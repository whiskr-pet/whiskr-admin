import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_pet_service_module/providers/cart_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/extensions/string_extensions.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/services/service_type_service.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/order_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/schedule_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/status_update_popup_widget.dart';

import '../../helpers/loading_animation_helper.dart';

class OrdersAndAppointmentsScreen extends StatefulWidget {
  const OrdersAndAppointmentsScreen({super.key});

  @override
  State<OrdersAndAppointmentsScreen> createState() => _OrdersAndAppointmentsScreenState();
}

class _OrdersAndAppointmentsScreenState extends State<OrdersAndAppointmentsScreen> {
  bool? _isTypeShop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialData();
    });
  }

  Future<void> _getInitialData() async {
    final WaOrdersProvider provider = context.read<WaOrdersProvider>();
    final bool isTypeShop = await ServiceTypeService.getServiceType();
    setState(() {
      _isTypeShop = isTypeShop;
    });
    provider.setIsLoading(true);
    if (isTypeShop) {
      await Future.wait([provider.getAllOrders()]);
    } else {
      // await Future.wait([serviceOffersProvider.getAllOffers(), serviceOffersProvider.getServiceOfferedTags(), serviceOffersProvider.getServiceOfferedCategories()]);
    }
    provider.setIsLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while determining service type
    if (_isTypeShop == null) {
      return Scaffold(body: Center(child: LoadingAnimationHelper.loading));
    }

    return Scaffold(body: _BuildBody(_isTypeShop ?? false));
  }
}

class _BuildBody extends StatefulWidget {
  const _BuildBody(this.isTypeShop);

  final bool isTypeShop;

  @override
  State<_BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<_BuildBody> {
  DateTimeRange? selectedDateRange;

  OrderType? selectedOrderType;

  StatusChipType? selectedOrderStatus;

  String? get formattedDateRange {
    if (selectedDateRange == null) return null;
    final start = selectedDateRange!.start;
    final end = selectedDateRange!.end;

    // Format: "Jan 1 - Jan 7, 2025"
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${_monthName(start.month)} ${start.day}, ${start.year}';
    }
    return '${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}, ${end.year}';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

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
          // WAOrdersAppointmentFilter(
          //   selectedDate: formattedDateRange,
          //   selectedOrderType: selectedOrderType?.name.toUpperCase(),
          //   selectedOrderStatus: selectedOrderStatus?.name.toUpperCase(),
          //   onResetFilter: () {
          //     setState(() {
          //       selectedDateRange = null;
          //       selectedOrderType = null;
          //       selectedOrderStatus = null;
          //     });
          //   },
          //   onDateTap: () async {
          //     final result = await DateRangeSelector.show(context, currentSelection: selectedDateRange);
          //     if (result != null) {
          //       setState(() {
          //         selectedDateRange = result;
          //       });
          //       debugPrint("Result onDateTap: $result");
          //     }
          //   },
          //   onOrderTypeTap: () async {
          //     final result = await OrderTypeSelector.show(context, currentSelection: selectedOrderType);
          //     if (result != null) {
          //       setState(() {
          //         selectedOrderType = result;
          //       });
          //     }
          //   },
          //   onOrderStatusTap: () async {
          //     final result = await OrderStatusSelector.show(context, currentSelection: selectedOrderStatus);
          //     if (result != null) {
          //       debugPrint("Result onOrderStatusTap: $result");
          //       setState(() {
          //         selectedOrderStatus = result;
          //       });
          //     }
          //   },
          // ),
          const SizedBox(height: 40),
          Consumer<WaOrdersProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return LoadingAnimationHelper.loading;
              return WAOrdersTable(orders: provider.ordersList);
            },
          ),
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
  const WAOrdersTable({super.key, required this.orders, this.height = 430, this.onDelete, this.onEdit});

  final double height;
  final List<ServiceOrderModel> orders;
  final Function(String, String)? onDelete;
  final Function(String)? onEdit;

  @override
  Widget build(BuildContext context) {
    final cardHeight = Responsive.value(context: context, mobile: 400.0, tablet: height + 20.0, desktop: height + 100.0, widescreen: height + 50.0);

    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        border: Border.all(color: ColorHelper.grey200.color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _WATable(columns: columns(context), rows: rows(context, orders, onDelete, onEdit)),
          ),
        ],
      ),
    );
  }
}

class _WATable extends StatelessWidget {
  const _WATable({required this.columns, required this.rows});

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final columnSpacing = Responsive.value(context: context, mobile: 12.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    final horizontalMargin = Responsive.value(context: context, mobile: 8.0, tablet: 12.0, desktop: 16.0, widescreen: 20.0);

    final dataRowHeight = Responsive.value(context: context, mobile: 60.0, tablet: 70.0, desktop: 80.0, widescreen: 90.0);

    final minWidth = Responsive.value(context: context, mobile: 500.0, tablet: 600.0, desktop: 800.0, widescreen: 1000.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DataTable2(
        headingTextStyle: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        headingRowDecoration: BoxDecoration(color: ColorHelper.white.color),
        decoration: BoxDecoration(color: ColorHelper.white.color),
        columnSpacing: columnSpacing,
        horizontalMargin: horizontalMargin,
        minWidth: minWidth,
        dataRowHeight: dataRowHeight,
        scrollController: ScrollController(),
        fixedTopRows: 1,
        columns: columns,
        rows: rows,
        empty: const Center(child: Text('No orders')),
      ),
    );
  }
}

List<DataColumn> columns(BuildContext context) {
  return [
    DataColumn2(label: Text('Order number'), size: ColumnSize.S),
    DataColumn2(label: Text('Name'), size: ColumnSize.S),
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
              Text(
                '${order.user?.firstName ?? ''} ${order.user?.lastName}',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
