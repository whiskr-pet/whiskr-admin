import 'package:flutter/material.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';

class AppointmentStatusUpdatePopup extends StatefulWidget {
  const AppointmentStatusUpdatePopup({super.key, required this.currentStatus, required this.appointmentId, required this.onStatusUpdate});

  final AppointmentStatusType currentStatus;
  final String appointmentId;
  final Function(StatusChipType) onStatusUpdate;

  static Future<AppointmentStatusType?> show(
    BuildContext context, {
    required AppointmentStatusType currentStatus,
    required String appointmentId,
    required Function(StatusChipType) onStatusUpdate,
  }) {
    return showDialog<AppointmentStatusType>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppointmentStatusUpdatePopup(currentStatus: currentStatus, appointmentId: appointmentId, onStatusUpdate: onStatusUpdate),
    );
  }

  @override
  State<AppointmentStatusUpdatePopup> createState() => _AppointmentStatusUpdatePopupState();
}

class _AppointmentStatusUpdatePopupState extends State<AppointmentStatusUpdatePopup> with SingleTickerProviderStateMixin {
  late AppointmentStatusType _selectedStatus;
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
    // Convert AppointmentStatusType to StatusChipType before calling the callback
    final StatusChipType chipType = _selectedStatus.toStatusChipType();
    widget.onStatusUpdate(chipType);
    Navigator.of(context).pop(_selectedStatus);
  }

  Color _getStatusColor(AppointmentStatusType status) {
    switch (status) {
      case AppointmentStatusType.scheduled:
        return Colors.orange;
      case AppointmentStatusType.confirmed:
        return Colors.blue;
      case AppointmentStatusType.inProgress:
        return Colors.purple;
      case AppointmentStatusType.completed:
        return Colors.green;
      case AppointmentStatusType.cancelled:
        return Colors.red;
      case AppointmentStatusType.noShow:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AppointmentStatusType status) {
    switch (status) {
      case AppointmentStatusType.scheduled:
        return Icons.calendar_today;
      case AppointmentStatusType.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatusType.inProgress:
        return Icons.hourglass_bottom;
      case AppointmentStatusType.completed:
        return Icons.check_circle;
      case AppointmentStatusType.cancelled:
        return Icons.cancel;
      case AppointmentStatusType.noShow:
        return Icons.person_off;
    }
  }

  String _getStatusDescription(AppointmentStatusType status) {
    switch (status) {
      case AppointmentStatusType.scheduled:
        return 'Appointment is scheduled';
      case AppointmentStatusType.confirmed:
        return 'Appointment confirmed with customer';
      case AppointmentStatusType.inProgress:
        return 'Currently in progress';
      case AppointmentStatusType.completed:
        return 'Successfully completed';
      case AppointmentStatusType.cancelled:
        return 'Appointment cancelled';
      case AppointmentStatusType.noShow:
        return 'Customer did not show up';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

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
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.edit_calendar, color: colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Update Appointment Status', style: themeData.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Appointment #${widget.appointmentId}', style: themeData.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(), color: colorScheme.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 32),

                // Current Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Current Status:',
                        style: themeData.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      // Convert to StatusChipType for display consistency
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.currentStatus).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getStatusColor(widget.currentStatus)),
                        ),
                        child: Text(
                          widget.currentStatus.title.toUpperCase(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(widget.currentStatus)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text('Select New Status', style: themeData.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),

                // Status Options
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: AppointmentStatusType.values.map((status) {
                        final bool isSelected = _selectedStatus == status;
                        final Color statusColor = _getStatusColor(status);
                        final bool isCurrentStatus = status == widget.currentStatus;

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
                                                status.title.toUpperCase(),
                                                style: themeData.textTheme.bodyLarge!.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? statusColor : colorScheme.onSurface,
                                                ),
                                              ),
                                              if (isCurrentStatus) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                                                  child: Text(
                                                    'CURRENT',
                                                    style: themeData.textTheme.bodySmall!.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(_getStatusDescription(status), style: themeData.textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant)),
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
                          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.60)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: themeData.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
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
                          backgroundColor: colorScheme.primary,
                          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Update Status',
                          style: themeData.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
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
