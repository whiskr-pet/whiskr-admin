import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/service_offering.dart';

class ApiService {
  static const String baseUrl = 'https://your-whiskr-api.com/api'; // Not used for demo
  static const String authTokenKey = 'auth_token';
  static const String productsKey = 'local_products';
  static const String ordersKey = 'local_orders';
  static const String servicesKey = 'local_services';

  // ignore: unused_field
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
  }

  // Local storage helpers
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Authentication methods
  // ignore: unused_element
  Future<String?> _getAuthToken() async {
    final prefs = await _prefs;
    return prefs.getString(authTokenKey);
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(authTokenKey, token);
  }

  Future<void> _clearAuthToken() async {
    final prefs = await _prefs;
    await prefs.remove(authTokenKey);
  }

  // Demo login - always succeeds
  Future<User> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
    await _saveAuthToken(token);

    return User(
      id: 'demo_user_1',
      email: email,
      name: 'Demo Admin',
      role: email.contains('shop') ? 'pet_shop' : 'admin',
      shopId: 'demo_shop_1',
      shopName: 'Whiskr Pet Shop',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
    );
  }

  // Demo logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _clearAuthToken();
  }

  // Demo get current user
  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return User(
      id: 'demo_user_1',
      email: 'admin@whiskr.com',
      name: 'Demo Admin',
      // role: 'admin',
      role: 'pet_shop',
      shopId: 'demo_shop_1',
      shopName: 'Whiskr Pet Shop',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
    );
  }

  // Local product storage
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await _prefs;
    final productsJson = prefs.getString(productsKey);

    if (productsJson != null) {
      final List<dynamic> productsList = json.decode(productsJson);
      return productsList.map((json) => Product.fromJson(json)).toList();
    }

    // Return demo products if none exist
    return _getDemoProducts();
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newProduct = Product(
      id: 'product_${DateTime.now().millisecondsSinceEpoch}',
      name: productData['name'],
      description: productData['description'],
      price: productData['price'],
      stockQuantity: productData['stockQuantity'],
      category: productData['category'],
      imageUrl: productData['imageUrl'],
      tags: List<String>.from(productData['tags'] ?? []),
      isActive: productData['isActive'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      shopId: 'demo_shop_1',
    );

    final products = await getProducts();
    products.add(newProduct);
    await _saveProducts(products);

    return newProduct;
  }

  Future<Product> updateProduct(String productId, Map<String, dynamic> productData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final products = await getProducts();
    final index = products.indexWhere((product) => product.id == productId);

    if (index != -1) {
      final updatedProduct = products[index].copyWith(
        name: productData['name'],
        description: productData['description'],
        price: productData['price'],
        stockQuantity: productData['stockQuantity'],
        category: productData['category'],
        imageUrl: productData['imageUrl'],
        tags: List<String>.from(productData['tags'] ?? []),
        isActive: productData['isActive'],
        updatedAt: DateTime.now(),
      );

      products[index] = updatedProduct;
      await _saveProducts(products);
      return updatedProduct;
    }

    throw Exception('Product not found');
  }

  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final products = await getProducts();
    products.removeWhere((product) => product.id == productId);
    await _saveProducts(products);
  }

  Future<Product> createDemoProduct() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final demoProducts = [
      {
        'name': 'Bird Cage Deluxe',
        'description': 'Spacious bird cage with multiple perches and feeding stations',
        'price': 89.99,
        'stockQuantity': 5,
        'category': 'Accessories',
        'tags': ['birds', 'cage', 'deluxe'],
      },
      {
        'name': 'Fish Tank Filter',
        'description': 'High-quality aquarium filter for clean water',
        'price': 34.99,
        'stockQuantity': 12,
        'category': 'Accessories',
        'tags': ['fish', 'filter', 'aquarium'],
      },
      {
        'name': 'Rabbit Food Premium',
        'description': 'Nutritious rabbit food with vitamins and minerals',
        'price': 18.99,
        'stockQuantity': 25,
        'category': 'Pet Food',
        'tags': ['rabbit', 'food', 'premium'],
      },
      {
        'name': 'Hamster Exercise Wheel',
        'description': 'Silent running exercise wheel for hamsters',
        'price': 22.99,
        'stockQuantity': 8,
        'category': 'Toys',
        'tags': ['hamster', 'exercise', 'wheel'],
      },
    ];

    final randomProduct = demoProducts[DateTime.now().millisecond % demoProducts.length];

    final newProduct = Product(
      id: 'demo_product_${DateTime.now().millisecondsSinceEpoch}',
      name: randomProduct['name'] as String,
      description: randomProduct['description'] as String,
      price: randomProduct['price'] as double,
      stockQuantity: randomProduct['stockQuantity'] as int,
      category: randomProduct['category'] as String,
      imageUrl: 'https://via.placeholder.com/300x300?text=${Uri.encodeComponent(randomProduct['name'] as String)}',
      tags: List<String>.from(randomProduct['tags'] as List),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      shopId: 'demo_shop_1',
    );

    // Save the new product
    final products = await getProducts();
    products.insert(0, newProduct);
    await _saveProducts(products);

    return newProduct;
  }

  Future<void> _saveProducts(List<Product> products) async {
    final prefs = await _prefs;
    final productsJson = json.encode(products.map((p) => p.toJson()).toList());
    await prefs.setString(productsKey, productsJson);
  }

  // Local order storage
  Future<List<Order>> getOrders({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await _prefs;
    final ordersJson = prefs.getString(ordersKey);

    if (ordersJson != null) {
      final List<dynamic> ordersList = json.decode(ordersJson);
      final orders = ordersList.map((json) => Order.fromJson(json)).toList();

      if (status != null && status != 'all') {
        return orders.where((order) => order.status == status).toList();
      }
      return orders;
    }

    // Return demo orders if none exist
    return _getDemoOrders();
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final orders = await getOrders();
    final index = orders.indexWhere((order) => order.id == orderId);

    if (index != -1) {
      final updatedOrder = orders[index].copyWith(status: status, updatedAt: DateTime.now());

      orders[index] = updatedOrder;
      await _saveOrders(orders);
      return updatedOrder;
    }

    throw Exception('Order not found');
  }

  Future<Order> getOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final orders = await getOrders();
    final order = orders.firstWhere((order) => order.id == orderId);
    return order;
  }

  Future<Order> createDemoOrder() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final demoCustomers = [
      {'name': 'Alice Brown', 'email': 'alice@example.com', 'phone': '+1234567892'},
      {'name': 'Mike Wilson', 'email': 'mike@example.com', 'phone': '+1234567893'},
      {'name': 'Emma Davis', 'email': 'emma@example.com', 'phone': '+1234567894'},
      {'name': 'Tom Anderson', 'email': 'tom@example.com', 'phone': '+1234567895'},
    ];

    final demoProducts = [
      {'name': 'Bird Seed Mix', 'price': 12.99},
      {'name': 'Fish Food Pellets', 'price': 8.99},
      {'name': 'Hamster Bedding', 'price': 6.99},
      {'name': 'Rabbit Hay', 'price': 9.99},
    ];

    final randomCustomer = demoCustomers[DateTime.now().millisecond % demoCustomers.length];
    final randomProduct = demoProducts[DateTime.now().millisecond % demoProducts.length];
    final quantity = (DateTime.now().millisecond % 3) + 1;
    final total = (randomProduct['price'] as double) * quantity;

    final newOrder = Order(
      id: 'demo_order_${DateTime.now().millisecondsSinceEpoch}',
      customerId: 'customer_${DateTime.now().millisecondsSinceEpoch}',
      customerName: randomCustomer['name']!,
      customerEmail: randomCustomer['email']!,
      customerPhone: randomCustomer['phone']!,
      items: [
        OrderItem(
          productId: 'demo_product_${DateTime.now().millisecondsSinceEpoch}',
          productName: randomProduct['name'] as String,
          price: randomProduct['price'] as double,
          quantity: quantity,
          total: total,
        ),
      ],
      subtotal: total,
      tax: total * 0.1,
      total: total * 1.1,
      status: 'pending',
      notes: 'Demo order created for testing',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      shopId: 'demo_shop_1',
      deliveryAddress: '${100 + (DateTime.now().millisecond % 900)} Demo St, Demo City, DC 12345',
      paymentMethod: 'credit_card',
      isPaid: false,
    );

    // Save the new order
    final orders = await getOrders();
    orders.insert(0, newOrder);
    await _saveOrders(orders);

    return newOrder;
  }

  Future<void> _saveOrders(List<Order> orders) async {
    final prefs = await _prefs;
    final ordersJson = json.encode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(ordersKey, ordersJson);
  }

  // Local services storage (demo)
  Future<List<ServiceOffering>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await _prefs;
    final String? servicesJson = prefs.getString(servicesKey);
    if (servicesJson != null) {
      final List<dynamic> list = json.decode(servicesJson) as List<dynamic>;
      return list.map((dynamic j) => ServiceOffering.fromJson(j as Map<String, dynamic>)).toList();
    }
    return _getDemoServices();
  }

  Future<ServiceOffering> createService(ServiceOffering service) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final List<ServiceOffering> list = await getServices();
    final ServiceOffering created = service.copyWith(
      id: service.id.isEmpty ? 'service_${DateTime.now().millisecondsSinceEpoch}' : service.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    list.insert(0, created);
    await _saveServices(list);
    return created;
  }

  Future<ServiceOffering> updateService(String id, ServiceOffering update) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final List<ServiceOffering> list = await getServices();
    final int index = list.indexWhere((ServiceOffering s) => s.id == id);
    if (index == -1) throw Exception('Service not found');
    final ServiceOffering updated = update.copyWith(updatedAt: DateTime.now());
    list[index] = updated;
    await _saveServices(list);
    return updated;
  }

  Future<void> deleteService(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final List<ServiceOffering> list = await getServices();
    list.removeWhere((ServiceOffering s) => s.id == id);
    await _saveServices(list);
  }

  Future<void> _saveServices(List<ServiceOffering> services) async {
    final prefs = await _prefs;
    final String payload = json.encode(services.map((ServiceOffering s) => s.toJson()).toList());
    await prefs.setString(servicesKey, payload);
  }

  // Dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final products = await getProducts();
    final orders = await getOrders();

    final totalRevenue = orders.where((order) => order.isDelivered).fold(0.0, (sum, order) => sum + order.total);

    final todayRevenue = orders
        .where(
          (order) =>
              order.isDelivered &&
              order.createdAt.day == DateTime.now().day &&
              order.createdAt.month == DateTime.now().month &&
              order.createdAt.year == DateTime.now().year,
        )
        .fold(0.0, (sum, order) => sum + order.total);

    return {
      'totalProducts': products.length,
      'totalOrders': orders.length,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'pendingOrders': orders.where((o) => o.isPending).length,
      'lowStockProducts': products.where((p) => p.isLowStock).length,
    };
  }

  Future<List<Map<String, dynamic>>> getSalesChartData(String period) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return demo chart data
    return [
      {'month': 'Jan', 'revenue': 1200.0},
      {'month': 'Feb', 'revenue': 1800.0},
      {'month': 'Mar', 'revenue': 1500.0},
      {'month': 'Apr', 'revenue': 2200.0},
      {'month': 'May', 'revenue': 1900.0},
      {'month': 'Jun', 'revenue': 2500.0},
    ];
  }

  // File upload (demo)
  Future<String> uploadImage(String filePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://via.placeholder.com/300x300?text=Product+Image';
  }

  // Demo data generators
  List<Product> _getDemoProducts() {
    return [
      Product(
        id: 'demo_product_1',
        name: 'Premium Dog Food',
        description: 'High-quality dog food with natural ingredients',
        price: 29.99,
        stockQuantity: 45,
        category: 'Pet Food',
        imageUrl: 'https://via.placeholder.com/300x300?text=Dog+Food',
        tags: ['premium', 'natural', 'dogs'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        shopId: 'demo_shop_1',
      ),
      Product(
        id: 'demo_product_2',
        name: 'Cat Toy Set',
        description: 'Interactive toys for cats',
        price: 15.99,
        stockQuantity: 8,
        category: 'Toys',
        imageUrl: 'https://via.placeholder.com/300x300?text=Cat+Toys',
        tags: ['interactive', 'cats', 'toys'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        shopId: 'demo_shop_1',
      ),
      Product(
        id: 'demo_product_3',
        name: 'Pet Carrier',
        description: 'Comfortable pet carrier for travel',
        price: 49.99,
        stockQuantity: 0,
        category: 'Accessories',
        imageUrl: 'https://via.placeholder.com/300x300?text=Pet+Carrier',
        tags: ['travel', 'carrier', 'comfortable'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        shopId: 'demo_shop_1',
      ),
    ];
  }

  List<Order> _getDemoOrders() {
    return [
      Order(
        id: 'demo_order_1',
        customerId: 'customer_1',
        customerName: 'John Smith',
        customerEmail: 'john@example.com',
        customerPhone: '+1234567890',
        items: [OrderItem(productId: 'demo_product_1', productName: 'Premium Dog Food', price: 29.99, quantity: 2, total: 59.98)],
        subtotal: 59.98,
        tax: 5.99,
        total: 65.97,
        status: 'pending',
        notes: 'Please deliver in the afternoon',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        shopId: 'demo_shop_1',
        deliveryAddress: '123 Main St, City, State 12345',
        paymentMethod: 'credit_card',
        isPaid: true,
      ),
      Order(
        id: 'demo_order_2',
        customerId: 'customer_2',
        customerName: 'Sarah Johnson',
        customerEmail: 'sarah@example.com',
        customerPhone: '+1234567891',
        items: [OrderItem(productId: 'demo_product_2', productName: 'Cat Toy Set', price: 15.99, quantity: 1, total: 15.99)],
        subtotal: 15.99,
        tax: 1.60,
        total: 17.59,
        status: 'delivered',
        notes: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        shopId: 'demo_shop_1',
        deliveryAddress: '456 Oak Ave, City, State 12345',
        paymentMethod: 'paypal',
        isPaid: true,
      ),
    ];
  }

  List<ServiceOffering> _getDemoServices() {
    return <ServiceOffering>[
      ServiceOffering(
        id: 'service_1',
        shopId: 'demo_shop_1',
        name: 'Full Grooming Package',
        type: 'grooming',
        description: 'Bath, haircut, nail trim, ear cleaning',
        price: 59.99,
        durationMinutes: 90,
        tags: const <String>['grooming', 'dogs', 'full'],
        isActive: true,
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      ServiceOffering(
        id: 'service_2',
        shopId: 'demo_shop_1',
        name: 'Dog Walking (30 min)',
        type: 'walking',
        description: 'Leash walk around the neighborhood',
        price: 15.00,
        durationMinutes: 30,
        tags: const <String>['walking', 'dogs'],
        isActive: true,
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      ServiceOffering(
        id: 'service_3',
        shopId: 'demo_shop_1',
        name: 'Basic Obedience Training',
        type: 'training',
        description: 'Sit, stay, come, leash manners',
        price: 120.00,
        durationMinutes: 60,
        tags: const <String>['training', 'obedience'],
        isActive: true,
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Error handling
  // ignore: unused_element
  String _handleDioError(DioException error) {
    return 'Demo mode - no actual API calls';
  }
}
