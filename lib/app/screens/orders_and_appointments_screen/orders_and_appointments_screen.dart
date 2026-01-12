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
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_search_provider.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/order_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/orders_filters.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/schedule_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/status_update_popup_widget.dart';

import '../../helpers/loading_animation_helper.dart';

class OrdersAndAppointmentsScreen extends StatefulWidget {
  const OrdersAndAppointmentsScreen({super.key});

  @override
  State<OrdersAndAppointmentsScreen> createState() => _OrdersAndAppointmentsScreenState();
}

class _OrdersAndAppointmentsScreenState extends State<OrdersAndAppointmentsScreen> {
  late WaOrdersSearchProvider searchProvider;
  bool? _isTypeShop;

  @override
  void initState() {
    searchProvider = WaOrdersSearchProvider();
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
    provider.setSearchMode(false);
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

    return MultiProvider(
      providers: [ChangeNotifierProvider<WaOrdersSearchProvider>.value(value: searchProvider)],
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
          const OrdersFiltersWidget(),
          const SizedBox(height: 40),
          Consumer2<WaOrdersProvider, WaOrdersSearchProvider>(
            builder: (context, ordersProvider, searchProvider, child) {
              if (ordersProvider.isLoading || searchProvider.isLoading) {
                return LoadingAnimationHelper.loading;
              }

              final orders = ordersProvider.isSearchMode ? searchProvider.items : ordersProvider.ordersList;

              return WAOrdersTable(orders: orders);
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

class _BuildPaginationControls extends StatelessWidget {
  const _BuildPaginationControls();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    // final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    return Consumer2<WaOrdersSearchProvider, WaOrdersProvider>(
      builder: (context, searchProvider, ordersProvider, child) {
        final bool isSearchMode = ordersProvider.isSearchMode;

        final int currentPage = isSearchMode ? searchProvider.currentPage : ordersProvider.currentPage;
        final int totalPages = isSearchMode ? searchProvider.totalPages : ordersProvider.totalPages;
        final bool hasPrevious = isSearchMode ? searchProvider.hasPreviousPage : ordersProvider.hasPreviousPage;
        final bool hasNext = isSearchMode ? searchProvider.hasNextPage : ordersProvider.hasNextPage;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: Responsive.value(context: context, mobile: 0.0, tablet: 0.0, desktop: 0.0, widescreen: 0.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
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
                          if (isSearchMode) {
                            searchProvider.previousPage();
                          } else {
                            ordersProvider.loadPreviousPage();
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
                    color: ColorHelper.green300.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorHelper.greenWeb.color.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Page',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 15.0),
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: ColorHelper.greenWeb.color, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '$currentPage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 16.0),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'of',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 15.0),
                          color: Colors.grey[600],
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
                          if (isSearchMode) {
                            searchProvider.nextPage();
                          } else {
                            ordersProvider.loadNextPage();
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
                      ? LinearGradient(
                          colors: [ColorHelper.greenWeb.color, ColorHelper.greenWeb.color.withValues(alpha: 0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [ColorHelper.greenWeb.color.withValues(alpha: 0.1), ColorHelper.greenWeb.color.withValues(alpha: 0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ))
                : null,
            color: widget.isEnabled ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isEnabled ? (_isHovered ? ColorHelper.greenWeb.color : ColorHelper.greenWeb.color.withValues(alpha: 0.3)) : Colors.grey[300]!,
              width: _isHovered && widget.isEnabled ? 2 : 1.5,
            ),
            boxShadow: _isHovered && widget.isEnabled ? [BoxShadow(color: ColorHelper.greenWeb.color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.isNext && widget.label != null)
                Icon(widget.icon, size: 20, color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400]),
              if (widget.label != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400],
                  ),
                ),
              ],
              if (widget.label == null) Icon(widget.icon, size: 24, color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400]),
              if (widget.isNext && widget.label != null)
                Icon(widget.icon, size: 20, color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
