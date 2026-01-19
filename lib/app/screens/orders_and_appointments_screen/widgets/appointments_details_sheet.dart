import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/extensions/string_extensions.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_provider.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/widgets/status_update_appointments_popup_widget.dart';

import '../../../../widgets/details_widget.dart';
import '../../../../widgets/wa_slide_panel.dart';
import 'appointment_status_chip.dart';

void showAppointmentDetailsSheet(BuildContext context) {
  showWASlidePanel(context: context, child: AppointmentDetailsSheet());
}

class AppointmentDetailsSheet extends StatelessWidget {
  const AppointmentDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final WaAppointmentsProvider provider = context.watch<WaAppointmentsProvider>();
    final WaAppointmentsModel appointment = provider.appointmentDetails;
    return Column(
      children: [
        _AppointmentHeader(appointment: appointment),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(appointment: appointment),
                const SizedBox(height: 24),
                _UpdateAppointmentSection(appointment: appointment),
                const SizedBox(height: 24),
                _ItemsSection(items: appointment.items),
                const SizedBox(height: 24),
                _SummarySection(total: appointment.total ?? 0),
                const SizedBox(height: 24),
                _MetaSection(appointment: appointment),
                if ((appointment.note ?? '').isNotEmpty) ...[const SizedBox(height: 24), _NoteSection(note: appointment.note!)],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentHeader extends StatelessWidget {
  final WaAppointmentsModel appointment;

  const _AppointmentHeader({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return DetailsHeader(title: 'Appointment #${appointment.appointmentNumber}');
  }
}

class _InfoSection extends StatelessWidget {
  final WaAppointmentsModel appointment;

  const _InfoSection({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GlassCard(
            title: 'Customer',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.person, value: appointment.customer ?? ''),
                if ((appointment.email ?? '').isNotEmpty) _InfoRow(icon: Icons.email, value: appointment.email!),
                if ((appointment.phone ?? '').isNotEmpty) _InfoRow(icon: Icons.phone, value: appointment.phone!),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            title: 'Appointment Time',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appointment.date != null) _InfoRow(icon: Icons.event, value: appointment.date!.toString().formatToDateString()),
                if ((appointment.time ?? '').isNotEmpty) _InfoRow(icon: Icons.access_time, value: appointment.time!),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final List<AppointmentItemModel> items;

  const _ItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Services',
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
  final WaAppointmentsModel appointment;

  const _MetaSection({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Time of creation',
      child: Column(children: [_KeyValue('Created', appointment.createdAt.toString().toFullDateTimeString())]),
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

class _UpdateAppointmentSection extends StatelessWidget {
  final WaAppointmentsModel appointment;

  const _UpdateAppointmentSection({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Update Your Appointment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need to change the appointment status? Tap the status chip below to update it and keep your customer informed.',
            style: TextStyle(height: 1.5, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              await AppointmentStatusUpdatePopup.show(
                context,
                // Use the safe conversion method
                currentStatus: AppointmentStatusTypeExtension.fromBackendString(appointment.status ?? ''),
                appointmentId: appointment.id?.substring(0, 8) ?? '',
                onStatusUpdate: (StatusChipType newStatus) async {
                  final WaAppointmentsProvider provider = context.read<WaAppointmentsProvider>();
                  provider.setSelectedAppointmentForUpdate(appointment);
                  provider.setStatusForUpdate(newStatus);

                  final ResponseModel<String> response = await provider.updateAppointmentStatus();

                  if (context.mounted) {
                    if (response.isSuccess) {
                      await provider.getAllAppointments();
                      if (context.mounted) {
                        WACustomSnackbar.instance.showSnack(
                          context,
                          'Appointment #${appointment.appointmentNumber} status updated to ${newStatus.toAppointmentType().title.toUpperCase()}',
                        );
                      }
                    } else {
                      WACustomSnackbar.instance.showSnack(context, 'Failed to update status', type: .error);
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
                  AppointmentStatusChip(status: appointment.status ?? ''),
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
