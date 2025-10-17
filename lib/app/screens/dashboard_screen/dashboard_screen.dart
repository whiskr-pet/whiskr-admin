import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_dashboard_orders/wa_custom_dashboard_orders.dart';
import 'package:w_components/wa_custom_dashboard_stock/wa_custom_dashboard_low_stock_products.dart';
import 'package:w_components/wa_custom_overview_card/wa_custom_overview_card.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:whiskr_admin_panel/providers/auth_provider.dart';

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
    return true;
  }

  Future<void> _getInitialData() async {}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BuildDashboardWelcome(onItemTapped: _onItemTapped, isPetShop: _isPetShop(context)),
    );
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
              return Text('Welcome back, ${authProvider.currentUser?.name ?? 'Eric Cartman'}!', style: theme.textTheme.headlineMedium);
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
