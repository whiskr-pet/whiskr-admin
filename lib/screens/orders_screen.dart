import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedView = 'list'; // 'list' or 'grid'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          IconButton(
            icon: Icon(_selectedView == 'list' ? Icons.grid_view : Icons.view_list),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'list' ? 'grid' : 'list';
              });
            },
          ),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
        ],
      ),
      body: Column(
        children: [
          // Demo Mode Indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Demo Mode: Click on orders to update status or view details', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                ),
                ElevatedButton.icon(
                  onPressed: _createDemoOrder,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Demo', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                ),
              ],
            ),
          ),

          // Quick Stats
          Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildQuickStat('Total', orderProvider.orders.length.toString(), AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    _buildQuickStat('Pending', orderProvider.pendingOrders.length.toString(), AppTheme.warningColor),
                    const SizedBox(width: 8),
                    _buildQuickStat('Delivered', orderProvider.deliveredOrders.length.toString(), AppTheme.successColor),
                    const SizedBox(width: 8),
                    _buildQuickStat('Revenue', '\$${orderProvider.totalRevenue.toStringAsFixed(0)}', AppTheme.infoColor),
                  ],
                ),
              );
            },
          ),

          // Orders List/Grid
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (orderProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading orders',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          orderProvider.error!,
                          style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () => orderProvider.loadOrders(), child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                final orders = orderProvider.filteredOrders;

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No orders yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a demo order to see how it works',
                          style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(onPressed: _createDemoOrder, icon: const Icon(Icons.add), label: const Text('Create Demo Order')),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(onRefresh: () => orderProvider.loadOrders(), child: _selectedView == 'list' ? _buildListView(orders) : _buildGridView(orders));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins'),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildOrderCard(order, isCompact: true));
      },
    );
  }

  Widget _buildGridView(List<Order> orders) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, isCompact: false);
      },
    );
  }

  Widget _buildOrderCard(Order order, {required bool isCompact}) {
    final Color statusColor = _getStatusColor(order.status);
    final IconData statusIcon = _getStatusIcon(order.status);
    final String initials = order.customerName.isNotEmpty ? order.customerName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '?';
    final String orderDate = _formatDate(order.createdAt);
    final String orderTime = "${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}";
    final Color cardBg = const Color(0xFF23272F); // dark card background
    final Color textColor = Colors.white;
    final Color subTextColor = Colors.white70;
    final Color dividerColor = Colors.white10;
    final Color avatarBg = AppTheme.primaryColor.withOpacity(0.9);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar, Name, Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar/Initials
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: avatarBg, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(width: 14),
                // Name and order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins', color: textColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: TextStyle(fontSize: 12, color: subTextColor, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        order.status[0].toUpperCase() + order.status.substring(1),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Date and time row
            Row(
              children: [
                Text(
                  orderDate,
                  style: TextStyle(fontSize: 13, color: textColor, fontFamily: 'Poppins'),
                ),
                const Spacer(),
                Text(
                  orderTime,
                  style: TextStyle(fontSize: 13, color: subTextColor, fontFamily: 'Poppins'),
                ),
              ],
            ),
            Divider(height: 24, thickness: 1, color: dividerColor),
            // Items table header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins', color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 32,
                  child: Text(
                    'Qty',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 60,
                  child: Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins', color: Colors.white),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Items list
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins', color: textColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins', color: textColor),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins', color: textColor),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Total row
            Row(
              children: [
                const Spacer(),
                Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins', color: subTextColor),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor, fontFamily: 'Poppins'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetails(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.25)),
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'See Details',
                      style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Update Status', style: TextStyle(fontSize: 13, fontFamily: 'Poppins')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Customer', order.customerName),
              _buildDetailRow('Email', order.customerEmail),
              _buildDetailRow('Phone', order.customerPhone),
              _buildDetailRow('Status', order.status.toUpperCase()),
              _buildDetailRow('Total', '\$${order.total.toStringAsFixed(2)}'),
              _buildDetailRow('Date', _formatDate(order.createdAt)),
              const SizedBox(height: 12),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.productName} x${item.quantity}', style: const TextStyle(fontSize: 12))),
                      Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showStatusUpdateDialog(order);
            },
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(order, 'pending', 'Pending', Icons.schedule, AppTheme.warningColor),
            _buildStatusOption(order, 'confirmed', 'Confirmed', Icons.check_circle, AppTheme.infoColor),
            _buildStatusOption(order, 'processing', 'Processing', Icons.build, AppTheme.primaryColor),
            _buildStatusOption(order, 'shipped', 'Shipped', Icons.local_shipping, AppTheme.secondaryColor),
            _buildStatusOption(order, 'delivered', 'Delivered', Icons.done_all, AppTheme.successColor),
            _buildStatusOption(order, 'cancelled', 'Cancelled', Icons.cancel, AppTheme.errorColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(Order order, String status, String label, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        _updateOrderStatus(order.id, status);
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('All Orders'),
                  value: 'all',
                  groupValue: orderProvider.selectedStatus,
                  onChanged: (value) {
                    orderProvider.setSelectedStatus(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Pending'),
                  value: 'pending',
                  groupValue: orderProvider.selectedStatus,
                  onChanged: (value) {
                    orderProvider.setSelectedStatus(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Confirmed'),
                  value: 'confirmed',
                  groupValue: orderProvider.selectedStatus,
                  onChanged: (value) {
                    orderProvider.setSelectedStatus(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Processing'),
                  value: 'processing',
                  groupValue: orderProvider.selectedStatus,
                  onChanged: (value) {
                    orderProvider.setSelectedStatus(value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Delivered'),
                  value: 'delivered',
                  groupValue: orderProvider.selectedStatus,
                  onChanged: (value) {
                    orderProvider.setSelectedStatus(value!);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _createDemoOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.createDemoOrder();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Demo order created successfully!'), backgroundColor: AppTheme.successColor));
    }
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

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.updateOrderStatus(orderId, newStatus);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order status updated to $newStatus'), backgroundColor: AppTheme.successColor));
    }
  }
}
