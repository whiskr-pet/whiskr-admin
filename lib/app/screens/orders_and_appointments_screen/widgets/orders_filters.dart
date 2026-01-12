import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_search_module/w_search_module.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_search_provider.dart';

class OrdersFiltersWidget extends StatefulWidget {
  const OrdersFiltersWidget({super.key});

  @override
  State<OrdersFiltersWidget> createState() => _OrdersFiltersWidgetState();
}

class _OrdersFiltersWidgetState extends State<OrdersFiltersWidget> with SingleTickerProviderStateMixin {
  String? _selectedStatus;
  String? _selectedSortBy;
  SortOrder? _selectedSortOrder;
  bool _showAdvancedFilters = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<String> _sortOptions = ['created_at', 'updated_at', 'delivery_date', 'total_price', 'order_number'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _enableSearchMode() {
    final WaOrdersProvider ordersProvider = context.read<WaOrdersProvider>();
    ordersProvider.setSearchMode(true);
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedSortBy = null;
      _selectedSortOrder = null;
    });

    final WaOrdersSearchProvider searchProvider = context.read<WaOrdersSearchProvider>();
    final WaOrdersProvider ordersProvider = context.read<WaOrdersProvider>();
    searchProvider.clearAllFilters();
    ordersProvider.setSearchMode(false);
  }

  void _applyStatusFilter(String? status) async {
    setState(() {
      _selectedStatus = status;
    });

    _enableSearchMode();
    final WaOrdersSearchProvider searchProvider = context.read<WaOrdersSearchProvider>();

    if (status != null) {
      await searchProvider.filterByStatus(status);
    } else {
      searchProvider.removeCustomFilter('status');
      await searchProvider.refresh();
    }
  }

  void _applySorting(String? sortBy, SortOrder? order) async {
    setState(() {
      _selectedSortBy = sortBy;
      _selectedSortOrder = order;
    });

    _enableSearchMode();
    final WaOrdersSearchProvider searchProvider = context.read<WaOrdersSearchProvider>();
    await searchProvider.setSorting(sortBy, order);
  }

  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });
    if (_showAdvancedFilters) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  String _getSortDisplayName(String sortBy) {
    switch (sortBy) {
      case 'created_at':
        return 'Date Created';
      case 'updated_at':
        return 'Last Updated';
      case 'delivery_date':
        return 'Delivery Date';
      case 'total_price':
        return 'Total Price';
      case 'order_number':
        return 'Order Number';
      default:
        return sortBy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _selectedStatus != null || _selectedSortBy != null;

    return Container(
      padding: EdgeInsets.all(Responsive.value(context: context, mobile: 12.0, tablet: 16.0, desktop: 16.0, widescreen: 20.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorHelper.greenWeb.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 20, color: ColorHelper.greenWeb.color),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              if (hasActiveFilters)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${_getActiveFilterCount()}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorHelper.greenWeb.color),
                  ),
                ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear_rounded, size: 16, color: Colors.red[400]),
                  label: Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Order Status Filter Chips
          _SectionLabel(icon: Icons.receipt_long_rounded, label: 'Order Status'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Pending',
                isSelected: _selectedStatus == StatusChipType.pending.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? StatusChipType.pending.name : null);
                },
                icon: Icons.schedule_rounded,
              ),
              _FilterChip(
                label: 'Confirmed',
                isSelected: _selectedStatus == StatusChipType.confirmed.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? StatusChipType.confirmed.name : null);
                },
                icon: Icons.check_circle_outline_rounded,
              ),
              _FilterChip(
                label: 'Cancelled',
                isSelected: _selectedStatus == StatusChipType.cancelled.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? StatusChipType.cancelled.name : null);
                },
                icon: Icons.cancel_outlined,
              ),
              _FilterChip(
                label: 'Delivered',
                isSelected: _selectedStatus == StatusChipType.delivered.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? StatusChipType.delivered.name : null);
                },
                icon: Icons.done_all_rounded,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Advanced Filters Toggle
          InkWell(
            onTap: _toggleAdvancedFilters,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Advanced Filters',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ColorHelper.greenWeb.color),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _showAdvancedFilters ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ColorHelper.greenWeb.color),
                  ),
                ],
              ),
            ),
          ),

          // Advanced Filters Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Sorting Options
                _SectionLabel(icon: Icons.sort_rounded, label: 'Sort By'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSortBy,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Select sort option', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      ),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_drop_down_rounded, color: ColorHelper.greenWeb.color),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Default', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        ..._sortOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(_getSortDisplayName(option), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          );
                        }),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue == null) {
                          _applySorting(null, null);
                        } else {
                          _applySorting(newValue, _selectedSortOrder ?? SortOrder.asc);
                        }
                      },
                    ),
                  ),
                ),

                if (_selectedSortBy != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterChip(
                          label: 'Ascending',
                          isSelected: _selectedSortOrder == SortOrder.asc,
                          onSelected: (bool selected) {
                            _applySorting(_selectedSortBy, selected ? SortOrder.asc : SortOrder.desc);
                          },
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterChip(
                          label: 'Descending',
                          isSelected: _selectedSortOrder == SortOrder.desc,
                          onSelected: (bool selected) {
                            _applySorting(_selectedSortBy, selected ? SortOrder.desc : SortOrder.asc);
                          },
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedStatus != null) count++;
    if (_selectedSortBy != null) count++;
    return count;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final IconData icon;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : ColorHelper.greenWeb.color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: ColorHelper.greenWeb.color,
      backgroundColor: ColorHelper.greenWeb.color.withValues(alpha: 0.1),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : ColorHelper.greenWeb.color, fontWeight: FontWeight.w500, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? ColorHelper.greenWeb.color : ColorHelper.greenWeb.color.withValues(alpha: 0.3), width: 1.5),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
