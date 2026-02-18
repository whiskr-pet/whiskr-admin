import 'package:flutter_test/flutter_test.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
import 'package:whiskr_admin_panel/features/calendar/mappers/appointment_calendar_mapper.dart';
import 'package:whiskr_admin_panel/features/calendar/mappers/order_calendar_mapper.dart';
import 'package:whiskr_admin_panel/features/calendar/models/calendar_entry.dart';

void main() {
  group('OrderCalendarMapper', () {
    test('maps order to calendar entry with 60m default duration', () {
      final ServiceOrderModel order = ServiceOrderModel(
        id: 'order-1',
        orderNumber: '1001',
        deliveryDate: '2026-02-01T10:30:00.000Z',
        status: 'pending',
      );

      final CalendarEntry result = OrderCalendarMapper.toEntry(order);

      expect(result.id, 'order-1');
      expect(result.sourceType, CalendarEntrySourceType.order);
      expect(result.statusKey, 'pending');
      expect(result.end.difference(result.start), const Duration(minutes: 60));
    });
  });

  group('AppointmentCalendarMapper', () {
    test('maps appointment date and time to calendar entry', () {
      final WaAppointmentsModel appointment = WaAppointmentsModel(
        id: 'appt-1',
        appointmentNumber: 'A-1',
        customer: 'Dana',
        status: 'confirmed',
        date: DateTime(2026, 2, 2),
        time: '14:45',
      );

      final CalendarEntry result = AppointmentCalendarMapper.toEntry(
        appointment,
      );

      expect(result.id, 'appt-1');
      expect(result.sourceType, CalendarEntrySourceType.appointment);
      expect(result.statusKey, 'confirmed');
      expect(result.start.hour, 14);
      expect(result.start.minute, 45);
    });
  });
}
