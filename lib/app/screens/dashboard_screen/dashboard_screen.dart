import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_dashboard_appointments/wa_custom_dashboard_appointments.dart';
import 'package:w_components/wa_custom_dashboard_orders/wa_custom_dashboard_orders.dart';
import 'package:w_components/wa_custom_dashboard_stock/wa_custom_dashboard_low_stock_products.dart';
import 'package:w_components/wa_custom_overview_card/wa_custom_overview_card.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/dashboard_view_helper.dart';
import 'package:whiskr_admin_panel/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  bool _isPetShop(BuildContext context) {
    return true;
  }

  Future<void> _getInitialData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildDashboardWelcome(isPetShop: _isPetShop(context)));
  }
}

class _BuildDashboardWelcome extends StatelessWidget {
  const _BuildDashboardWelcome({required this.isPetShop});

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
          _BuildDashboardQuickActions(isPetShop: isPetShop),
          const SizedBox(height: 24),
          Text('Overview', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          if (Responsive.isTablet(context) || Responsive.isMobile(context)) ...[
            _BuildDashboardOverviewCardsTabletLayout(),
          ] else ...[
            _BuildDashboardOverviewCards(),
            const SizedBox(height: 24),
          ],
          if (!isPetShop)
            WhiskrAdminDashboardTableSegment(segmentTitle: 'Recent Orders', priceTag: 'KM ', orders: recentOrders)
          else
            _BuildDashboardAppointments(),
          const SizedBox(height: 24),
          WhiskrAdminDashboardStockTableSegment(segmentTitle: 'Low Stock Products', products: lowStockProducts),
        ],
      ),
    );
  }
}

// Tablet layout
class _BuildDashboardOverviewCardsTabletLayout extends StatelessWidget {
  const _BuildDashboardOverviewCardsTabletLayout();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.value<double>(context: context, mobile: 350, tablet: 350, desktop: 350, widescreen: 350),
      width: double.infinity,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: Responsive.value<double>(
          context: context,
          mobile: 1.5,
          tablet: context.select<DashboardProvider, double>((dashboardProvider) => dashboardProvider.isSideMenuOpen ? 1.5 : 2),
          desktop: 1.5,
          widescreen: 1.5,
        ),
        crossAxisSpacing: 1.2,
        mainAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        children: [
          WhiskrAdminOverviewCards(icon: Icons.inventory, title: 'Total Products', value: '123', iconBackgroundColor: ColorHelper.magenta300.color),
          WhiskrAdminOverviewCards(icon: Icons.shopping_cart, title: 'Total Orders', value: '55', iconBackgroundColor: ColorHelper.yellow300.color),
          WhiskrAdminOverviewCards(icon: Icons.payments, title: "Today's Revenue", value: 'KM 300', iconBackgroundColor: ColorHelper.green300.color),
          WhiskrAdminOverviewCards(icon: Icons.payments, title: 'Total Revenue', value: 'KM 1302', iconBackgroundColor: ColorHelper.blue300.color),
        ],
      ),
    );
  }
}

// todo when BE is ready, move to helper, create model, go over
class _BuildDashboardOverviewCards extends StatelessWidget {
  const _BuildDashboardOverviewCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(icon: Icons.inventory, title: 'Total Products', value: '123', iconBackgroundColor: ColorHelper.magenta300.color),
        ),
        Expanded(
          child: WhiskrAdminOverviewCards(icon: Icons.shopping_cart, title: 'Total Orders', value: '55', iconBackgroundColor: ColorHelper.yellow300.color),
        ),
        Expanded(
          child: WhiskrAdminOverviewCards(icon: Icons.payments, title: "Today's Revenue", value: 'KM 300', iconBackgroundColor: ColorHelper.green300.color),
        ),
        Expanded(
          child: WhiskrAdminOverviewCards(icon: Icons.payments, title: 'Total Revenue', value: 'KM 132302', iconBackgroundColor: ColorHelper.blue300.color),
        ),
      ],
    );
  }
}

class _BuildDashboardQuickActions extends StatelessWidget {
  _BuildDashboardQuickActions({this.isPetShop = false});

  final bool isPetShop;
  final DashboardViewHelper dashboardViewHelper = DashboardViewHelper();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dashboardViewHelper
          .dashboardOverviewHelperModels(isPetShop)
          .map(
            (model) => Expanded(
              child: ElevatedButton.icon(onPressed: model.onPressed, icon: Icon(model.icon), label: Text(model.title)),
            ),
          )
          .toList(),
    );
  }
}

class _BuildDashboardAppointments extends StatelessWidget {
  const _BuildDashboardAppointments();

  @override
  Widget build(BuildContext context) {
    return WhiskrAdminDashboardTableSegmentAppointments(segmentTitle: 'Recent Appointments', appointments: appointments, priceTag: 'KM ');
  }
}

// TODO: Remove this after BE connection
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

List<AppointmentModel> appointments = [
  AppointmentModel(
    customerImg: '',
    customer: 'John Doe',
    petId: '123',
    email: 'john@example.com',
    phone: '1234567890',
    address: '123 Main St, Anytown, USA',
    items: [
      AppointmentItemModel(name: 'Service 1', price: 100),
      AppointmentItemModel(name: 'Service 22', price: 200),
      AppointmentItemModel(name: 'Service 33', price: 300),
      AppointmentItemModel(name: 'Service 44', price: 400),
      AppointmentItemModel(name: 'Service 1', price: 100),
      AppointmentItemModel(name: 'Service 22', price: 200),
      AppointmentItemModel(name: 'Service 33', price: 300),
      AppointmentItemModel(name: 'Service 44', price: 400),
    ],
    total: 1000,
    date: DateTime.now(),
    time: '10:00',
    note: 'Note 1',
    status: 'Confirmed',
  ),
  AppointmentModel(
    customerImg: '',
    customer: 'Jane Doe',
    petId: '123',
    email: 'jane@example.com',
    phone: '1234567890',
    address: '123 Main St, Anytown, USA',
    items: [AppointmentItemModel(name: 'Service 2', price: 200)],
    total: 200,
    date: DateTime.now(),
    time: '10:00',
    note: 'Note 2',
    status: 'Delivered',
  ),
  AppointmentModel(
    customerImg: '',
    customer: 'Jim Beam',
    petId: '123',
    email: 'jim@example.com',
    phone: '1234567890',
    address: '123 Main St, Anytown, USA',
    items: [AppointmentItemModel(name: 'Service 3', price: 300)],
    total: 300,
    date: DateTime.now(),
    time: '10:00',
    note: 'Note 3',
    status: 'Cancelled',
  ),
  AppointmentModel(
    customerImg: '',
    customer: 'Jim Beam',
    petId: '123',
    email: 'jim@example.com',
    phone: '1234567890',
    address: '123 Main St, Anytown, USA',
    items: [AppointmentItemModel(name: 'Service 4', price: 400)],
    total: 400,
    date: DateTime.now(),
    time: '10:00',
    note: 'Note 4',
    status: 'Cancelled',
  ),
];
