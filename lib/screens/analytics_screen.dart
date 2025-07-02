import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';
import '../models/order.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeRange = '7d';
  String _selectedMetric = 'revenue';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
              const PopupMenuItem(value: '1y', child: Text('Last Year')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 4), Text(_getTimeRangeText())]),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<OrderProvider>(context, listen: false).loadOrders();
          await Provider.of<ProductProvider>(context, listen: false).loadProducts();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Demo Mode Indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Demo Mode: Click on any card to see detailed analytics', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Revenue Overview
              const Text(
                'Revenue Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildClickableStatCard(
                          'Total Revenue',
                          '\$${orderProvider.totalRevenue.toStringAsFixed(2)}',
                          Icons.attach_money,
                          AppTheme.successColor,
                          () => _showRevenueDetails(orderProvider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildClickableStatCard(
                          'Today\'s Revenue',
                          '\$${orderProvider.todayRevenue.toStringAsFixed(2)}',
                          Icons.trending_up,
                          AppTheme.primaryColor,
                          () => _showTodayRevenueDetails(orderProvider),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Order Statistics
              const Text(
                'Order Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  final stats = orderProvider.orderStatistics;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildClickableStatCard('Pending', stats['pending'].toString(), Icons.schedule, AppTheme.warningColor, () => _showOrderStatusDetails('pending', orderProvider)),
                      _buildClickableStatCard('Confirmed', stats['confirmed'].toString(), Icons.check_circle, AppTheme.infoColor, () => _showOrderStatusDetails('confirmed', orderProvider)),
                      _buildClickableStatCard('Processing', stats['processing'].toString(), Icons.build, AppTheme.primaryColor, () => _showOrderStatusDetails('processing', orderProvider)),
                      _buildClickableStatCard('Delivered', stats['delivered'].toString(), Icons.done_all, AppTheme.successColor, () => _showOrderStatusDetails('delivered', orderProvider)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Product Statistics
              const Text(
                'Product Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildClickableStatCard(
                          'Total Products',
                          productProvider.products.length.toString(),
                          Icons.inventory,
                          AppTheme.primaryColor,
                          () => _showAllProductsDetails(productProvider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildClickableStatCard(
                          'Low Stock',
                          productProvider.lowStockProducts.length.toString(),
                          Icons.warning,
                          AppTheme.warningColor,
                          () => _showLowStockDetails(productProvider),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Sales Chart
              const Text(
                'Sales Trend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              _buildSalesChart(),
              const SizedBox(height: 24),

              // Top Products
              const Text(
                'Top Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              _buildTopProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 12),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'Poppins'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Revenue Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedMetric = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'revenue', child: Text('Revenue')),
                    const PopupMenuItem(value: 'orders', child: Text('Orders')),
                    const PopupMenuItem(value: 'products', child: Text('Products')),
                  ],
                  child: Text(_getMetricText()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildChartData()),
          ],
        ),
      ),
    );
  }

  Widget _buildChartData() {
    final data = _getChartData();
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final barWidth = (availableWidth - 40) / data.length; // 40 for padding
        final maxBarWidth = 40.0; // Maximum bar width
        final actualBarWidth = barWidth < maxBarWidth ? barWidth : maxBarWidth;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            final maxValue = data.reduce((a, b) => a > b ? a : b);
            final height = maxValue > 0 ? (value / maxValue) * 100.0 : 0.0;

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: actualBarWidth,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(_getChartLabel(index), style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTopProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final topProducts = productProvider.products.take(5).toList();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topProducts.length,
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(product.name),
                subtitle: Text(product.category),
                trailing: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor),
                ),
                onTap: () => _showProductDetails(product),
              );
            },
          ),
        );
      },
    );
  }

  // Helper methods
  String _getTimeRangeText() {
    switch (_selectedTimeRange) {
      case '7d':
        return '7D';
      case '30d':
        return '30D';
      case '90d':
        return '90D';
      case '1y':
        return '1Y';
      default:
        return '7D';
    }
  }

  String _getMetricText() {
    switch (_selectedMetric) {
      case 'revenue':
        return 'Revenue';
      case 'orders':
        return 'Orders';
      case 'products':
        return 'Products';
      default:
        return 'Revenue';
    }
  }

  List<double> _getChartData() {
    switch (_selectedMetric) {
      case 'revenue':
        return [1200, 1800, 1500, 2200, 1900, 2500, 2100];
      case 'orders':
        return [15, 22, 18, 28, 24, 32, 26];
      case 'products':
        return [8, 12, 10, 15, 13, 18, 16];
      default:
        return [1200, 1800, 1500, 2200, 1900, 2500, 2100];
    }
  }

  String _getChartLabel(int index) {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[index % labels.length];
  }

  // Detail dialogs
  void _showRevenueDetails(OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revenue Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Total Revenue', '\$${orderProvider.totalRevenue.toStringAsFixed(2)}'),
              _buildDetailRow('Today\'s Revenue', '\$${orderProvider.todayRevenue.toStringAsFixed(2)}'),
              _buildDetailRow('Average Order Value', '\$${(orderProvider.totalRevenue / orderProvider.orders.length).toStringAsFixed(2)}'),
              _buildDetailRow('Total Orders', orderProvider.orders.length.toString()),
              _buildDetailRow('Delivered Orders', orderProvider.deliveredOrders.length.toString()),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showTodayRevenueDetails(OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Today\'s Revenue Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Today\'s Revenue', '\$${orderProvider.todayRevenue.toStringAsFixed(2)}'),
              _buildDetailRow('Orders Today', orderProvider.recentOrders.length.toString()),
              _buildDetailRow('Average Order Today', '\$${(orderProvider.todayRevenue / orderProvider.recentOrders.length).toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showOrderStatusDetails(String status, OrderProvider orderProvider) {
    final orders = orderProvider.orders.where((order) => order.status == status).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$status Orders'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text('${orders.length} orders with $status status'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(title: Text(order.customerName), subtitle: Text('Order #${order.id.substring(0, 8)}'), trailing: Text('\$${order.total.toStringAsFixed(2)}'));
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showAllProductsDetails(ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Products'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text('${productProvider.products.length} total products'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return ListTile(title: Text(product.name), subtitle: Text(product.category), trailing: Text('\$${product.price.toStringAsFixed(2)}'));
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showLowStockDetails(ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Low Stock Products'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text('${productProvider.lowStockProducts.length} products with low stock'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: productProvider.lowStockProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.lowStockProducts[index];
                    return ListTile(title: Text(product.name), subtitle: Text('Stock: ${product.stockQuantity}'), trailing: Text('\$${product.price.toStringAsFixed(2)}'));
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Category', product.category),
            _buildDetailRow('Price', '\$${product.price.toStringAsFixed(2)}'),
            _buildDetailRow('Stock', product.stockQuantity.toString()),
            _buildDetailRow('Status', product.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow('Tags', product.tags.join(', ')),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
