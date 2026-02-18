import 'package:flutter/material.dart';

import '../models/calendar_entry.dart';
import '../models/calendar_status_option.dart';

class CalendarEntryFormData {
  const CalendarEntryFormData({
    required this.title,
    required this.subtitle,
    required this.statusKey,
    required this.start,
    required this.end,
  });

  final String title;
  final String subtitle;
  final String statusKey;
  final DateTime start;
  final DateTime end;
}

class CalendarEntryFormDialog extends StatefulWidget {
  const CalendarEntryFormDialog({
    super.key,
    this.initial,
    required this.statusOptions,
  });

  final CalendarEntry? initial;
  final List<CalendarStatusOption> statusOptions;

  static Future<CalendarEntryFormData?> show(
    BuildContext context, {
    CalendarEntry? initial,
    required List<CalendarStatusOption> statusOptions,
  }) {
    return showDialog<CalendarEntryFormData>(
      context: context,
      builder: (BuildContext context) {
        return CalendarEntryFormDialog(
          initial: initial,
          statusOptions: statusOptions,
        );
      },
    );
  }

  @override
  State<CalendarEntryFormDialog> createState() =>
      _CalendarEntryFormDialogState();
}

class _CalendarEntryFormDialogState extends State<CalendarEntryFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late DateTime _start;
  late DateTime _end;
  late String _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.initial?.subtitle ?? '',
    );
    _start = widget.initial?.start ?? DateTime.now();
    _end = widget.initial?.end ?? DateTime.now().add(const Duration(hours: 1));
    _status =
        widget.initial?.statusKey ??
        (widget.statusOptions.isNotEmpty
            ? widget.statusOptions.first.key
            : 'pending');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'New event' : 'Edit event'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Customer/Pet'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: widget.statusOptions
                  .map(
                    (CalendarStatusOption status) => DropdownMenuItem<String>(
                      value: status.key,
                      child: Text(status.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'Start',
              value: _start,
              onChanged: (DateTime value) => setState(() => _start = value),
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'End',
              value: _end,
              onChanged: (DateTime value) => setState(() => _end = value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              CalendarEntryFormData(
                title: _titleController.text.trim(),
                subtitle: _subtitleController.text.trim(),
                statusKey: _status,
                start: _start,
                end: _end,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );

        if (date == null || !context.mounted) {
          return;
        }

        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time == null) {
          return;
        }

        onChanged(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}
