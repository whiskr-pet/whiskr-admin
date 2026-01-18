import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_dashboard_stock/wa_custom_dashboard_low_stock_products.dart';
import 'package:w_components/wa_custom_overview_card/wa_custom_overview_card.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/services/service_type_service.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
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
      builder: (context, appointments, child) => WhiskrAdminDashboardTableSegmentAppointments(
        segmentTitle: 'Recent Appointments',
        appointments: appointments,
        priceTag: 'KM ',
        onRefresh: () async => context.read<WaAppointmentsProvider>().getLastAppointmentsLimit(),
      ),
    );
  }
}

// todo remove all
class WhiskrAdminDashboardTableSegment extends StatelessWidget {
  const WhiskrAdminDashboardTableSegment({super.key, required this.segmentTitle, required this.orders, this.height = 430, required this.priceTag, this.onRefresh});

  final String segmentTitle;
  final double height;
  final String priceTag;
  final List<ServiceOrderModel> orders;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    final cardHeight = Responsive.value(context: context, mobile: 500.0, tablet: height + 60.0, desktop: height + 120.0, widescreen: height + 160.0);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: Container(
        width: double.infinity,
        height: cardHeight,
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0)),
            Expanded(child: _buildOrdersList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleFontSize = Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0);

    final subtitleFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

    final badgePadding = Responsive.value(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      tablet: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      desktop: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      widescreen: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

    final iconSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segmentTitle,
                style: theme.textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w700, fontSize: titleFontSize, color: colorScheme.onSurface, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                style: theme.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: subtitleFontSize),
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (onRefresh != null)
              IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh_rounded, size: iconSize),
                tooltip: 'Refresh orders',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  padding: EdgeInsets.all(Responsive.value(context: context, mobile: 8.0, tablet: 10.0, desktop: 12.0, widescreen: 14.0)),
                ),
              ),
            if (onRefresh != null) SizedBox(width: Responsive.value(context: context, mobile: 6.0, tablet: 8.0, desktop: 10.0, widescreen: 12.0)),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: Responsive.value(context: context, mobile: 4.0, tablet: 6.0, desktop: 8.0, widescreen: 10.0)),
      itemCount: orders.length,
      separatorBuilder: (context, index) => SizedBox(height: Responsive.value(context: context, mobile: 8.0, tablet: 10.0, desktop: 12.0, widescreen: 14.0)),
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index], priceTag: priceTag);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconSize = Responsive.value(context: context, mobile: 56.0, tablet: 64.0, desktop: 72.0, widescreen: 80.0);

    final titleFontSize = Responsive.value(context: context, mobile: 16.0, tablet: 18.0, desktop: 20.0, widescreen: 22.0);

    final subtitleFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: iconSize, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: theme.textTheme.titleMedium!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: titleFontSize),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here once placed',
            style: theme.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: subtitleFontSize),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order, required this.priceTag});

  final ServiceOrderModel order;
  final String priceTag;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceType = Responsive.getDeviceType(context);

    final cardPadding = Responsive.value(context: context, mobile: 12.0, tablet: 14.0, desktop: 16.0, widescreen: 18.0);

    final borderRadius = Responsive.value(context: context, mobile: 12.0, tablet: 14.0, desktop: 16.0, widescreen: 18.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? colorScheme.surfaceContainerHighest.withOpacity(0.5) : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: _isHovered ? colorScheme.primary.withOpacity(0.3) : colorScheme.outlineVariant.withOpacity(0.3), width: 1),
        ),
        padding: EdgeInsets.all(cardPadding),
        child: deviceType == DeviceType.mobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildCustomerInfo(context)),
            const SizedBox(width: 8),
            StatusChip.orderStatus(widget.order.status ?? ''),
          ],
        ),
        const SizedBox(height: 12),
        _buildOrderDetailsMobile(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerInfoWidth = Responsive.value(context: context, mobile: 200.0, tablet: 240.0, desktop: 280.0, widescreen: 320.0);

    final amountWidth = Responsive.value(context: context, mobile: 120.0, tablet: 140.0, desktop: 160.0, widescreen: 180.0);

    final dateWidth = Responsive.value(context: context, mobile: 110.0, tablet: 120.0, desktop: 140.0, widescreen: 160.0);

    final statusWidth = Responsive.value(context: context, mobile: 120.0, tablet: 130.0, desktop: 140.0, widescreen: 150.0);

    final spacing = Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0);

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        SizedBox(width: customerInfoWidth, child: _buildCustomerInfo(context)),
        SizedBox(width: spacing),
        SizedBox(
          width: amountWidth,
          child: _buildDetailItemInline(
            context,
            icon: Icons.payments_rounded,
            label: 'Amount',
            value: '${widget.priceTag}${widget.order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
            color: colorScheme.primary,
          ),
        ),
        SizedBox(width: spacing),
        SizedBox(
          width: dateWidth,
          child: _buildDetailItemInline(
            context,
            icon: Icons.local_shipping_outlined,
            label: 'Delivery',
            value: _formatDate(widget.order.deliveryDate ?? ''),
            color: colorScheme.tertiary,
          ),
        ),
        SizedBox(width: spacing),
        SizedBox(
          width: dateWidth,
          child: _buildDetailItemInline(context, icon: Icons.schedule_rounded, label: 'Created', value: _formatDate(widget.order.createdAt ?? ''), color: colorScheme.secondary),
        ),
        SizedBox(width: spacing),
        SizedBox(width: statusWidth, child: StatusChip.orderStatus(widget.order.status ?? '')),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = widget.order.user?.firstName ?? 'Guest';
    final imageUrl = widget.order.user?.image?.url ?? '';

    final avatarRadius = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    final nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    final emailFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 12.5, desktop: 13.0, widescreen: 13.5);

    return Row(
      children: [
        _CustomerAvatar(imageUrl: imageUrl, customerName: customerName, radius: avatarRadius),
        SizedBox(width: Responsive.value(context: context, mobile: 10.0, tablet: 11.0, desktop: 12.0, widescreen: 14.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: nameFontSize),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.order.user?.email ?? 'No email',
                style: theme.textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant, fontSize: emailFontSize),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsMobile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildDetailItemInline(
          context,
          icon: Icons.payments_rounded,
          label: 'Amount',
          value: '${widget.priceTag}${widget.order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
          color: colorScheme.primary,
        ),
        _buildDetailItemInline(context, icon: Icons.local_shipping_outlined, label: 'Delivery', value: _formatDate(widget.order.deliveryDate ?? ''), color: colorScheme.tertiary),
        _buildDetailItemInline(context, icon: Icons.schedule_rounded, label: 'Created', value: _formatDate(widget.order.createdAt ?? ''), color: colorScheme.secondary),
      ],
    );
  }

  Widget _buildDetailItemInline(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    final labelFontSize = Responsive.value(context: context, mobile: 11.0, tablet: 11.5, desktop: 12.0, widescreen: 12.5);

    final valueFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color.withOpacity(0.7)),
        SizedBox(width: Responsive.value(context: context, mobile: 4.0, tablet: 5.0, desktop: 6.0, widescreen: 7.0)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: labelFontSize),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: valueFontSize),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      final dateOnly = DateTime(date.year, date.month, date.day);
      final nowOnly = DateTime(now.year, now.month, now.day);
      final difference = dateOnly.difference(nowOnly).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == -1) {
        return 'Yesterday';
      } else if (difference < -1 && difference >= -6) {
        return '${-difference} days ago';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference > 1 && difference <= 6) {
        return 'In $difference days';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.imageUrl, required this.customerName, this.radius = 24});

  final String imageUrl;
  final String customerName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials(context);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildLoadingIndicator(context);
                  },
                )
              : _buildInitials(context),
        ),
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(customerName),
          style: TextStyle(color: colorScheme.onPrimary, fontSize: radius * 0.7, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    final initials = StringBuffer();

    for (var i = 0; i < names.length && i < 2; i++) {
      if (names[i].isNotEmpty) {
        initials.write(names[i][0].toUpperCase());
      }
    }

    return initials.isEmpty ? '?' : initials.toString();
  }
}

/// appointments
///
class WhiskrAdminDashboardTableSegmentAppointments extends StatelessWidget {
  const WhiskrAdminDashboardTableSegmentAppointments({
    super.key,
    required this.segmentTitle,
    required this.appointments,
    this.height = 430,
    required this.priceTag,
    this.onRefresh,
  });

  final String segmentTitle;
  final double height;
  final String priceTag;
  final List<WaAppointmentsModel> appointments;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    final cardHeight = Responsive.value(context: context, mobile: 500.0, tablet: height + 60.0, desktop: height + 120.0, widescreen: height + 160.0);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: Container(
        width: double.infinity,
        height: cardHeight,
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0)),
            Expanded(child: _buildAppointmentsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleFontSize = Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0);

    final subtitleFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

    final badgePadding = Responsive.value(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      tablet: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      desktop: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      widescreen: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

    final iconSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segmentTitle,
                style: theme.textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w700, fontSize: titleFontSize, color: colorScheme.onSurface, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                '${appointments.length} ${appointments.length == 1 ? 'appointment' : 'appointments'}',
                style: theme.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: subtitleFontSize),
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (onRefresh != null)
              IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh_rounded, size: iconSize),
                tooltip: 'Refresh appointments',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  padding: EdgeInsets.all(Responsive.value(context: context, mobile: 8.0, tablet: 10.0, desktop: 12.0, widescreen: 14.0)),
                ),
              ),
            if (onRefresh != null) SizedBox(width: Responsive.value(context: context, mobile: 6.0, tablet: 8.0, desktop: 10.0, widescreen: 12.0)),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(BuildContext context) {
    if (appointments.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: Responsive.value(context: context, mobile: 4.0, tablet: 6.0, desktop: 8.0, widescreen: 10.0)),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => SizedBox(height: Responsive.value(context: context, mobile: 8.0, tablet: 10.0, desktop: 12.0, widescreen: 14.0)),
      itemBuilder: (context, index) {
        return _AppointmentCard(appointment: appointments[index], priceTag: priceTag);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconSize = Responsive.value(context: context, mobile: 56.0, tablet: 64.0, desktop: 72.0, widescreen: 80.0);

    final titleFontSize = Responsive.value(context: context, mobile: 16.0, tablet: 18.0, desktop: 20.0, widescreen: 22.0);

    final subtitleFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: iconSize, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: theme.textTheme.titleMedium!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: titleFontSize),
          ),
          const SizedBox(height: 8),
          Text(
            'Appointments will appear here once scheduled',
            style: theme.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: subtitleFontSize),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatefulWidget {
  const _AppointmentCard({required this.appointment, required this.priceTag});

  final WaAppointmentsModel appointment;
  final String priceTag;

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceType = Responsive.getDeviceType(context);

    final cardPadding = Responsive.value(context: context, mobile: 12.0, tablet: 14.0, desktop: 16.0, widescreen: 18.0);

    final borderRadius = Responsive.value(context: context, mobile: 12.0, tablet: 14.0, desktop: 16.0, widescreen: 18.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? colorScheme.surfaceContainerHighest.withOpacity(0.5) : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: _isHovered ? colorScheme.primary.withOpacity(0.3) : colorScheme.outlineVariant.withOpacity(0.3), width: 1),
        ),
        padding: EdgeInsets.all(cardPadding),
        child: deviceType == DeviceType.mobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildCustomerInfo(context)),
            const SizedBox(width: 8),
            StatusChip.orderStatus(widget.appointment.status ?? ''),
          ],
        ),
        const SizedBox(height: 12),
        _buildAppointmentDetailsMobile(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerInfoWidth = Responsive.value(context: context, mobile: 200.0, tablet: 220.0, desktop: 240.0, widescreen: 260.0);

    final serviceWidth = Responsive.value(context: context, mobile: 180.0, tablet: 200.0, desktop: 220.0, widescreen: 240.0);

    final dateWidth = Responsive.value(context: context, mobile: 120.0, tablet: 130.0, desktop: 140.0, widescreen: 150.0);

    final timeWidth = Responsive.value(context: context, mobile: 100.0, tablet: 110.0, desktop: 120.0, widescreen: 130.0);

    final statusWidth = Responsive.value(context: context, mobile: 120.0, tablet: 130.0, desktop: 140.0, widescreen: 150.0);

    final spacing = Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: customerInfoWidth, child: _buildCustomerInfo(context)),
        SizedBox(width: spacing),
        SizedBox(
          width: serviceWidth,
          child: _buildDetailItemInline(
            context,
            icon: Icons.medical_services_rounded,
            label: 'Service',
            value: widget.appointment.items.map((item) => item.name).join(', '),
            color: colorScheme.primary,
          ),
        ),
        SizedBox(width: spacing),
        SizedBox(
          width: dateWidth,
          child: _buildDetailItemInline(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: _formatDate(widget.appointment.date?.toIso8601String() ?? ''),
            color: colorScheme.tertiary,
          ),
        ),
        SizedBox(width: spacing),
        SizedBox(
          width: timeWidth,
          child: _buildDetailItemInline(context, icon: Icons.access_time_rounded, label: 'Time', value: widget.appointment.time ?? 'N/A', color: colorScheme.secondary),
        ),
        SizedBox(width: spacing),
        SizedBox(width: statusWidth, child: StatusChip.orderStatus(widget.appointment.status ?? '')),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = widget.appointment.customer ?? 'Guest';

    final avatarRadius = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    final nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    final phoneFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 12.5, desktop: 13.0, widescreen: 13.5);

    // todo pass image url when available
    return Row(
      children: [
        _CustomerAvatarAppointment(imageUrl: '', customerName: customerName, radius: avatarRadius),
        SizedBox(width: Responsive.value(context: context, mobile: 10.0, tablet: 11.0, desktop: 12.0, widescreen: 14.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: nameFontSize),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.appointment.phone ?? 'No phone',
                style: theme.textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant, fontSize: phoneFontSize),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailsMobile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildDetailItemInline(
          context,
          icon: Icons.medical_services_rounded,
          label: 'Service',
          value: widget.appointment.items.map((item) => item.name).join(', '),
          color: colorScheme.primary,
        ),
        _buildDetailItemInline(
          context,
          icon: Icons.calendar_today_rounded,
          label: 'Date',
          value: _formatDate(widget.appointment.date?.toIso8601String() ?? ''),
          color: colorScheme.tertiary,
        ),
        _buildDetailItemInline(context, icon: Icons.access_time_rounded, label: 'Time', value: widget.appointment.time ?? 'N/A', color: colorScheme.secondary),
      ],
    );
  }

  Widget _buildDetailItemInline(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    final labelFontSize = Responsive.value(context: context, mobile: 11.0, tablet: 11.5, desktop: 12.0, widescreen: 12.5);

    final valueFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color.withOpacity(0.7)),
        SizedBox(width: Responsive.value(context: context, mobile: 4.0, tablet: 5.0, desktop: 6.0, widescreen: 7.0)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: labelFontSize),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface, fontSize: valueFontSize),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      final dateOnly = DateTime(date.year, date.month, date.day);
      final nowOnly = DateTime(now.year, now.month, now.day);
      final difference = dateOnly.difference(nowOnly).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == -1) {
        return 'Yesterday';
      } else if (difference < -1 && difference >= -6) {
        return '${-difference} days ago';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference > 1 && difference <= 6) {
        return 'In $difference days';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

class _CustomerAvatarAppointment extends StatelessWidget {
  const _CustomerAvatarAppointment({required this.imageUrl, required this.customerName, this.radius = 24});

  final String imageUrl;
  final String customerName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials(context);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildLoadingIndicator(context);
                  },
                )
              : _buildInitials(context),
        ),
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(customerName),
          style: TextStyle(color: colorScheme.onPrimary, fontSize: radius * 0.7, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    final initials = StringBuffer();

    for (var i = 0; i < names.length && i < 2; i++) {
      if (names[i].isNotEmpty) {
        initials.write(names[i][0].toUpperCase());
      }
    }

    return initials.isEmpty ? '?' : initials.toString();
  }
}
