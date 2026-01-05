import 'package:flutter/material.dart';
import 'package:w_pet_service_module/providers/cart_provider.dart';

class ScheduleTypeChipWidget extends StatelessWidget {
  const ScheduleTypeChipWidget({super.key, required this.scheduleType});

  final String scheduleType;

  ScheduleType? _parseScheduleType(String type) {
    try {
      return ScheduleType.values.firstWhere((e) => e.name.toLowerCase() == type.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleType = _parseScheduleType(this.scheduleType);
    final isDelivery = scheduleType == ScheduleType.delivery;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDelivery ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
        border: Border.all(color: isDelivery ? const Color(0xFF4CAF50) : const Color(0xFFE91E63), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDelivery ? Icons.local_shipping : Icons.store, color: isDelivery ? const Color(0xFF4CAF50) : const Color(0xFFE91E63), size: 14),
          const SizedBox(width: 5),
          Text(
            this.scheduleType.toUpperCase(),
            style: TextStyle(color: isDelivery ? const Color(0xFF2E7D32) : const Color(0xFFC2185B), fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
