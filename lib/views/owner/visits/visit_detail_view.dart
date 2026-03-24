import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../models/appointment_model.dart';
import '../booking/available_vets_view.dart';

class VisitDetailView extends StatelessWidget {
  final Appointment appointment;

  const VisitDetailView({super.key, required this.appointment});

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  String _emoji(String vetName) {
    // Derive a unique icon per vet for visual variety
    final icons = ['🩺', '⚕️', '🔬', '💊'];
    return icons[vetName.length % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppointmentController>();
    // Watch for live status updates
    final live = ctrl.upcomingVisits
        .followedBy(ctrl.pastVisits)
        .firstWhere((a) => a.appointmentId == appointment.appointmentId,
            orElse: () => appointment);

    final dateFmt = DateFormat('EEEE, MMMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');
    final isActive = live.status == AppointmentStatus.pending ||
        live.status == AppointmentStatus.confirmed;
    final isCompleted = live.status == AppointmentStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Visit Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vet profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: _lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _emoji(live.vetName),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          live.vetName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PawHealth Vet Clinic',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '9:00 AM – 10:00 PM',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status badge
            _buildStatusRow(live.status),

            const SizedBox(height: 20),

            // Info rows
            _buildInfoCard([
              _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date',
                  value: dateFmt.format(live.appointmentDate)),
              _InfoRow(icon: Icons.access_time, label: 'Time',
                  value: timeFmt.format(live.timeSlot)),
              _InfoRow(icon: Icons.pets, label: 'Pet', value: live.petName),
              _InfoRow(icon: Icons.note_outlined, label: 'Reason',
                  value: live.reason),
            ]),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(context, ctrl, live, isActive, isCompleted),
    );
  }

  Widget _buildStatusRow(AppointmentStatus status) {
    final map = {
      AppointmentStatus.confirmed: ('Confirmed', const Color(0xFFDCFCE7), const Color(0xFF166534)),
      AppointmentStatus.pending:   ('Pending',   const Color(0xFFFEF9C3), const Color(0xFF854D0E)),
      AppointmentStatus.completed: ('Completed', const Color(0xFFF0F0F0), const Color(0xFF555555)),
      AppointmentStatus.cancelled: ('Cancelled', const Color(0xFFFFE4E4), const Color(0xFF991B1B)),
    };
    final (label, bg, fg) = map[status]!;
    return Row(
      children: [
        const Text('Status:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: TextStyle(color: fg, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: rows.map((r) => _buildRow(r)).toList(),
      ),
    );
  }

  Widget _buildRow(_InfoRow r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(r.icon, color: _purple, size: 18),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.label, style: TextStyle(fontSize: 11, fontFamily: 'Poppins', color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(r.value, style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, AppointmentController ctrl,
      Appointment live, bool isActive, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Builder(builder: (ctx) {
        if (isActive) {
          return _CancelButton(appointment: live);
        } else if (isCompleted) {
          return ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
            label: const Text(
              'Book Follow-up',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const AvailableVetsView()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          );
        } else {
          // Cancelled state
          return OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Appointment Cancelled', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400)),
          );
        }
      }),
    );
  }
}

class _CancelButton extends StatefulWidget {
  final Appointment appointment;
  const _CancelButton({required this.appointment});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _cancelling = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _cancelling
          ? null
          : () async {
              setState(() => _cancelling = true);
              await context.read<AppointmentController>().cancelAppointment(widget.appointment.appointmentId);
              setState(() => _cancelling = false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Appointment cancelled.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: Colors.red, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _cancelling
          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
          : const Text(
              'Cancel Appointment',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
}
