import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/calendar_entry.dart';

class CalendarEntriesDataSource extends CalendarDataSource {
  CalendarEntriesDataSource({
    required List<CalendarEntry> entries,
    required Color Function(String statusKey) colorForStatus,
  }) {
    appointments = entries
        .map(
          (CalendarEntry entry) => Appointment(
            id: entry.id,
            startTime: entry.start,
            endTime: entry.end,
            subject: entry.title,
            notes: entry.subtitle,
            color: colorForStatus(entry.statusKey),
          ),
        )
        .toList(growable: false);

    _entryById = <String, CalendarEntry>{
      for (final CalendarEntry entry in entries) entry.id: entry,
    };
  }

  late final Map<String, CalendarEntry> _entryById;

  CalendarEntry? entryFromAppointment(Object? appointment) {
    if (appointment is Appointment) {
      final String? id = appointment.id?.toString();
      if (id != null) {
        return _entryById[id];
      }
    }
    return null;
  }
}
