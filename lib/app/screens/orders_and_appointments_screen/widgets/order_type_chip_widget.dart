import 'package:flutter/material.dart';
import 'package:w_pet_service_module/providers/cart_provider.dart';

class OrderTypeChipWidget extends StatelessWidget {
  const OrderTypeChipWidget({super.key, required this.orderType});

  final String orderType;

  OrderType? _parseOrderType(String type) {
    try {
      return OrderType.values.firstWhere((e) => e.name.toLowerCase() == type.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderType = _parseOrderType(this.orderType);
    final isQuick = orderType == OrderType.quick;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isQuick ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
        border: Border.all(color: isQuick ? const Color(0xFFFF9800) : const Color(0xFF2196F3), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isQuick ? Icons.bolt : Icons.schedule, color: isQuick ? const Color(0xFFFF9800) : const Color(0xFF2196F3), size: 14),
          const SizedBox(width: 5),
          Text(
            this.orderType.toUpperCase(),
            style: TextStyle(color: isQuick ? const Color(0xFFE65100) : const Color(0xFF1565C0), fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
