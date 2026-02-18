import 'package:flutter_test/flutter_test.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:whiskr_admin_panel/features/calendar/models/calendar_status_option.dart';

void main() {
  group('CalendarStatusResolver', () {
    test('normalizes appointment backend chip status to app status', () {
      expect(
        CalendarStatusResolver.normalizeAppointmentStatus('pending'),
        AppointmentStatusType.scheduled.name,
      );
      expect(
        CalendarStatusResolver.normalizeAppointmentStatus('processing'),
        AppointmentStatusType.inProgress.name,
      );
    });

    test('maps appointment app status to backend chip status', () {
      expect(
        CalendarStatusResolver.toAppointmentBackendStatus(
          AppointmentStatusType.inProgress.name,
        ),
        StatusChipType.processing,
      );
      expect(
        CalendarStatusResolver.toAppointmentBackendStatus(
          AppointmentStatusType.completed.name,
        ),
        StatusChipType.delivered,
      );
    });
  });
}
