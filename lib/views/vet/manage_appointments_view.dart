import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
import 'vet_appointment_details_view.dart';

class ManageAppointmentsView extends StatefulWidget {
  // When embedded=true it's a tab inside VetDashboardView (no AppBar back button needed)
  final bool embeddedMode;
  const ManageAppointmentsView({super.key, this.embeddedMode = false});

  @override
  State<ManageAppointmentsView> createState() => _ManageAppointmentsViewState();
}

class _ManageAppointmentsViewState extends State<ManageAppointmentsView> {
  static const _purple = Color(0xFF8A2BE2);
  int _selectedStatusIndex = 0; // 0: Pending, 1: Confirmed, 2: Completed

  @override
  Widget build(BuildContext context) {
    final vc = context.watch<VetController>();
    final pending = vc.pendingAppointments;
    final confirmed = vc.confirmedAppointments;
    final completed = vc.completedAppointments;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: widget.embeddedMode
          ? null
          : AppBar(
              title: const Text('All Appointments', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.embeddedMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All Appointments', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
                    const SizedBox(height: 4),
                    Text('View pending, confirmed, and completed appointments', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),

            // Status Filter Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  _StatusTab(
                    label: 'Pending',
                    count: pending.length,
                    isSelected: _selectedStatusIndex == 0,
                    badgeColor: const Color(0xFFFEF3C7),
                    textColor: const Color(0xFFB45309),
                    onTap: () => setState(() => _selectedStatusIndex = 0),
                  ),
                  const SizedBox(width: 12),
                  _StatusTab(
                    label: 'Confirmed',
                    count: confirmed.length,
                    isSelected: _selectedStatusIndex == 1,
                    badgeColor: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1E40AF),
                    onTap: () => setState(() => _selectedStatusIndex = 1),
                  ),
                  const SizedBox(width: 12),
                  _StatusTab(
                    label: 'Completed',
                    count: completed.length,
                    isSelected: _selectedStatusIndex == 2,
                    badgeColor: const Color(0xFFF0FDF4),
                    textColor: const Color(0xFF166534),
                    onTap: () => setState(() => _selectedStatusIndex = 2),
                  ),
                ],
              ),
            ),

            // Appointments List
            Expanded(
              child: _selectedStatusIndex == 0
                  ? _buildAppointmentsList(pending, 'No pending appointments')
                  : _selectedStatusIndex == 1
                      ? _buildAppointmentsList(confirmed, 'No confirmed appointments')
                      : _buildAppointmentsList(completed, 'No completed appointments'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, String emptyMessage) {
    return appointments.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Color(0xFFF3E8FF), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, size: 48, color: _purple),
                ),
                const SizedBox(height: 16),
                const Text('All caught up!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                const SizedBox(height: 6),
                Text(emptyMessage, style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: appointments.length,
            itemBuilder: (ctx, i) => _AppointmentCard(appointment: appointments[i]),
          );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color badgeColor;
  final Color textColor;
  final VoidCallback onTap;

  const _StatusTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.badgeColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? badgeColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? textColor : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatefulWidget {
  final Appointment appointment;
  const _AppointmentCard({required this.appointment});

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  bool _processing = false;

  static const _purple = Color(0xFF8A2BE2);

  Future<void> _act(bool accept) async {
    setState(() => _processing = true);
    final vc = context.read<VetController>();
    if (accept) {
      await vc.acceptAppointment(widget.appointment.appointmentId);
    } else {
      await vc.rejectAppointment(widget.appointment.appointmentId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          accept ? '✓ Appointment accepted for ${widget.appointment.petName}' : '✗ Appointment rejected',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: accept ? _purple : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VetAppointmentDetailsView(appointment: appt),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet + Status
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: const BoxDecoration(color: Color(0xFFF3E8FF), shape: BoxShape.circle),
                  child: const Center(child: Text('🐾', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt.petName, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                      Text(appt.reason, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                _buildStatusPill(appt.status),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),
            // Date + Time
            Row(
              children: [
                _InfoPill(icon: Icons.calendar_today_outlined, text: DateFormat('EEE, MMM d').format(appt.appointmentDate)),
                const SizedBox(width: 10),
                _InfoPill(icon: Icons.access_time, text: DateFormat('h:mm a').format(appt.timeSlot)),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons (Only for Pending)
            if (appt.status == AppointmentStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _processing ? null : () => _act(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _processing ? null : () => _act(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        disabledBackgroundColor: _purple.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _processing
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Accept', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(AppointmentStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case AppointmentStatus.pending:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = 'Pending';
        break;
      case AppointmentStatus.confirmed:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1E40AF);
        label = 'Confirmed';
        break;
      case AppointmentStatus.completed:
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF166534);
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFF991B1B);
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11, color: textColor)),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF8A2BE2)),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
