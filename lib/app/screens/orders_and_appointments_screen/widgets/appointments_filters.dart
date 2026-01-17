import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_search_module/w_search_module.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_provider.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_search_provider.dart';

class AppointmentsFiltersWidget extends StatefulWidget {
  const AppointmentsFiltersWidget({super.key});

  @override
  State<AppointmentsFiltersWidget> createState() => _AppointmentsFiltersWidgetState();
}

class _AppointmentsFiltersWidgetState extends State<AppointmentsFiltersWidget> with SingleTickerProviderStateMixin {
  AppointmentStatusType? _selectedStatus;
  String? _selectedSortBy;
  SortOrder? _selectedSortOrder;
  bool _showAdvancedFilters = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<String> _sortOptions = ['created_at', 'updated_at', 'date', 'total', 'time', 'status'];

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
    final WaAppointmentsProvider appointmentsProvider = context.read<WaAppointmentsProvider>();
    appointmentsProvider.setSearchMode(true);
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedSortBy = null;
      _selectedSortOrder = null;
    });

    final WaAppointmentsSearchProvider searchProvider = context.read<WaAppointmentsSearchProvider>();
    final WaAppointmentsProvider appointmentsProvider = context.read<WaAppointmentsProvider>();
    searchProvider.clearAllFilters();
    appointmentsProvider.setSearchMode(false);
  }

  void _applyStatusFilter(AppointmentStatusType? status) async {
    setState(() {
      _selectedStatus = status;
    });

    _enableSearchMode();
    final WaAppointmentsSearchProvider searchProvider = context.read<WaAppointmentsSearchProvider>();

    if (status != null) {
      // Convert AppointmentStatusType to StatusChipType using extension method
      final StatusChipType chipType = status.toStatusChipType();
      await searchProvider.filterByStatus(chipType.name);
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
    final WaAppointmentsSearchProvider searchProvider = context.read<WaAppointmentsSearchProvider>();
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
      case 'date':
        return 'Appointment Date';
      case 'total':
        return 'Total Price';
      case 'time':
        return 'Appointment Time';
      case 'status':
        return 'Status';
      default:
        return sortBy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final bool hasActiveFilters = _selectedStatus != null || _selectedSortBy != null;

    return Container(
      padding: EdgeInsets.all(Responsive.value(context: context, mobile: 12.0, tablet: 16.0, desktop: 16.0, widescreen: 20.0)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22), width: 1),
        boxShadow: <BoxShadow>[BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              if (hasActiveFilters)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${_getActiveFilterCount()}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.primary),
                  ),
                ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear_rounded, size: 16, color: colorScheme.error),
                  label: Text(
                    'Clear All',
                    style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w500, fontSize: 13),
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

          // Appointment Status Filter Chips
          _SectionLabel(icon: Icons.event_note_rounded, label: 'Appointment Status'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Scheduled',
                isSelected: _selectedStatus == AppointmentStatusType.scheduled,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? AppointmentStatusType.scheduled : null);
                },
                icon: Icons.calendar_today_rounded,
              ),
              _FilterChip(
                label: 'Confirmed',
                isSelected: _selectedStatus == AppointmentStatusType.confirmed,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? AppointmentStatusType.confirmed : null);
                },
                icon: Icons.check_circle_outline_rounded,
              ),
              _FilterChip(
                label: 'In Progress',
                isSelected: _selectedStatus == AppointmentStatusType.inProgress,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? AppointmentStatusType.inProgress : null);
                },
                icon: Icons.hourglass_bottom_rounded,
              ),
              _FilterChip(
                label: 'Completed',
                isSelected: _selectedStatus == AppointmentStatusType.completed,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? AppointmentStatusType.completed : null);
                },
                icon: Icons.done_all_rounded,
              ),
              _FilterChip(
                label: 'Cancelled',
                isSelected: _selectedStatus == AppointmentStatusType.cancelled,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? AppointmentStatusType.cancelled : null);
                },
                icon: Icons.cancel_outlined,
              ),
              _FilterChip(
                label: 'No Show',
                isSelected: _selectedStatus == AppointmentStatusType.noShow,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? AppointmentStatusType.noShow : null);
                },
                icon: Icons.person_off_outlined,
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _showAdvancedFilters ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: colorScheme.primary),
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
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.60), width: 1),
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
                        child: Icon(Icons.arrow_drop_down_rounded, color: colorScheme.primary),
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
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? colorScheme.onPrimary : colorScheme.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
      checkmarkColor: colorScheme.onPrimary,
      labelStyle: TextStyle(color: isSelected ? colorScheme.onPrimary : colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.35), width: 1.5),
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
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
