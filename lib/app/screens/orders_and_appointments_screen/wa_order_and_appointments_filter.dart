import 'package:flutter/material.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';

enum OrderType { delivery, pickup }

/// A reusable filter widget for orders and appointments
/// Provides filtering by Date, Order Type, and Order Status with a reset option
class WAOrdersAppointmentFilter extends StatelessWidget {
  final String? selectedDate;
  final String? selectedOrderType;
  final String? selectedOrderStatus;
  final VoidCallback onResetFilter;
  final VoidCallback onDateTap;
  final VoidCallback onOrderTypeTap;
  final VoidCallback onOrderStatusTap;

  const WAOrdersAppointmentFilter({
    super.key,
    this.selectedDate,
    this.selectedOrderType,
    this.selectedOrderStatus,
    required this.onResetFilter,
    required this.onDateTap,
    required this.onOrderTypeTap,
    required this.onOrderStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterIcon(),
          _buildDivider(),
          _buildFilterOption(
            label: 'Date',
            value: selectedDate,
            onTap: onDateTap,
          ),
          _buildDivider(),
          _buildFilterOption(
            label: 'Order Type',
            value: selectedOrderType,
            onTap: onOrderTypeTap,
          ),
          _buildDivider(),
          _buildFilterOption(
            label: 'Order Status',
            value: selectedOrderStatus,
            onTap: onOrderStatusTap,
          ),
          _buildDivider(),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildFilterIcon() {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list, size: 24, color: Colors.grey[800]),
          const SizedBox(width: 8),
          Text(
            'Filter By',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFE5E7EB));
  }

  Widget _buildFilterOption({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value ?? label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: value != null ? Colors.grey[800] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onResetFilter,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 20, color: Colors.orange[700]),
            const SizedBox(width: 6),
            Text(
              'Reset Filter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date Range Selector Bottom Sheet
class DateRangeSelector extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTimeRange?) onSelected;

  const DateRangeSelector({
    super.key,
    this.selectedRange,
    required this.onSelected,
  });

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? currentSelection,
  }) async {
    return await showModalBottomSheet<DateTimeRange?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DateRangeSelector(
        selectedRange: currentSelection,
        onSelected: (range) => Navigator.pop(context, range),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.greenWeb.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Date Range',
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorHelper.white.color,
                ),
              ),
              if (selectedRange != null)
                TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: ColorHelper.white.color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPresetOption('Today', Icons.today, () {
            final now = DateTime.now();
            onSelected(
              DateTimeRange(
                start: DateTime(now.year, now.month, now.day),
                end: DateTime(now.year, now.month, now.day, 23, 59, 59),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildPresetOption('Last 7 Days', Icons.date_range, () {
            final now = DateTime.now();
            onSelected(
              DateTimeRange(
                start: DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(const Duration(days: 6)),
                end: DateTime(now.year, now.month, now.day, 23, 59, 59),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildPresetOption('Last 30 Days', Icons.calendar_month, () {
            final now = DateTime.now();
            onSelected(
              DateTimeRange(
                start: DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(const Duration(days: 29)),
                end: DateTime(now.year, now.month, now.day, 23, 59, 59),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildPresetOption('This Month', Icons.calendar_today, () {
            final now = DateTime.now();
            onSelected(
              DateTimeRange(
                start: DateTime(now.year, now.month, 1),
                end: DateTime(now.year, now.month, now.day, 23, 59, 59),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildCustomDateOption(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPresetOption(String label, IconData icon, VoidCallback onTap) {
    final isSelected = _isPresetSelected(label);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? ColorHelper.orange500.color
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? ColorHelper.orange500.color.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ColorHelper.orange700.color
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? ColorHelper.orange700.color
                    : Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ColorHelper.orange700.color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDateOption(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTimeRange<DateTime>? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: selectedRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorHelper.orange500.color,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.grey[800]!,
                  primaryContainer: ColorHelper.greenWeb.color,
                  onPrimaryContainer: Colors.white,
                  secondary: ColorHelper.orange300.color,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedRange != null && !_isPresetSelected('')
                ? ColorHelper.orange500.color
                : const Color(0xFFE5E7EB),
            width: selectedRange != null && !_isPresetSelected('') ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedRange != null && !_isPresetSelected('')
              ? Colors.orange.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_calendar,
              color: selectedRange != null && !_isPresetSelected('')
                  ? ColorHelper.orange700.color
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Custom Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: selectedRange != null && !_isPresetSelected('')
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: selectedRange != null && !_isPresetSelected('')
                    ? ColorHelper.orange700.color
                    : Colors.grey[800],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  bool _isPresetSelected(String preset) {
    if (selectedRange == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case 'Today':
        return selectedRange!.start.isAtSameMomentAs(today) &&
            selectedRange!.end.day == today.day;
      case 'Last 7 Days':
        return selectedRange!.start.isAtSameMomentAs(
          today.subtract(const Duration(days: 6)),
        );
      case 'Last 30 Days':
        return selectedRange!.start.isAtSameMomentAs(
          today.subtract(const Duration(days: 29)),
        );
      case 'This Month':
        return selectedRange!.start.isAtSameMomentAs(
          DateTime(now.year, now.month, 1),
        );
      default:
        return false;
    }
  }
}

/// Order Type Selector Bottom Sheet
class OrderTypeSelector extends StatelessWidget {
  final OrderType? selectedType;
  final Function(OrderType?) onSelected;

  const OrderTypeSelector({
    super.key,
    this.selectedType,
    required this.onSelected,
  });

  static Future<OrderType?> show(
    BuildContext context, {
    OrderType? currentSelection,
  }) async {
    return await showModalBottomSheet<OrderType?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderTypeSelector(
        selectedType: currentSelection,
        onSelected: (type) => Navigator.pop(context, type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.greenWeb.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Order Type',
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorHelper.white.color,
                ),
              ),
              if (selectedType != null)
                TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: ColorHelper.white.color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOrderTypeOption(
            OrderType.delivery,
            'Delivery',
            Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 12),
          _buildOrderTypeOption(
            OrderType.pickup,
            'Pickup',
            Icons.store_outlined,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderTypeOption(OrderType type, String label, IconData icon) {
    final isSelected = selectedType == type;
    return InkWell(
      onTap: () => onSelected(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange[700] : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.orange[700] : Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.orange[700], size: 24),
          ],
        ),
      ),
    );
  }
}

/// Order Status Selector Bottom Sheet
class OrderStatusSelector extends StatelessWidget {
  final StatusChipType? selectedStatus;
  final Function(StatusChipType?) onSelected;

  const OrderStatusSelector({
    super.key,
    this.selectedStatus,
    required this.onSelected,
  });

  static Future<StatusChipType?> show(
    BuildContext context, {
    StatusChipType? currentSelection,
  }) async {
    return await showModalBottomSheet<StatusChipType?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderStatusSelector(
        selectedStatus: currentSelection,
        onSelected: (status) => Navigator.pop(context, status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.greenWeb.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Order Status',
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorHelper.white.color,
                ),
              ),
              if (selectedStatus != null)
                TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: ColorHelper.white.color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStatusOption(
            StatusChipType.pending,
            'Pending',
            Icons.schedule,
            const Color(0xFFFFA500),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            StatusChipType.confirmed,
            'Confirmed',
            Icons.check_circle,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            StatusChipType.processing,
            'Processing',
            Icons.build,
            const Color(0xFF9333EA),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            StatusChipType.shipped,
            'Shipped',
            Icons.local_shipping,
            const Color(0xFFEC4899),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            StatusChipType.delivered,
            'Delivered',
            Icons.done_all,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            StatusChipType.cancelled,
            'Cancelled',
            Icons.cancel,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    StatusChipType status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedStatus == status;
    return InkWell(
      onTap: () => onSelected(status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
