import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/wa_order_item.dart';

extension StatusChipTypeJson on StatusChipType {
  static StatusChipType fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return StatusChipType.pending;
      case 'confirmed':
        return StatusChipType.confirmed;
      case 'processing':
        return StatusChipType.processing;
      case 'shipped':
        return StatusChipType.shipped;
      case 'delivered':
        return StatusChipType.delivered;
      case 'cancelled':
      case 'declined':
        return StatusChipType.cancelled;
      default:
        throw ArgumentError('Invalid order status: $status');
    }
  }
}

class WAOrder {
  final String id;
  final String customer;
  final String email;
  final String phone;
  final StatusChipType status;
  final String address;
  final List<OrderItem> items;
  final double total;
  final DateTime date;

  WAOrder({
    required this.id,
    required this.customer,
    required this.email,
    required this.phone,
    required this.status,
    required this.address,
    required this.items,
    required this.total,
    required this.date,
  });

  factory WAOrder.fromJson(Map<String, dynamic> json) {
    return WAOrder(
      id: json['id'] as String,
      customer: json['customer'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      status: StatusChipTypeJson.fromString(json['status'] as String),
      address: json['address'] as String,
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList(),
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'email': email,
      'phone': phone,
      'status': status.name,
      'address': address,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'date': date.toIso8601String(),
    };
  }

  WAOrder copyWith({String? customer, String? email, String? phone, StatusChipType? status, String? address, List<OrderItem>? items, double? total, DateTime? date}) {
    return WAOrder(
      id: id,
      customer: customer ?? this.customer,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      address: address ?? this.address,
      items: items ?? this.items,
      total: total ?? this.total,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Order(customer: $customer, email: $email, status: ${status.name}, total: $total, date: $date)';
  }
}
