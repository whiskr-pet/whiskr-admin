import 'package:flutter/material.dart';

import '../models/calendar_filters.dart';
import '../models/calendar_status_option.dart';

class CalendarFiltersPanel extends StatelessWidget {
  const CalendarFiltersPanel({
    super.key,
    required this.filters,
    required this.statusOptions,
    required this.serviceTypes,
    required this.resources,
    required this.onToggleStatus,
    required this.onToggleServiceType,
    required this.onToggleResource,
    required this.onApplyQuickRange,
    required this.onClear,
  });

  final CalendarFilters filters;
  final List<CalendarStatusOption> statusOptions;
  final Set<String> serviceTypes;
  final Set<String> resources;
  final ValueChanged<String> onToggleStatus;
  final ValueChanged<String> onToggleServiceType;
  final ValueChanged<String> onToggleResource;
  final ValueChanged<CalendarQuickRange> onApplyQuickRange;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Drawer(
      width: 360,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(onPressed: onClear, child: const Text('Clear')),
                ],
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: 'Quick range',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ChoiceChip(
                      label: const Text('Today'),
                      selected: filters.quickRange == CalendarQuickRange.today,
                      onSelected: (_) =>
                          onApplyQuickRange(CalendarQuickRange.today),
                    ),
                    ChoiceChip(
                      label: const Text('This week'),
                      selected:
                          filters.quickRange == CalendarQuickRange.thisWeek,
                      onSelected: (_) =>
                          onApplyQuickRange(CalendarQuickRange.thisWeek),
                    ),
                    ChoiceChip(
                      label: const Text('This month'),
                      selected:
                          filters.quickRange == CalendarQuickRange.thisMonth,
                      onSelected: (_) =>
                          onApplyQuickRange(CalendarQuickRange.thisMonth),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FilterSection(
                title: 'Status',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: statusOptions
                      .map(
                        (CalendarStatusOption status) => FilterChip(
                          label: Text(status.label),
                          selected: filters.statusKeys.contains(status.key),
                          onSelected: (_) => onToggleStatus(status.key),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              if (serviceTypes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _FilterSection(
                  title: 'Service type',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: serviceTypes
                        .map(
                          (String type) => FilterChip(
                            label: Text(type),
                            selected: filters.serviceTypes.contains(type),
                            onSelected: (_) => onToggleServiceType(type),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
              if (resources.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _FilterSection(
                  title: 'Staff/resource',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: resources
                        .map(
                          (String resource) => FilterChip(
                            label: Text(resource),
                            selected: filters.staffResources.contains(resource),
                            onSelected: (_) => onToggleResource(resource),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
