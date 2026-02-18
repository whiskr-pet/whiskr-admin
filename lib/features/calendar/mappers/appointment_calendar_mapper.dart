import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';

import '../calendar_constants.dart';
import '../models/calendar_entry.dart';
import '../models/calendar_status_option.dart';

class AppointmentCalendarMapper {
  const AppointmentCalendarMapper._();

  static CalendarEntry toEntry(WaAppointmentsModel appointment) {
    final DateTime start = _resolveStart(appointment);
    final DateTime end = start.add(kDefaultOrderDuration);

    return CalendarEntry(
      id: appointment.id ?? '',
      title: (appointment.appointmentNumber?.isNotEmpty ?? false)
          ? 'Appointment #${appointment.appointmentNumber}'
          : 'Appointment',
      start: start,
      end: end,
      statusKey: CalendarStatusResolver.normalizeAppointmentStatus(
        appointment.status,
      ),
      subtitle: appointment.customer,
      sourceType: CalendarEntrySourceType.appointment,
      metadata: <String, dynamic>{
        'source': appointment,
        'customerName': appointment.customer,
        'petId': appointment.petId,
        'serviceType': appointment.items.isNotEmpty
            ? appointment.items.first.name
            : null,
        'status': appointment.status,
        'note': appointment.note,
      },
    );
  }

  static DateTime _resolveStart(WaAppointmentsModel appointment) {
    if (appointment.date == null) {
      return appointment.createdAt ?? DateTime.now();
    }

    final DateTime base = appointment.date!;
    final String? time = appointment.time;
    if (time == null || time.isEmpty) {
      return base;
    }

    final List<String> pieces = time.split(':');
    final int hour = int.tryParse(pieces.first) ?? 9;
    final int minute = pieces.length > 1 ? (int.tryParse(pieces[1]) ?? 0) : 0;

    return DateTime(base.year, base.month, base.day, hour, minute);
  }
}
