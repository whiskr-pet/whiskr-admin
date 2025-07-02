import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../utils/app_theme.dart';

class RecentOrdersWidget extends StatelessWidget {
  final void Function()? onViewAll;
  final void Function(Order)? onOrderTap;
  const RecentOrdersWidget({super.key, this.onViewAll, this.onOrderTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final recentOrders = orderProvider.recentOrders.take(5).toList();

        if (recentOrders.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No recent orders',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                    TextButton(onPressed: onViewAll, child: const Text('View All')),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentOrders.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return _buildOrderItem(context, order);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
        child: Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status), size: 20),
      ),
      title: Text(
        order.customerName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${order.id.substring(0, 8)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Poppins'),
          ),
          Text(
            DateFormat('MMM dd, yyyy').format(order.createdAt),
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Poppins'),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${order.total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _getStatusColor(order.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              order.status.toUpperCase(),
              style: TextStyle(color: _getStatusColor(order.status), fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
      onTap: () => onOrderTap?.call(order),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'confirmed':
        return AppTheme.infoColor;
      case 'processing':
        return AppTheme.primaryColor;
      case 'shipped':
        return AppTheme.secondaryColor;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'processing':
        return Icons.build;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_cart;
    }
  }
}
