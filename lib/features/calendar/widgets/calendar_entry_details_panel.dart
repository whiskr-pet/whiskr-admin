import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/details_widget.dart';
import '../models/calendar_entry.dart';
import '../models/calendar_status_option.dart';

class CalendarEntryDetailsPanel extends StatelessWidget {
  const CalendarEntryDetailsPanel({
    super.key,
    required this.entry,
    required this.statusOptions,
    required this.statusLabelResolver,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenRelated,
    required this.onMarkStatus,
  });

  final CalendarEntry entry;
  final List<CalendarStatusOption> statusOptions;
  final String Function(String statusKey) statusLabelResolver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenRelated;
  final ValueChanged<String> onMarkStatus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat formatter = DateFormat('d MMM yyyy, HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DetailsHeader(
          title: entry.title,
          subtitle: Text(
            entry.subtitle ?? '-',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CalendarStatusPalette.colorForStatus(
                      context,
                      entry.statusKey,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(statusLabelResolver(entry.statusKey)),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  title: 'Time',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Start: ${formatter.format(entry.start)}'),
                      const SizedBox(height: 6),
                      Text('End: ${formatter.format(entry.end)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  title: 'Actions',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onOpenRelated,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open related'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  title: 'Mark status',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: statusOptions
                        .map(
                          (CalendarStatusOption status) => ChoiceChip(
                            label: Text(status.label),
                            selected: status.key == entry.statusKey,
                            onSelected: (_) => onMarkStatus(status.key),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
