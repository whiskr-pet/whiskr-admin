import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/recent_orders_widget.dart';
import '../widgets/low_stock_products_widget.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';
import 'analytics_screen.dart';
import 'services_screen.dart';
import 'login_screen.dart';
import '../models/order.dart';
import '../models/product.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _isPetShop(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.currentUser?.role == 'pet_shop';
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(BuildContext context) {
    final bool petShop = _isPetShop(context);
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(petShop ? Icons.room_service : Icons.inventory), label: petShop ? 'Services' : 'Inventory'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Orders'),
      const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
    ];
  }

  Widget _buildRoleAwareDrawerItem(BuildContext context) {
    final bool petShop = _isPetShop(context);
    return ListTile(
      leading: Icon(petShop ? Icons.room_service : Icons.inventory),
      title: Text(petShop ? 'Services Offered' : 'Inventory'),
      selected: _selectedIndex == 1,
      onTap: () => _onItemTapped(1),
    );
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await Future.wait([productProvider.loadProducts(), orderProvider.loadOrders()]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showOrderDetailsDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8)}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${order.customerName}'),
              Text('Email: ${order.customerEmail}'),
              Text('Phone: ${order.customerPhone}'),
              Text('Status: ${order.status.toUpperCase()}'),
              Text('Total: \$${order.total.toStringAsFixed(2)}'),
              Text('Date: ${order.createdAt}'),
              const SizedBox(height: 12),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.productName} x${item.quantity}', style: const TextStyle(fontSize: 12))),
                      Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showProductDetailsDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${product.category}'),
              Text('Price: \$${product.price.toStringAsFixed(2)}'),
              Text('Stock: ${product.stockQuantity}'),
              Text('Status: ${product.isActive ? 'Active' : 'Inactive'}'),
              const SizedBox(height: 12),
              Text('Description: ${product.description}'),
              if (product.tags.isNotEmpty) ...[const SizedBox(height: 8), Text('Tags: ${product.tags.join(', ')}')],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showPlaceholderDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiskr Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showPlaceholderDialog('Notifications', 'Notifications functionality coming soon!');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _showPlaceholderDialog('Profile', 'Profile functionality coming soon!');
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(children: [Icon(Icons.person_outline), SizedBox(width: 8), Text('Profile')]),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Logout')]),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: _buildBottomNavItems(context),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.pets, size: 30, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 12),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.currentUser?.name ?? 'Admin User',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.currentUser?.email ?? 'admin@whiskr.com',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), selected: _selectedIndex == 0, onTap: () => _onItemTapped(0)),
          _buildRoleAwareDrawerItem(context),
          ListTile(leading: const Icon(Icons.shopping_cart), title: const Text('Orders'), selected: _selectedIndex == 2, onTap: () => _onItemTapped(2)),
          ListTile(leading: const Icon(Icons.analytics), title: const Text('Analytics'), selected: _selectedIndex == 3, onTap: () => _onItemTapped(3)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              _showPlaceholderDialog('Settings', 'Settings functionality coming soon!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              _showPlaceholderDialog('Help & Support', 'Help & Support functionality coming soon!');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _isPetShop(context) ? const ServicesScreen() : const InventoryScreen();
      case 2:
        return const OrdersScreen();
      case 3:
        return const AnalyticsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Text('Welcome back, ${authProvider.currentUser?.name ?? 'Admin'}!', style: Theme.of(context).textTheme.headlineMedium);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening with your pet shop today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onItemTapped(1), // Navigate to Inventory or Services
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(_isPetShop(context) ? 'Add Service' : 'Add Product', style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onItemTapped(2), // Navigate to Orders
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('View Orders', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onItemTapped(3), // Navigate to Analytics
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('Analytics', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Consumer2<ProductProvider, OrderProvider>(
              builder: (context, productProvider, orderProvider, child) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardStatsCard(
                      title: 'Total Products',
                      value: productProvider.products.length.toString(),
                      icon: Icons.inventory,
                      color: AppTheme.primaryColor,
                      subtitle: '${productProvider.lowStockProducts.length} low stock',
                    ),
                    DashboardStatsCard(
                      title: 'Total Orders',
                      value: orderProvider.orders.length.toString(),
                      icon: Icons.shopping_cart,
                      color: AppTheme.secondaryColor,
                      subtitle: '${orderProvider.pendingOrders.length} pending',
                    ),
                    DashboardStatsCard(
                      title: 'Today\'s Revenue',
                      value: '\$${orderProvider.todayRevenue.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: AppTheme.successColor,
                      subtitle: '${orderProvider.recentOrders.length} orders today',
                    ),
                    DashboardStatsCard(
                      title: 'Total Revenue',
                      value: '\$${orderProvider.totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: AppTheme.infoColor,
                      subtitle: 'All time',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(2),
                  child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RecentOrdersWidget(onViewAll: () => _onItemTapped(2), onOrderTap: _showOrderDetailsDialog),
            const SizedBox(height: 24),

            // Low Stock Products
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                TextButton(
                  onPressed: () => _onItemTapped(1),
                  child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LowStockProductsWidget(onViewAll: () => _onItemTapped(1), onProductTap: _showProductDetailsDialog),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }
}
