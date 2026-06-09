import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../models/appointment_model.dart';
import '../booking/book_appointment_view.dart';
import '../../video_call/video_call_view.dart';
import '../../video_call/video_call_waiting_view.dart';

class VisitDetailView extends StatelessWidget {
  final Appointment appointment;

  const VisitDetailView({super.key, required this.appointment});

  

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
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          'Consultation Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
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
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(12),
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
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          live.clinicName.isNotEmpty ? live.clinicName : 'PawHealth Vet Clinic',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Consultation type badge
            _buildConsultationTypeBadge(live),

            const SizedBox(height: 16),

            // Video call section (for virtual appointments)
            if (live.isVirtual && isActive)
              _buildVideoCallSection(context, ctrl, live),

            if (live.isVirtual && isActive)
              const SizedBox(height: 16),

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

            if (isCompleted && live.medicalRecord != null) ...[
              const SizedBox(height: 24),
              const Text(
                "Doctor's Notes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis: ${live.medicalRecord!.diagnosis}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (live.medicalRecord!.doctorNotes?.isNotEmpty ?? false) ...[
                      const Text(
                        'Notes:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        live.medicalRecord!.doctorNotes!,
                        style: const TextStyle(fontSize: 14, ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (live.medicalRecord!.medicationsPrescribed?.isNotEmpty ?? false) ...[
                      const Text(
                        'Medications:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        live.medicalRecord!.medicationsPrescribed!.join(', '),
                        style: const TextStyle(fontSize: 14, ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (live.medicalRecord!.followUpInstructions?.isNotEmpty ?? false) ...[
                      const Text(
                        'Follow-up Instructions:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        live.medicalRecord!.followUpInstructions!,
                        style: const TextStyle(fontSize: 14, ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(context, ctrl, live, isActive, isCompleted),
    );
  }

  Widget _buildConsultationTypeBadge(Appointment appt) {
    final isVirtual = appt.isVirtual;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isVirtual ? const Color(0xFFF0E8FF) : const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVirtual ? const Color(0xFFD4BFFF) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVirtual ? Icons.videocam : Icons.local_hospital,
            size: 16,
            color: isVirtual ? const Color(0xFF7C3AED) : const Color(0xFF15803D),
          ),
          const SizedBox(width: 8),
          Text(
            isVirtual ? 'Virtual Consultation' : 'In-Person Visit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isVirtual ? const Color(0xFF7C3AED) : const Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCallSection(BuildContext context, AppointmentController ctrl, Appointment live) {
    final isConfirmed = live.status == AppointmentStatus.confirmed;
    final isCallActive = live.isCallActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCallActive
            ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)])
            : null,
        color: isCallActive ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isCallActive
                ? const Color(0xFF7C3AED).withOpacity(0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.videocam,
                size: 18,
                color: isCallActive ? Colors.white : const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              Text(
                'Video Consultation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCallActive ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!isConfirmed)
            Text(
              'The video call will be available once the vet confirms your appointment.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            )
          else if (isCallActive)
            Column(
              children: [
                Text(
                  'The vet has started the consultation!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _joinVideoCall(context, ctrl, live),
                    icon: const Icon(Icons.videocam, color: Color(0xFF7C3AED), size: 18),
                    label: const Text(
                      'Join Video Call',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  'Waiting for the vet to start the video call...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoCallWaitingView(appointment: live),
                        ),
                      );
                    },
                    icon: const Icon(Icons.hourglass_top, size: 16, color: Color(0xFF7C3AED)),
                    label: const Text(
                      'Enter Waiting Room',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4BFFF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _joinVideoCall(BuildContext context, AppointmentController ctrl, Appointment live) async {
    final response = await ctrl.getCallStatus(live.appointmentId);
    if (response != null && response['active'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallView(
            appId: response['app_id'],
            token: response['token'],
            channelName: response['channel'],
            uid: response['uid'] ?? 2,
            remoteName: live.vetName,
            onCallEnded: () {
              ctrl.endVideoCall(live.appointmentId).catchError((e) {
                debugPrint('Call ended or error: $e');
              });
            },
          ),
        ),
      );
    }
  }

  Widget _buildStatusRow(AppointmentStatus status) {
    final map = {
      AppointmentStatus.confirmed: ('Confirmed', AppColors.healthGreenBg, AppColors.completedText),
      AppointmentStatus.pending:   ('Pending',   const Color(0xFFFEF9C3), const Color(0xFF854D0E)),
      AppointmentStatus.completed: ('Completed', const Color(0xFFF0F0F0), const Color(0xFF555555)),
      AppointmentStatus.cancelled: ('Cancelled', const Color(0xFFFFE4E4), AppColors.cancelledText),
    };
    final (label, bg, fg) = map[status]!;
    return Row(
      children: [
        const Text('Status:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13)),
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
          Icon(r.icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(r.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
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
            label: Text(
              'Book Follow-up',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const BookAppointmentView()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
            child: Text('Appointment Cancelled', style: TextStyle(color: Colors.grey.shade400)),
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
                        style: TextStyle(fontWeight: FontWeight.w600)),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
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
