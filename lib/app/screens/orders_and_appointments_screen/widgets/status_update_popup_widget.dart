import 'package:flutter/material.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';

class StatusUpdatePopup extends StatefulWidget {
  const StatusUpdatePopup({super.key, required this.currentStatus, required this.orderNumber, required this.onStatusUpdate});

  final StatusChipType currentStatus;
  final String orderNumber;
  final Function(StatusChipType) onStatusUpdate;

  static Future<StatusChipType?> show(
    BuildContext context, {
    required StatusChipType currentStatus,
    required String orderNumber,
    required Function(StatusChipType) onStatusUpdate,
  }) {
    return showDialog<StatusChipType>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatusUpdatePopup(currentStatus: currentStatus, orderNumber: orderNumber, onStatusUpdate: onStatusUpdate),
    );
  }

  @override
  State<StatusUpdatePopup> createState() => _StatusUpdatePopupState();
}

class _StatusUpdatePopupState extends State<StatusUpdatePopup> with SingleTickerProviderStateMixin {
  late StatusChipType _selectedStatus;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);

    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleStatusUpdate() {
    widget.onStatusUpdate(_selectedStatus);
    Navigator.of(context).pop(_selectedStatus);
  }

  Color _getStatusColor(StatusChipType status) {
    switch (status) {
      case StatusChipType.pending:
        return Colors.orange;
      case StatusChipType.confirmed:
        return Colors.blue;
      case StatusChipType.processing:
        return Colors.purple;
      case StatusChipType.shipped:
        return Colors.teal;
      case StatusChipType.delivered:
        return Colors.green;
      case StatusChipType.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(StatusChipType status) {
    switch (status) {
      case StatusChipType.pending:
        return Icons.schedule;
      case StatusChipType.confirmed:
        return Icons.check_circle_outline;
      case StatusChipType.processing:
        return Icons.sync;
      case StatusChipType.shipped:
        return Icons.local_shipping;
      case StatusChipType.delivered:
        return Icons.check_circle;
      case StatusChipType.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(StatusChipType status) {
    switch (status) {
      case StatusChipType.pending:
        return 'Awaiting confirmation';
      case StatusChipType.confirmed:
        return 'Order confirmed';
      case StatusChipType.processing:
        return 'Being prepared';
      case StatusChipType.shipped:
        return 'On the way';
      case StatusChipType.delivered:
        return 'Successfully delivered';
      case StatusChipType.cancelled:
        return 'Order cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 480,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.edit_note, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Update Order Status', style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Order #${widget.orderNumber}', style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(), color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 32),

                // Current Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Current Status:',
                        style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      StatusChip.orderStatus(widget.currentStatus.name),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text('Select New Status', style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),

                // Status Options
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: StatusChipType.values.map((status) {
                        final isSelected = _selectedStatus == status;
                        final statusColor = _getStatusColor(status);
                        final isCurrentStatus = status == widget.currentStatus;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? statusColor.withValues(alpha: 0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? statusColor : Colors.grey[300]!, width: isSelected ? 2 : 1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(_getStatusIcon(status), color: statusColor, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                status.name.toUpperCase(),
                                                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: isSelected ? statusColor : Colors.black87),
                                              ),
                                              if (isCurrentStatus) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                                                  child: Text(
                                                    'CURRENT',
                                                    style: theme.textTheme.bodySmall!.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(_getStatusDescription(status), style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    if (isSelected) Icon(Icons.check_circle, color: statusColor, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedStatus == widget.currentStatus ? null : _handleStatusUpdate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Update Status',
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
