import 'package:flutter/material.dart';

import '../models/calendar_view_type.dart';

class CalendarToolbar extends StatelessWidget {
  const CalendarToolbar({
    super.key,
    required this.periodLabel,
    required this.currentView,
    required this.onToday,
    required this.onPrevious,
    required this.onNext,
    required this.onViewChanged,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.onCreate,
  });

  final String periodLabel;
  final CalendarViewType currentView;
  final VoidCallback onToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<CalendarViewType> onViewChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilledButton.tonal(onPressed: onToday, child: const Text('Today')),
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous',
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next',
            ),
            Text(
              periodLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            ToggleButtons(
              isSelected: CalendarViewType.values
                  .map((CalendarViewType e) => e == currentView)
                  .toList(growable: false),
              onPressed: (int index) =>
                  onViewChanged(CalendarViewType.values[index]),
              borderRadius: BorderRadius.circular(10),
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Month'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Week'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Day'),
                ),
              ],
            ),
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search customer/pet',
                ),
                onChanged: onSearchChanged,
              ),
            ),
            OutlinedButton.icon(
              onPressed: onOpenFilters,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters'),
            ),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ],
        ),
      ),
    );
  }
}
