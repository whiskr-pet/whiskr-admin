import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_components/wa_custom_dashboard_appointments/wa_custom_dashboard_appointments.dart';
import 'package:w_components/wa_custom_dashboard_orders/wa_custom_dashboard_orders.dart';
import 'package:w_components/wa_custom_dashboard_stock/wa_custom_dashboard_low_stock_products.dart';
import 'package:w_components/wa_custom_overview_card/wa_custom_overview_card.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/dashboard_view_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialData();
    });
  }

  Future<void> _getInitialData() async {
    final DashboardProvider dashboardProvider = context.read<DashboardProvider>();
    final WaOrdersProvider ordersProvider = context.read<WaOrdersProvider>();
    final WaAppointmentsProvider appointmentsProvider = context.read<WaAppointmentsProvider>();
    dashboardProvider.setLoading(true);
    await context.read<WAOnboardingProvider>().getServiceAdmin();
    Future.wait([ordersProvider.getLastOrdersLimit(), appointmentsProvider.getLastAppointmentsLimit()]);
    dashboardProvider.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Selector<DashboardProvider, bool>(
        selector: (context, dashboardProvider) => dashboardProvider.isPetShop,
        builder: (context, isPetShop, child) {
          return _BuildDashboardWelcome(isPetShop: isPetShop);
        },
      ),
    );
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
      child: Selector<DashboardProvider, bool>(
        selector: (context, dashboardProvider) => dashboardProvider.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return Center(child: LoadingAnimationHelper.loading);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Selector<WAOnboardingProvider, String>(
                selector: (context, onboardingProvider) => onboardingProvider.serviceAdminData.name ?? '',
                builder: (context, name, child) {
                  return Text('Welcome back, $name!', style: theme.textTheme.headlineMedium);
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await context.read<AuthenticationProvider>().userLogout().then((value) {
                    if (context.mounted) context.go(loginRoute);
                  });
                },
                child: Text('logout'),
              ),
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
              if (isPetShop) WhiskrAdminDashboardTableSegment(segmentTitle: 'Recent Orders', priceTag: 'KM ', orders: recentOrders) else _BuildDashboardAppointments(),
              const SizedBox(height: 24),
              if (isPetShop) WhiskrAdminDashboardStockTableSegment(segmentTitle: 'Low Stock Products', products: lowStockProducts),
            ],
          );
        },
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
    return Selector<WaAppointmentsProvider, List<WaAppointmentsModel>>(
      selector: (context, appointmentsProvider) => appointmentsProvider.lastAppointmentsList,
      builder: (context, appointments, child) => WhiskrAdminDashboardTableSegmentAppointments(segmentTitle: 'Recent Appointments', appointments: appointments, priceTag: 'KM '),
    );
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
    image: 'https://ik.imagekit.io/petpals/pet-recipe-images/image_picker_637D0AF8-E5AB-4D47-82A5-923B6BB5C9A4-7340-00002CFE79C1C4EF_ugSLlVVbJ.jpg?updatedAt=1732786901469',
    name: 'Dog Food',
    stock: 10,
    category: 'Food',
    status: LowStockProductStatus.lowStock.title,
  ),
  LowStockProductModel(
    image: 'https://ik.imagekit.io/petpals/pet-recipe-images/image_picker_637D0AF8-E5AB-4D47-82A5-923B6BB5C9A4-7340-00002CFE79C1C4EF_ugSLlVVbJ.jpg?updatedAt=1732786901469',
    name: 'Dog Food',
    stock: 10,
    category: 'Food',
    status: LowStockProductStatus.lowStock.title,
  ),
  LowStockProductModel(
    image: 'https://ik.imagekit.io/petpals/pet-recipe-images/image_picker_637D0AF8-E5AB-4D47-82A5-923B6BB5C9A4-7340-00002CFE79C1C4EF_ugSLlVVbJ.jpg?updatedAt=1732786901469',
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
