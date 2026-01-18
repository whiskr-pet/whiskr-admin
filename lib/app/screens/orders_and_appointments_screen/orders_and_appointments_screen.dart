import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_utils/extensions/string_extensions.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/services/service_type_service.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_provider.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_search_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_search_provider.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/appointment_status_chip.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/appointments_filters.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/order_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/orders_filters.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/schedule_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/status_update_appointments_popup_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/status_update_popup_widget.dart';

import '../../helpers/loading_animation_helper.dart';

class OrdersAndAppointmentsScreen extends StatefulWidget {
  const OrdersAndAppointmentsScreen({super.key});

  @override
  State<OrdersAndAppointmentsScreen> createState() => _OrdersAndAppointmentsScreenState();
}

class _OrdersAndAppointmentsScreenState extends State<OrdersAndAppointmentsScreen> {
  late WaOrdersSearchProvider searchProvider;
  late WaAppointmentsSearchProvider appointmentsSearchProvider;
  bool? _isTypeShop;

  @override
  void initState() {
    searchProvider = WaOrdersSearchProvider();
    appointmentsSearchProvider = WaAppointmentsSearchProvider();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialData();
    });
  }

  Future<void> _getInitialData() async {
    final WaOrdersProvider provider = context.read<WaOrdersProvider>();
    final WaAppointmentsProvider appointmentsProvider = context.read<WaAppointmentsProvider>();
    final bool isTypeShop = await ServiceTypeService.getServiceType();
    setState(() {
      _isTypeShop = isTypeShop;
    });
    provider.setIsLoading(true);
    provider.setSearchMode(false);
    if (isTypeShop) {
      await Future.wait([provider.getAllOrders()]);
    } else {
      await Future.wait([appointmentsProvider.getAllAppointments()]);
    }
    provider.setIsLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while determining service type
    if (_isTypeShop == null) {
      return Scaffold(body: Center(child: LoadingAnimationHelper.loading));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WaOrdersSearchProvider>.value(value: searchProvider),
        ChangeNotifierProvider<WaAppointmentsSearchProvider>.value(value: appointmentsSearchProvider),
      ],
      builder: (context, child) {
        return Scaffold(body: _BuildBody(_isTypeShop ?? false));
      },
    );
  }

  @override
  void dispose() {
    searchProvider.dispose();
    super.dispose();
  }
}

class _BuildBody extends StatefulWidget {
  const _BuildBody(this.isTypeShop);

  final bool isTypeShop;

  @override
  State<_BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<_BuildBody> {
  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 32.0, desktop: 40.0, widescreen: 48.0);
    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BuildHeader(widget.isTypeShop),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          widget.isTypeShop ? const OrdersFiltersWidget() : const AppointmentsFiltersWidget(),
          const SizedBox(height: 40),
          widget.isTypeShop
              ? Consumer2<WaOrdersProvider, WaOrdersSearchProvider>(
                  builder: (context, ordersProvider, searchProvider, child) {
                    if (ordersProvider.isLoading || searchProvider.isLoading) {
                      return LoadingAnimationHelper.loading;
                    }

                    final List<ServiceOrderModel> orders = ordersProvider.isSearchMode ? searchProvider.items : ordersProvider.ordersList;

                    return WAOrdersTable(orders: orders, isTypeShop: widget.isTypeShop);
                  },
                )
              : Consumer2<WaAppointmentsProvider, WaAppointmentsSearchProvider>(
                  builder: (context, appointmentsProvider, searchProvider, child) {
                    if (appointmentsProvider.isLoading || searchProvider.isLoading) {
                      return LoadingAnimationHelper.loading;
                    }

                    final List<WaAppointmentsModel> appointments = appointmentsProvider.isSearchMode ? searchProvider.items : appointmentsProvider.appointmentsList;

                    return WAAppointmentsTable(appointments: appointments, isTypeShop: widget.isTypeShop);
                  },
                ),
          const SizedBox(height: 30),
          const _BuildPaginationControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader(this.isTypeShop);

  final bool isTypeShop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 28.0, desktop: 32.0, widescreen: 36.0);

    return Text(
      isTypeShop ? 'Orders' : 'Appointments',
      style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize, fontWeight: FontWeight.bold),
    );
  }
}

class WAOrdersTable extends StatelessWidget {
  const WAOrdersTable({super.key, required this.orders, this.height = 430, this.onDelete, this.onEdit, this.isTypeShop = false});

  final double height;
  final List<ServiceOrderModel> orders;
  final Function(String, String)? onDelete;
  final Function(String)? onEdit;
  final bool isTypeShop;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final cardHeight = Responsive.value(context: context, mobile: 400.0, tablet: height + 20.0, desktop: height + 100.0, widescreen: height + 50.0);

    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _WATable(columns: columns(context), rows: rows(context, orders, onDelete, onEdit), isTypeShop: isTypeShop),
          ),
        ],
      ),
    );
  }
}

class _WATable extends StatelessWidget {
  const _WATable({required this.columns, required this.rows, this.isTypeShop = false});

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isTypeShop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final columnSpacing = Responsive.value(context: context, mobile: 12.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    final horizontalMargin = Responsive.value(context: context, mobile: 8.0, tablet: 12.0, desktop: 16.0, widescreen: 20.0);

    final dataRowHeight = Responsive.value(context: context, mobile: 60.0, tablet: 70.0, desktop: 80.0, widescreen: 90.0);

    final minWidth = Responsive.value(context: context, mobile: 500.0, tablet: 600.0, desktop: 800.0, widescreen: 1000.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DataTable2(
        headingTextStyle: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        headingRowDecoration: BoxDecoration(color: colorScheme.surface),
        decoration: BoxDecoration(color: colorScheme.surface),
        columnSpacing: columnSpacing,
        horizontalMargin: horizontalMargin,
        minWidth: minWidth,
        dataRowHeight: dataRowHeight,
        scrollController: ScrollController(),
        fixedTopRows: 1,
        columns: columns,
        rows: rows,
        empty: Center(child: Text('No ${isTypeShop ? "orders" : "appointments"}')),
      ),
    );
  }
}

List<DataColumn> columns(BuildContext context) {
  return [
    DataColumn2(label: Text('Order number'), size: ColumnSize.S),
    DataColumn2(label: Text('Name'), size: ColumnSize.M),
    DataColumn2(label: Text('Address'), size: ColumnSize.M),
    DataColumn2(label: Text('Date'), size: ColumnSize.S),
    DataColumn2(label: Text('Order Type'), size: ColumnSize.S),
    DataColumn2(label: Text('Schedule'), size: ColumnSize.S),
    DataColumn2(label: Text('Status'), size: ColumnSize.S),
  ];
}

List<DataRow> rows(BuildContext context, List<ServiceOrderModel> orders, Function? onDelete, Function? onEdit) {
  final theme = Theme.of(context);

  final nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

  final amountFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

  final dateFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 13.0, desktop: 14.0, widescreen: 15.0);
  return orders
      .map(
        (ServiceOrderModel order) => DataRow(
          cells: [
            // Order number
            DataCell(
              Text(
                order.orderNumber ?? '',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: nameFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Name
            DataCell(
              Row(
                spacing: 8,
                children: [
                  _CustomerAvatarAppointment(
                    imageUrl: order.user?.image?.url ?? '',
                    customerName: '${order.user?.firstName ?? ''} ${order.user?.lastName}',
                    radius: Responsive.value(context: context, mobile: 14.0, tablet: 16.0, desktop: 18.0, widescreen: 20.0),
                  ),
                  Text(
                    '${order.user?.firstName ?? ''} ${order.user?.lastName}',
                    style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            // Address
            DataCell(
              Text(
                order.deliveryAddress ?? '',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Date
            DataCell(
              Text(
                (order.deliveryDate ?? '').toFullDateTimeString(),
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            DataCell(OrderTypeChipWidget(orderType: order.orderType!.name)),
            DataCell(ScheduleTypeChipWidget(scheduleType: order.scheduleType!.name)),

            // Status
            DataCell(
              InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
                  await StatusUpdatePopup.show(
                    context,
                    currentStatus: StatusChipTypeExtension.fromString(order.status ?? ''),
                    orderNumber: order.orderNumber ?? '',
                    onStatusUpdate: (newStatus) async {
                      final provider = context.read<WaOrdersProvider>();
                      provider.setSelectedOrderForUpdate(order);
                      provider.setStatusForUpdate(newStatus);

                      final ResponseModel<String> response = await provider.updateOrderStatus();

                      if (context.mounted) {
                        if (response.isSuccess) {
                          await provider.getAllOrders();
                          WACustomSnackbar.instance.showSnack(context, 'Order #${order.orderNumber} status updated to ${newStatus.name.toUpperCase()}');
                        } else {
                          WACustomSnackbar.instance.showSnack(context, '', type: .error);
                        }
                      }
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), child: StatusChip.orderStatus(order.status ?? '')),
              ),
            ),
          ],
        ),
      )
      .toList();
}

class WAAppointmentsTable extends StatelessWidget {
  const WAAppointmentsTable({super.key, required this.appointments, this.height = 430, this.onDelete, this.onEdit, this.isTypeShop = false});

  final bool isTypeShop;
  final double height;
  final List<WaAppointmentsModel> appointments;
  final Function(String, String)? onDelete;
  final Function(String)? onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final double cardHeight = Responsive.value(context: context, mobile: 400.0, tablet: height + 20.0, desktop: height + 100.0, widescreen: height + 50.0);

    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _WATable(columns: appointmentsColumns(context), rows: appointmentRows(context, appointments, onDelete, onEdit), isTypeShop: isTypeShop),
          ),
        ],
      ),
    );
  }
}

List<DataColumn> appointmentsColumns(BuildContext context) {
  return [
    DataColumn2(label: Text('Appointment ID'), size: ColumnSize.S),
    DataColumn2(label: Text('Customer'), size: ColumnSize.M),
    DataColumn2(label: Text('Order Created'), size: ColumnSize.S),
    DataColumn2(label: Text('Contact'), size: ColumnSize.M),
    DataColumn2(label: Text('Scheduled Date & Time'), size: ColumnSize.M),
    DataColumn2(label: Text('Total Price'), size: ColumnSize.S),
    DataColumn2(label: Text('Status'), size: ColumnSize.S),
  ];
}

List<DataRow> appointmentRows(BuildContext context, List<WaAppointmentsModel> appointments, Function? onDelete, Function? onEdit) {
  final ThemeData theme = Theme.of(context);
  final double nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);
  final double amountFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);
  final double dateFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 13.0, desktop: 14.0, widescreen: 15.0);

  return appointments
      .map(
        (WaAppointmentsModel appointment) => DataRow(
          cells: [
            // Appointment ID
            DataCell(
              Text(
                appointment.appointmentNumber ?? '',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: nameFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Customer Name
            DataCell(
              Row(
                spacing: 8,
                children: [
                  _CustomerAvatarAppointment(
                    imageUrl: appointment.userImage != null ? appointment.userImage!.url ?? '' : '',
                    customerName: appointment.customer ?? 'N/A',
                    radius: Responsive.value(context: context, mobile: 14.0, tablet: 16.0, desktop: 18.0, widescreen: 20.0),
                  ),

                  Text(
                    appointment.customer ?? 'N/A',
                    style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                appointment.createdAt != null ? '${appointment.createdAt!.day}/${appointment.createdAt!.month}/${appointment.createdAt!.year}' : 'N/A',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Contact (Email or Phone)
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (appointment.email != null)
                    Text(
                      appointment.email!,
                      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: dateFontSize),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  if (appointment.phone != null)
                    Text(
                      appointment.phone!,
                      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: dateFontSize, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            // Date & Time
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.date != null ? '${appointment.date!.day}/${appointment.date!.month}/${appointment.date!.year}' : 'N/A',
                    style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
                  ),
                  if (appointment.time != null)
                    Text(
                      appointment.time!,
                      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: dateFontSize - 1, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            // Total
            DataCell(
              Text(
                appointment.total != null ? '\$${appointment.total!.toStringAsFixed(2)}' : '\$0.00',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: amountFontSize, color: theme.colorScheme.primary),
              ),
            ),
            // Status with update functionality
            DataCell(
              InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
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
                          await provider.getAllAppointments();
                          if (context.mounted) {
                            WACustomSnackbar.instance.showSnack(
                              context,
                              'Appointment #${appointment.appointmentNumber} status updated to ${newStatus.toAppointmentType().title.toUpperCase()}',
                            );
                          }
                        } else {
                          WACustomSnackbar.instance.showSnack(context, 'Failed to update status', type: .error);
                        }
                      }
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  // Convert backend status to appointment status for display
                  child: AppointmentStatusChip(status: appointment.status ?? ''),
                ),
              ),
            ),
          ],
        ),
      )
      .toList();
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
        boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
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
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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

class _BuildPaginationControls extends StatelessWidget {
  const _BuildPaginationControls();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isMobile = Responsive.isMobile(context);

    return Consumer4<WaOrdersSearchProvider, WaOrdersProvider, WaAppointmentsSearchProvider, WaAppointmentsProvider>(
      builder: (context, ordersSearchProvider, ordersProvider, appointmentsSearchProvider, appointmentsProvider, child) {
        // Determine which provider to use based on service type
        final bool isTypeShop = context.findAncestorStateOfType<_BuildBodyState>()!.widget.isTypeShop;

        final bool isSearchMode = isTypeShop ? ordersProvider.isSearchMode : appointmentsProvider.isSearchMode;

        final int currentPage = isTypeShop
            ? (isSearchMode ? ordersSearchProvider.currentPage : ordersProvider.currentPage)
            : (isSearchMode ? appointmentsSearchProvider.currentPage : appointmentsProvider.currentPage);

        final int totalPages = isTypeShop
            ? (isSearchMode ? ordersSearchProvider.totalPages : ordersProvider.totalPages)
            : (isSearchMode ? appointmentsSearchProvider.totalPages : appointmentsProvider.totalPages);

        final bool hasPrevious = isTypeShop
            ? (isSearchMode ? ordersSearchProvider.hasPreviousPage : ordersProvider.hasPreviousPage)
            : (isSearchMode ? appointmentsSearchProvider.hasPreviousPage : appointmentsProvider.hasPreviousPage);

        final bool hasNext = isTypeShop
            ? (isSearchMode ? ordersSearchProvider.hasNextPage : ordersProvider.hasNextPage)
            : (isSearchMode ? appointmentsSearchProvider.hasNextPage : appointmentsProvider.hasNextPage);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: Responsive.value(context: context, mobile: 0.0, tablet: 0.0, desktop: 0.0, widescreen: 0.0)),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[BoxShadow(color: theme.shadowColor.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.value(context: context, mobile: 20.0, tablet: 32.0, desktop: 40.0, widescreen: 48.0),
              vertical: Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PaginationButton(
                  icon: Icons.chevron_left_rounded,
                  label: isMobile ? null : 'Previous',
                  onPressed: hasPrevious
                      ? () {
                          if (isTypeShop) {
                            if (isSearchMode) {
                              ordersSearchProvider.previousPage();
                            } else {
                              ordersProvider.loadPreviousPage();
                            }
                          } else {
                            if (isSearchMode) {
                              appointmentsSearchProvider.previousPage();
                            } else {
                              appointmentsProvider.loadPreviousPage();
                            }
                          }
                        }
                      : null,
                  isEnabled: hasPrevious,
                  width: isMobile ? 48 : 140,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0),
                    vertical: Responsive.value(context: context, mobile: 10.0, tablet: 12.0, desktop: 14.0, widescreen: 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Page',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 15.0),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '$currentPage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 16.0),
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'of',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 15.0),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalPages',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 16.0),
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                _PaginationButton(
                  icon: Icons.chevron_right_rounded,
                  label: isMobile ? null : 'Next',
                  onPressed: hasNext
                      ? () {
                          if (isTypeShop) {
                            if (isSearchMode) {
                              ordersSearchProvider.nextPage();
                            } else {
                              ordersProvider.loadNextPage();
                            }
                          } else {
                            if (isSearchMode) {
                              appointmentsSearchProvider.nextPage();
                            } else {
                              appointmentsProvider.loadNextPage();
                            }
                          }
                        }
                      : null,
                  isEnabled: hasNext,
                  isNext: true,
                  width: isMobile ? 48 : 140,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginationButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isNext;
  final double width;

  const _PaginationButton({required this.icon, this.label, this.onPressed, required this.isEnabled, this.isNext = false, required this.width});

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width,
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.isEnabled
                ? (_isHovered
                      ? LinearGradient(colors: <Color>[colorScheme.primary, colorScheme.primary.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : LinearGradient(
                          colors: <Color>[colorScheme.primary.withValues(alpha: 0.12), colorScheme.primary.withValues(alpha: 0.06)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ))
                : null,
            color: widget.isEnabled ? null : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isEnabled ? (_isHovered ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.35)) : colorScheme.outline.withValues(alpha: 0.55),
              width: _isHovered && widget.isEnabled ? 2 : 1.5,
            ),
            boxShadow: _isHovered && widget.isEnabled
                ? <BoxShadow>[BoxShadow(color: colorScheme.primary.withValues(alpha: 0.22), blurRadius: 8, offset: const Offset(0, 4))]
                : <BoxShadow>[],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.isNext && widget.label != null)
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isEnabled ? (_isHovered ? colorScheme.onPrimary : colorScheme.primary) : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              if (widget.label != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: widget.isEnabled ? (_isHovered ? colorScheme.onPrimary : colorScheme.primary) : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                ),
              ],
              if (widget.label == null)
                Icon(
                  widget.icon,
                  size: 24,
                  color: widget.isEnabled ? (_isHovered ? colorScheme.onPrimary : colorScheme.primary) : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              if (widget.isNext && widget.label != null)
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isEnabled ? (_isHovered ? colorScheme.onPrimary : colorScheme.primary) : colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
