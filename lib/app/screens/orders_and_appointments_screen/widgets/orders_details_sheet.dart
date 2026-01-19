import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_pet_service_module/models/service_order_model/service_order_model.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/extensions/string_extensions.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/order_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/schedule_type_chip_widget.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/status_update_popup_widget.dart';

import '../../../../widgets/details_widget.dart';
import '../../../../widgets/wa_slide_panel.dart';

void showOrderDetailsSheet(BuildContext context) {
  showWASlidePanel(context: context, child: OrderDetailsSheet());
}

class OrderDetailsSheet extends StatelessWidget {
  const OrderDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final WaOrdersProvider provider = context.watch<WaOrdersProvider>();
    final ServiceOrderModel order = provider.orderDetails;
    return Column(
      children: [
        _OrderHeader(order: order),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(order: order),
                const SizedBox(height: 24),
                _UpdateOrderSection(order: order),
                const SizedBox(height: 24),
                _ItemsSection(items: order.items ?? []),
                const SizedBox(height: 24),
                _SummarySection(total: order.totalPrice ?? 0),
                const SizedBox(height: 24),
                _MetaSection(order: order),
                if ((order.note ?? '').isNotEmpty) ...[const SizedBox(height: 24), _NoteSection(note: order.note!)],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final ServiceOrderModel order;

  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return DetailsHeader(
      title: 'Order #${order.orderNumber}',
      subtitle: Wrap(
        spacing: 8,
        children: [
          if (order.orderType != null) OrderTypeChipWidget(orderType: order.orderType!.name),
          if (order.scheduleType != null) ScheduleTypeChipWidget(scheduleType: order.scheduleType!.name),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final ServiceOrderModel order;

  const _InfoSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final user = order.user;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GlassCard(
            title: 'Customer',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.person, value: '${user?.firstName ?? ''} ${user?.lastName ?? ''}'),
                if ((user?.email ?? '').isNotEmpty) _InfoRow(icon: Icons.email, value: user!.email!),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            title: 'Delivery',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.location_on, value: order.deliveryAddress ?? ''),
                if ((order.deliveryDate ?? '').isNotEmpty) _InfoRow(icon: Icons.event, value: order.deliveryDate!.toFullDateTimeString()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final List<ServiceOrderItemModel> items;

  const _ItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Items',
      child: Column(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withValues(alpha: 0.04)),
            child: Row(
              children: [
                Expanded(
                  child: Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text('\$${item.price?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final double total;

  const _SummarySection({required this.total});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Summary',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: ColorHelper.yellow500.color.withValues(alpha: 0.5)),
        child: Row(
          children: [
            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MetaSection extends StatelessWidget {
  final ServiceOrderModel order;

  const _MetaSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Time of creation',
      child: Column(children: [_KeyValue('Created', (order.createdAt ?? '-').toFullDateTimeString())]),
    );
  }
}

class _NoteSection extends StatelessWidget {
  final String note;

  const _NoteSection({required this.note});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Note',
      child: Text(note, style: const TextStyle(height: 1.5)),
    );
  }
}

///
///
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}

class _UpdateOrderSection extends StatelessWidget {
  final ServiceOrderModel order;

  const _UpdateOrderSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Update Your Order',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need to change the order status? Tap the status chip below to update it and keep your customer informed.',
            style: TextStyle(height: 1.5, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              await StatusUpdatePopup.show(
                context,
                currentStatus: StatusChipTypeExtension.fromString(order.status ?? ''),
                orderNumber: order.orderNumber ?? '',
                onStatusUpdate: (StatusChipType newStatus) async {
                  final WaOrdersProvider provider = context.read<WaOrdersProvider>();
                  provider.setSelectedOrderForUpdate(order);
                  provider.setStatusForUpdate(newStatus);

                  final ResponseModel<String> response = await provider.updateOrderStatus();

                  if (context.mounted) {
                    if (response.isSuccess) {
                      await provider.getAllOrders();
                      WACustomSnackbar.instance.showSnack(context, 'Order #${order.orderNumber} status updated to ${newStatus.name.toUpperCase()}');
                    } else {
                      WACustomSnackbar.instance.showSnack(context, 'Failed to update order status', type: .error);
                    }
                  }
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip.orderStatus(order.status ?? ''),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 16, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
