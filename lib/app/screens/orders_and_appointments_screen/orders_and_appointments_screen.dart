import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/wa_order.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/wa_order_and_appointments_filter.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/wa_order_item.dart';

class OrdersAndAppointmentsScreen extends StatelessWidget {
  const OrdersAndAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildBody());
  }
}

class _BuildBody extends StatefulWidget {
  const _BuildBody({super.key});

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
          _BuildHeader(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          WAOrdersAppointmentFilter(
            selectedDate: formattedDateRange,
            selectedOrderType: selectedOrderType?.name.toUpperCase(),
            selectedOrderStatus: selectedOrderStatus?.name.toUpperCase(),
            onResetFilter: () {
              setState(() {
                selectedDateRange = null;
                selectedOrderType = null;
                selectedOrderStatus = null;
              });
            },
            onDateTap: () async {
              final result = await DateRangeSelector.show(context, currentSelection: selectedDateRange);
              if (result != null) {
                setState(() {
                  selectedDateRange = result;
                });
                debugPrint("Result onDateTap: $result");
              }
            },
            onOrderTypeTap: () async {
              final result = await OrderTypeSelector.show(context, currentSelection: selectedOrderType);
              if (result != null) {
                setState(() {
                  selectedOrderType = result;
                });
              }
            },
            onOrderStatusTap: () async {
              final result = await OrderStatusSelector.show(context, currentSelection: selectedOrderStatus);
              if (result != null) {
                debugPrint("Result onOrderStatusTap: $result");
                setState(() {
                  selectedOrderStatus = result;
                });
              }
            },
          ),
          WAOrdersTable(orders: _listOrders),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 28.0, desktop: 32.0, widescreen: 36.0);

    return Text(
      'Orders',
      style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize, fontWeight: FontWeight.bold),
    );
  }
}

class WAOrdersTable extends StatelessWidget {
  const WAOrdersTable({super.key, required this.orders, this.height = 430, this.onDelete, this.onEdit});

  final double height;
  final List<WAOrder> orders;
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
    DataColumn2(label: Text('ID'), size: ColumnSize.S),
    DataColumn2(label: Text('Name'), size: ColumnSize.M),
    DataColumn2(label: Text('Address'), size: ColumnSize.M),
    DataColumn2(label: Text('Date'), size: ColumnSize.S),
    DataColumn2(label: Text('Time'), size: ColumnSize.S),
    DataColumn2(label: Text('Status'), size: ColumnSize.S),
  ];
}

List<DataRow> rows(BuildContext context, List<WAOrder> orders, Function? onDelete, Function? onEdit) {
  final theme = Theme.of(context);
  final avatarRadius = Responsive.value(context: context, mobile: 14.0, tablet: 20.0, desktop: 22.0, widescreen: 26.0);

  final nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

  final amountFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

  final dateFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 13.0, desktop: 14.0, widescreen: 15.0);
  return orders
      .map(
        (WAOrder order) => DataRow(
          cells: [
            // ID
            DataCell(
              Text(
                order.id,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: nameFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Name
            DataCell(
              Text(
                order.customer,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Address
            DataCell(
              Text(
                order.address,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Date
            DataCell(
              Text(
                order.date.toIso8601String(),
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Date
            DataCell(
              Text(
                order.date.toIso8601String(),
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Status
            DataCell(StatusChip.orderStatus(order.status.name)),
          ],
        ),
      )
      .toList();
}

List<WAOrder> _listOrders = [
  WAOrder(
    id: '1232312',
    customer: 'Danis',
    email: 'danis.preldzic@gmail.com',
    phone: '062748065',
    status: StatusChipType.pending,
    address: 'Behdzeta Mutevelica 115',
    items: [
      OrderItem(name: 'Crvi', price: 45, quantity: 23),
      OrderItem(name: 'Hrana za macke', price: 25, quantity: 10),
      OrderItem(name: 'Voda za macke', price: 2, quantity: 1),
    ],
    total: 72,
    date: DateTime.now(),
  ),
];
