import 'package:flutter/material.dart';
import 'package:w_pet_service_module/providers/cart_provider.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context: context, mobile: 6.0, tablet: 7.0, desktop: 8.0),
        vertical: Responsive.value(context: context, mobile: 3.0, tablet: 3.5, desktop: 4.0),
      ),
      decoration: BoxDecoration(
        color: isQuick ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
        border: Border.all(color: isQuick ? const Color(0xFFFF9800) : const Color(0xFF2196F3), width: 1),
        borderRadius: BorderRadius.circular(Responsive.value(context: context, mobile: 4.0, tablet: 4.0, desktop: 5.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isQuick ? Icons.bolt : Icons.schedule,
            color: isQuick ? const Color(0xFFFF9800) : const Color(0xFF2196F3),
            size: Responsive.value(context: context, mobile: 11.0, tablet: 12.0, desktop: 13.0),
          ),
          SizedBox(width: Responsive.value(context: context, mobile: 3.0, tablet: 4.0, desktop: 4.0)),
          Text(
            this.orderType.toUpperCase(),
            style: TextStyle(
              color: isQuick ? const Color(0xFFE65100) : const Color(0xFF1565C0),
              fontWeight: FontWeight.w600,
              fontSize: Responsive.value(context: context, mobile: 9.0, tablet: 10.0, desktop: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}
