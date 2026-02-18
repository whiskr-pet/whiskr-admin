import 'package:w_dashboard/helpers/status_chip_type.dart';

import 'calendar_entry.dart';

class CalendarStatusOption {
  const CalendarStatusOption({required this.key, required this.label});

  final String key;
  final String label;
}

class CalendarStatusResolver {
  const CalendarStatusResolver._();

  static List<CalendarStatusOption> optionsForSource(
    CalendarEntrySourceType sourceType,
  ) {
    if (sourceType == CalendarEntrySourceType.order) {
      return StatusChipType.values
          .map(
            (StatusChipType e) =>
                CalendarStatusOption(key: e.name, label: e.title),
          )
          .toList(growable: false);
    }

    return AppointmentStatusType.values
        .map(
          (AppointmentStatusType e) =>
              CalendarStatusOption(key: e.name, label: e.title),
        )
        .toList(growable: false);
  }

  static String normalizeOrderStatus(String? status) {
    if (status == null || status.isEmpty) {
      return StatusChipType.pending.name;
    }

    try {
      return StatusChipTypeExtension.fromString(status).name;
    } catch (_) {
      return StatusChipType.pending.name;
    }
  }

  static String normalizeAppointmentStatus(String? status) {
    if (status == null || status.isEmpty) {
      return AppointmentStatusType.scheduled.name;
    }

    try {
      return AppointmentStatusTypeExtension.fromBackendString(status).name;
    } catch (_) {
      return AppointmentStatusType.scheduled.name;
    }
  }

  static StatusChipType toOrderBackendStatus(String statusKey) {
    return StatusChipTypeExtension.fromString(statusKey);
  }

  static StatusChipType toAppointmentBackendStatus(String statusKey) {
    final AppointmentStatusType appointmentStatus =
        AppointmentStatusTypeExtension.fromString(statusKey);
    return appointmentStatus.toStatusChipType();
  }
}
