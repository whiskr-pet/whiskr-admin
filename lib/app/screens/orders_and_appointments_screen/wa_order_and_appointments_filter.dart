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
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.50)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterIcon(context),
          _buildDivider(context),
          _buildFilterOption(
            context: context,
            label: 'Date',
            value: selectedDate,
            onTap: onDateTap,
          ),
          _buildDivider(context),
          _buildFilterOption(
            context: context,
            label: 'Order Type',
            value: selectedOrderType,
            onTap: onOrderTypeTap,
          ),
          _buildDivider(context),
          _buildFilterOption(
            context: context,
            label: 'Order Status',
            value: selectedOrderStatus,
            onTap: onOrderStatusTap,
          ),
          _buildDivider(context),
          _buildResetButton(context),
        ],
      ),
    );
  }

  Widget _buildFilterIcon(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list, size: 24, color: colorScheme.onSurface),
          const SizedBox(width: 8),
          Text(
            'Filter By',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Container(height: 40, width: 1, color: colorScheme.outline.withValues(alpha: 0.50));
  }

  Widget _buildFilterOption({
    required BuildContext context,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
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
                    color: value != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onResetFilter,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 20, color: colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              'Reset Filter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.secondary,
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
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                  color: colorScheme.onPrimary,
                ),
              ),
              if (selectedRange != null)
                TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPresetOption(context: context, label: 'Today', icon: Icons.today, onTap: () {
            final now = DateTime.now();
            onSelected(
              DateTimeRange(
                start: DateTime(now.year, now.month, now.day),
                end: DateTime(now.year, now.month, now.day, 23, 59, 59),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildPresetOption(context: context, label: 'Last 7 Days', icon: Icons.date_range, onTap: () {
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
          _buildPresetOption(context: context, label: 'Last 30 Days', icon: Icons.calendar_month, onTap: () {
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
          _buildPresetOption(context: context, label: 'This Month', icon: Icons.calendar_today, onTap: () {
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

  Widget _buildPresetOption({required BuildContext context, required String label, required IconData icon, required VoidCallback onTap}) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
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
                : colorScheme.outline.withValues(alpha: 0.50),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? ColorHelper.orange500.color.withValues(alpha: 0.08)
              : colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ColorHelper.orange700.color
                  : colorScheme.onSurfaceVariant,
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
                    : colorScheme.onSurface,
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
            final ThemeData themeData = Theme.of(context);
            final ColorScheme baseColorScheme = themeData.colorScheme;
            return Theme(
              data: themeData.copyWith(
                colorScheme: baseColorScheme.copyWith(
                  primary: ColorHelper.orange500.color,
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
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.50),
            width: selectedRange != null && !_isPresetSelected('') ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedRange != null && !_isPresetSelected('')
              ? ColorHelper.orange500.color.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              Icons.edit_calendar,
              color: selectedRange != null && !_isPresetSelected('')
                  ? ColorHelper.orange700.color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
    final ColorScheme colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                  color: colorScheme.onPrimary,
                ),
              ),
              if (selectedType != null)
                TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOrderTypeOption(
            context,
            OrderType.delivery,
            'Delivery',
            Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 12),
          _buildOrderTypeOption(
            context,
            OrderType.pickup,
            'Pickup',
            Icons.store_outlined,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderTypeOption(BuildContext context, OrderType type, String label, IconData icon) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
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
          color: isSelected ? colorScheme.secondary.withValues(alpha: 0.08) : colorScheme.surface,
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
    final ColorScheme colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                  color: colorScheme.onPrimary,
                ),
              ),
              if (selectedStatus != null)
                TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStatusOption(
            context,
            StatusChipType.pending,
            'Pending',
            Icons.schedule,
            const Color(0xFFFFA500),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            context,
            StatusChipType.confirmed,
            'Confirmed',
            Icons.check_circle,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            context,
            StatusChipType.processing,
            'Processing',
            Icons.build,
            const Color(0xFF9333EA),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            context,
            StatusChipType.shipped,
            'Shipped',
            Icons.local_shipping,
            const Color(0xFFEC4899),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            context,
            StatusChipType.delivered,
            'Delivered',
            Icons.done_all,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          _buildStatusOption(
            context,
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
    BuildContext context,
    StatusChipType status,
    String label,
    IconData icon,
    Color color,
  ) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
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
          color: isSelected ? color.withValues(alpha: 0.08) : colorScheme.surface,
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
