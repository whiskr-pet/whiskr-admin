import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_dashboard_orders/wa_custom_dashboard_orders.dart';
import 'package:w_components/wa_custom_dashboard_stock/wa_custom_dashboard_low_stock_products.dart';
import 'package:w_components/wa_custom_overview_card/wa_custom_overview_card.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/providers/theme_provider/theme_provider.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

import '../../../providers/auth_provider.dart';
import '../analytics_screen.dart';
import '../inventory_screen.dart';
import '../orders_screen.dart';
import '../services_screen.dart';

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
    _getInitialData();
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

  Future<void> _getInitialData() async {}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          // Theme Switch Button
          Consumer<CustomThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    key: ValueKey(themeProvider.themeMode),
                  ),
                ),
                tooltip: themeProvider.themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  themeProvider.setThemeMode(!themeProvider.isDarkTheme(context));
                },
              );
            },
          ),
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
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: ColorHelper.blue500.color,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      // drawer: WebDrawer(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      //   onShowPlaceholderDialog: _showPlaceholderDialog,
      //   isPetShop: _isPetShop(context),
      // ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: ColorHelper.blue500.color,
        unselectedItemColor: Colors.grey,
        items: _buildBottomNavItems(context),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _BuildDashboardWelcome(onItemTapped: _onItemTapped, isPetShop: _isPetShop(context));
      case 1:
        return _isPetShop(context) ? const ServicesScreen() : const InventoryScreen();
      case 2:
        return const OrdersScreen();
      case 3:
        return const AnalyticsScreen();
      default:
        return _BuildDashboardWelcome(onItemTapped: _onItemTapped, isPetShop: _isPetShop(context));
    }
  }

  Future<void> _logout() async {
    final ResponseModel response = await context.read<AuthenticationProvider>().userLogout();
    if (response.isSuccess) {
      if (mounted) {
        context.go(loginRoute, extra: {'clearHistory': true});
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error ?? ''), backgroundColor: ColorHelper.red500.color));
      }
    }
  }
}

class _BuildDashboardWelcome extends StatelessWidget {
  const _BuildDashboardWelcome({required this.onItemTapped, required this.isPetShop});

  final void Function(int) onItemTapped;
  final bool isPetShop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Text('Welcome back, ${authProvider.currentUser?.name ?? 'Admin'}!', style: theme.textTheme.headlineMedium);
            },
          ),
          const SizedBox(height: 24),
          _BuildDashboardQuickActions(onItemTapped: onItemTapped, isPetShop: isPetShop),
          const SizedBox(height: 24),
          Text('Overview', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          _BuildDashboardOverviewCards(),
          const SizedBox(height: 24),
          WhiskrAdminDashboardTableSegment(segmentTitle: 'Recent Orders', orders: recentOrders),
          const SizedBox(height: 24),
          WhiskrAdminDashboardStockTableSegment(segmentTitle: 'Low Stock Products', products: lowStockProducts),
        ],
      ),
    );
  }
}

class _BuildDashboardOverviewCards extends StatelessWidget {
  const _BuildDashboardOverviewCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WhiskrAdminOverviewCards(icon: Icons.inventory, title: 'Total Products', value: '123', iconBackgroundColor: ColorHelper.magenta300.color),
        WhiskrAdminOverviewCards(icon: Icons.shopping_cart, title: 'Total Orders', value: '55', iconBackgroundColor: ColorHelper.yellow300.color),
        WhiskrAdminOverviewCards(
          icon: Icons.payments,
          title: "Today's Revenue",
          value:
              'KM '
              '300',
          iconBackgroundColor: ColorHelper.green300.color,
        ),
        WhiskrAdminOverviewCards(
          icon: Icons.payments,
          title: 'Total Revenue',
          value:
              'KM '
              '1302',
          iconBackgroundColor: ColorHelper.blue300.color,
        ),
      ],
    );
  }
}

class _BuildDashboardQuickActions extends StatelessWidget {
  const _BuildDashboardQuickActions({this.isPetShop = false, required this.onItemTapped});

  final bool isPetShop;
  final void Function(int) onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onItemTapped(1),
            icon: const Icon(Icons.add, size: 16),
            label: Text(isPetShop ? 'Add Service' : 'Add Product', style: const TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onItemTapped(2),
            icon: const Icon(Icons.shopping_cart, size: 16),
            label: const Text('View Orders', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onItemTapped(3),
            icon: const Icon(Icons.analytics, size: 16),
            label: const Text('Analytics', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

List<LowStockProductModel> lowStockProducts = [
  LowStockProductModel(
    image: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
    name: 'Cat Food',
    stock: 0,
    category: 'Food',
    status: LowStockProductStatus.outOfStock.title,
  ),
  LowStockProductModel(
    image:
        'https://ik.imagekit.io/petpals/pet-recipe-images/image_picker_637D0AF8-E5AB-4D47-82A5-923B6BB5C9A4-7340-00002CFE79C1C4EF_ugSLlVVbJ.jpg?updatedAt=1732786901469',
    name: 'Dog Food',
    stock: 10,
    category: 'Food',
    status: LowStockProductStatus.lowStock.title,
  ),
  LowStockProductModel(
    image:
        'https://ik.imagekit.io/petpals/pet-recipe-images/image_picker_637D0AF8-E5AB-4D47-82A5-923B6BB5C9A4-7340-00002CFE79C1C4EF_ugSLlVVbJ.jpg?updatedAt=1732786901469',
    name: 'Dog Food',
    stock: 10,
    category: 'Food',
    status: LowStockProductStatus.lowStock.title,
  ),
  LowStockProductModel(
    image:
        'https://ik.imagekit.io/petpals/pet-recipe-images/image_picker_637D0AF8-E5AB-4D47-82A5-923B6BB5C9A4-7340-00002CFE79C1C4EF_ugSLlVVbJ.jpg?updatedAt=1732786901469',
    name: 'Dog Food',
    stock: 10,
    category: 'Food',
    status: LowStockProductStatus.lowStock.title,
  ),
];

List<RecentOrderModel> recentOrders = [
  RecentOrderModel(customerImg: '', name: 'John Doe', amount: 100, date: '2021-01-01', status: 'Confirmed'),
  RecentOrderModel(customerImg: '', name: 'Jane Doe', amount: 200, date: '2021-01-02', status: 'Delivered'),
  RecentOrderModel(customerImg: '', name: 'Jim Beam', amount: 300, date: '2021-01-03', status: 'Cancelled'),
  RecentOrderModel(customerImg: '', name: 'Jim Beam', amount: 300, date: '2021-01-03', status: 'Cancelled'),
];
