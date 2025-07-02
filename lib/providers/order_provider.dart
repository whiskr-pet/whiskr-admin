import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'all';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;

  // Filtered orders based on status
  List<Order> get filteredOrders {
    if (_selectedStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => order.status == _selectedStatus).toList();
  }

  // Get orders by status
  List<Order> get pendingOrders => _orders.where((order) => order.isPending).toList();
  List<Order> get confirmedOrders => _orders.where((order) => order.isConfirmed).toList();
  List<Order> get processingOrders => _orders.where((order) => order.isProcessing).toList();
  List<Order> get shippedOrders => _orders.where((order) => order.isShipped).toList();
  List<Order> get deliveredOrders => _orders.where((order) => order.isDelivered).toList();
  List<Order> get cancelledOrders => _orders.where((order) => order.isCancelled).toList();

  // Get recent orders (last 7 days)
  List<Order> get recentOrders {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _orders.where((order) => order.createdAt.isAfter(sevenDaysAgo)).toList();
  }

  // Get total revenue
  double get totalRevenue {
    return _orders.where((order) => order.isDelivered).fold(0.0, (sum, order) => sum + order.total);
  }

  // Get today's revenue
  double get todayRevenue {
    final today = DateTime.now();
    return _orders
        .where((order) => order.isDelivered && order.createdAt.year == today.year && order.createdAt.month == today.month && order.createdAt.day == today.day)
        .fold(0.0, (sum, order) => sum + order.total);
  }

  // Load orders
  Future<void> loadOrders() async {
    _setLoading(true);
    _error = null;

    try {
      _orders = await _apiService.getOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load orders by status
  Future<void> loadOrdersByStatus(String status) async {
    _setLoading(true);
    _error = null;

    try {
      _orders = await _apiService.getOrders(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedOrder = await _apiService.updateOrderStatus(orderId, newStatus);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      return await _apiService.getOrder(orderId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Set selected status filter
  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get order statistics
  Map<String, int> get orderStatistics {
    return {
      'pending': pendingOrders.length,
      'confirmed': confirmedOrders.length,
      'processing': processingOrders.length,
      'shipped': shippedOrders.length,
      'delivered': deliveredOrders.length,
      'cancelled': cancelledOrders.length,
    };
  }

  // Get monthly revenue data
  Map<String, double> get monthlyRevenue {
    final Map<String, double> monthlyData = {};
    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';

      final monthRevenue = _orders.where((order) => order.isDelivered && order.createdAt.year == month.year && order.createdAt.month == month.month).fold(0.0, (sum, order) => sum + order.total);

      monthlyData[monthKey] = monthRevenue;
    }

    return monthlyData;
  }

  // Create demo order for testing
  Future<bool> createDemoOrder() async {
    try {
      final demoOrder = await _apiService.createDemoOrder();
      _orders.insert(0, demoOrder);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
