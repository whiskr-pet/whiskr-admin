import 'package:flutter/material.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';

class AppointmentStatusChip extends StatelessWidget {
  const AppointmentStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    try {
      // Convert backend StatusChipType to UI AppointmentStatusType
      final AppointmentStatusType appointmentStatus = AppointmentStatusTypeExtension.fromBackendString(status);

      Color color;
      switch (appointmentStatus) {
        case AppointmentStatusType.scheduled:
          color = Colors.orange;
          break;
        case AppointmentStatusType.confirmed:
          color = Colors.blue;
          break;
        case AppointmentStatusType.inProgress:
          color = Colors.purple;
          break;
        case AppointmentStatusType.completed:
          color = Colors.green;
          break;
        case AppointmentStatusType.cancelled:
          color = Colors.red;
          break;
        case AppointmentStatusType.noShow:
          color = Colors.grey;
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          appointmentStatus.title.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      );
    } catch (e) {
      // Fallback to original status chip if conversion fails
      return StatusChip.orderStatus(status);
    }
  }
}
