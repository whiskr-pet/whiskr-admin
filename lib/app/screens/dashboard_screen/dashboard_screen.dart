import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_dashboard_appointments/wa_custom_dashboard_appointments.dart';
import 'package:w_components/wa_custom_dashboard_orders/wa_custom_dashboard_orders.dart';
import 'package:w_components/wa_custom_dashboard_stock/wa_custom_dashboard_low_stock_products.dart';
import 'package:w_components/wa_custom_overview_card/wa_custom_overview_card.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/services/service_type_service.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/dashboard_view_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';

import '../orders_and_appointments_screen/widgets/status_update_appointments_popup_widget.dart';

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
    final WAInventoryServicesProvider inventoryServicesProvider = context.read<WAInventoryServicesProvider>();
    final WaAppointmentsProvider appointmentsProvider = context.read<WaAppointmentsProvider>();
    final WAOnboardingProvider onboardingProvider = context.read<WAOnboardingProvider>();
    dashboardProvider.setLoading(true);
    final bool isTypeShop = await ServiceTypeService.getServiceType();
    dashboardProvider.setServiceType(isTypeShop);
    await onboardingProvider.getServiceAdmin();
    Future.wait([ordersProvider.getLastOrdersLimit(), appointmentsProvider.getLastAppointmentsLimit(), inventoryServicesProvider.getLowStockProducts()]);
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
              if (isPetShop)
                WhiskrAdminDashboardTableSegment(
                  segmentTitle: 'Recent Orders',
                  priceTag: 'KM ',
                  orders: context.watch<WaOrdersProvider>().lastOrdersList,
                  onRefresh: () async {
                    await context.read<WaOrdersProvider>().getLastOrdersLimit();
                  },
                )
              else
                _BuildDashboardAppointments(),
              const SizedBox(height: 24),
              if (isPetShop) WhiskrAdminDashboardStockTableSegment(segmentTitle: 'Low Stock Products', products: context.watch<WAInventoryServicesProvider>().lowStockProducts),
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
  const _BuildDashboardQuickActions({required this.isPetShop});

  final bool isPetShop;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: DashboardViewHelper.getDashboardOverviewModels(
        isPetShop ? DashboardType.petShop : DashboardType.serviceProvider,
        context,
      )
          .map(
            (model) => Expanded(
          child: ElevatedButton.icon(
            onPressed: model.onPressed,
            icon: Icon(model.icon),
            label: Text(model.title),
          ),
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
      builder: (context, appointments, child) => WhiskrAdminDashboardTableSegmentAppointments(
        segmentTitle: 'Recent Appointments',
        appointments: appointments,
        priceTag: 'KM ',
        onRefresh: () async => context.read<WaAppointmentsProvider>().getLastAppointmentsLimit(),
        onStatusTap: (WaAppointmentsModel appointment) async {
          await AppointmentStatusUpdatePopup.show(
            context,
            // Use the safe conversion method
            currentStatus: AppointmentStatusTypeExtension.fromBackendString(appointment.status ?? ''),
            appointmentId: appointment.id?.substring(0, 8) ?? '',
            onStatusUpdate: (StatusChipType newStatus) async {
              final WaAppointmentsProvider provider = context.read<WaAppointmentsProvider>();
              provider.setSelectedAppointmentForUpdate(appointment);
              provider.setStatusForUpdate(newStatus);

              final ResponseModel<String> response = await provider.updateAppointmentStatus();

              if (context.mounted) {
                if (response.isSuccess) {
                  await provider.getLastAppointmentsLimit();
                  if (context.mounted) {
                    WACustomSnackbar.instance.showSnack(
                      context,
                      'Appointment #${appointment.appointmentNumber} status updated to ${newStatus.toAppointmentType().title.toUpperCase()}',
                    );
                  }
                } else {
                  WACustomSnackbar.instance.showSnack(context, 'Failed to update status', type: WACustomSnackbarType.error);
                }
              }
            },
          );
        },
      ),
    );
  }
}