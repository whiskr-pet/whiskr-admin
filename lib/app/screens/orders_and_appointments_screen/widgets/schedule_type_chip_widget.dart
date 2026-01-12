import 'package:flutter/material.dart';
import 'package:w_pet_service_module/providers/cart_provider.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context: context, mobile: 6.0, tablet: 7.0, desktop: 8.0),
        vertical: Responsive.value(context: context, mobile: 3.0, tablet: 3.5, desktop: 4.0),
      ),
      decoration: BoxDecoration(
        color: isDelivery ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
        border: Border.all(color: isDelivery ? const Color(0xFF4CAF50) : const Color(0xFFE91E63), width: 1),
        borderRadius: BorderRadius.circular(Responsive.value(context: context, mobile: 4.0, tablet: 4.0, desktop: 5.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelivery ? Icons.local_shipping : Icons.store,
            color: isDelivery ? const Color(0xFF4CAF50) : const Color(0xFFE91E63),
            size: Responsive.value(context: context, mobile: 11.0, tablet: 12.0, desktop: 13.0),
          ),
          SizedBox(width: Responsive.value(context: context, mobile: 3.0, tablet: 4.0, desktop: 4.0)),
          Text(
            this.scheduleType.toUpperCase(),
            style: TextStyle(
              color: isDelivery ? const Color(0xFF2E7D32) : const Color(0xFFC2185B),
              fontWeight: FontWeight.w600,
              fontSize: Responsive.value(context: context, mobile: 9.0, tablet: 10.0, desktop: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}
