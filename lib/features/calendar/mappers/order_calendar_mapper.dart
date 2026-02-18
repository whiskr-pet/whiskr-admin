import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';

import '../calendar_constants.dart';
import '../models/calendar_entry.dart';
import '../models/calendar_status_option.dart';

class OrderCalendarMapper {
  const OrderCalendarMapper._();

  static CalendarEntry toEntry(ServiceOrderModel order) {
    final DateTime start = _resolveStart(order);
    final DateTime end = start.add(kDefaultOrderDuration);
    final String customerName = [
      order.user?.firstName ?? '',
      order.user?.lastName ?? '',
    ].join(' ').trim();

    return CalendarEntry(
      id: order.id ?? '',
      title: (order.orderNumber?.isNotEmpty ?? false)
          ? 'Order #${order.orderNumber}'
          : 'Order',
      start: start,
      end: end,
      statusKey: CalendarStatusResolver.normalizeOrderStatus(order.status),
      subtitle: customerName.isNotEmpty ? customerName : null,
      sourceType: CalendarEntrySourceType.order,
      metadata: <String, dynamic>{
        'source': order,
        'customerName': customerName,
        'serviceType': order.orderType?.name,
        'scheduleType': order.scheduleType?.name,
        'status': order.status,
        'note': order.note,
      },
    );
  }

  static DateTime _resolveStart(ServiceOrderModel order) {
    final String? deliveryDate = order.deliveryDate;
    if (deliveryDate != null && deliveryDate.isNotEmpty) {
      final DateTime? parsed = DateTime.tryParse(deliveryDate);
      if (parsed != null) {
        return parsed;
      }
    }

    final String? createdAt = order.createdAt;
    if (createdAt != null && createdAt.isNotEmpty) {
      final DateTime? parsed = DateTime.tryParse(createdAt);
      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }
}
