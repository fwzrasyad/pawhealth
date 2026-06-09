import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
import 'vet_appointment_details_view.dart';

class ManageAppointmentsView extends StatefulWidget {
  final bool embeddedMode;
  const ManageAppointmentsView({super.key, this.embeddedMode = false});

  @override
  State<ManageAppointmentsView> createState() => _ManageAppointmentsViewState();
}

class _ManageAppointmentsViewState extends State<ManageAppointmentsView> {
  int _selectedStatusIndex = 0; // 0: Pending, 1: Confirmed, 2: Completed

  @override
  Widget build(BuildContext context) {
    final vc = context.watch<VetController>();
    final pending = vc.pendingAppointments;
    final confirmed = vc.confirmedAppointments;
    final completed = vc.completedAppointments;

    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Hero Header
            Stack(
              children: [
                // Blobs
                Positioned(
                  top: -40,
                  left: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6D28D9).withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Content
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                        'All Appointments',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3, bottom: 20),
                        child: Text(
                          'Manage your upcoming bookings',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      // Tab Bar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _StatusTab(
                              label: 'Pending',
                              count: pending.length,
                              isSelected: _selectedStatusIndex == 0,
                              onTap: () => setState(() => _selectedStatusIndex = 0),
                            ),
                            _StatusTab(
                              label: 'Confirmed',
                              count: confirmed.length,
                              isSelected: _selectedStatusIndex == 1,
                              onTap: () => setState(() => _selectedStatusIndex = 1),
                            ),
                            _StatusTab(
                              label: 'Completed',
                              count: completed.length,
                              isSelected: _selectedStatusIndex == 2,
                              onTap: () => setState(() => _selectedStatusIndex = 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ],
            ),
            // White Card Body
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _selectedStatusIndex == 0
                    ? _buildAppointmentsList(pending, 'No pending appointments')
                    : _selectedStatusIndex == 1
                        ? _buildAppointmentsList(confirmed, 'No confirmed appointments')
                        : _buildAppointmentsList(completed, 'No completed appointments'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, String emptyMessage) {
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontFamily: 'Figtree',
            color: Color(0xFF9B8CB8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _AppointmentCard(appointment: appointments[i]),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF1A0F2E) : Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.white.withValues(alpha: 0.65),
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
          accept ? '✓ Appointment accepted' : '✗ Appointment rejected',
          style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600),
        ),
        backgroundColor: accept ? const Color(0xFF15803D) : const Color(0xFFB45309),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    final vc = context.read<VetController>();
    final fallbackPet = vc.getPetById(appt.petId);
    final imgUrl = (appt.petProfileUrl != null && appt.petProfileUrl!.isNotEmpty)
        ? appt.petProfileUrl
        : fallbackPet?.profileImageUrl;

    Color badgeColor;
    String badgeLabel;
    switch (appt.status) {
      case AppointmentStatus.pending:
        badgeColor = const Color(0xFFB45309);
        badgeLabel = 'Pending';
        break;
      case AppointmentStatus.confirmed:
        badgeColor = const Color(0xFF534AB7);
        badgeLabel = 'Confirmed';
        break;
      case AppointmentStatus.completed:
        badgeColor = const Color(0xFF15803D);
        badgeLabel = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        badgeColor = const Color(0xFF9B8CB8);
        badgeLabel = 'Cancelled';
        break;
    }

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE8F8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: imgUrl != null && imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const SizedBox(),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              vc.getPetEmoji(fallbackPet?.species ?? ''),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            vc.getPetEmoji(fallbackPet?.species ?? ''),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.petName,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A0F2E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 1),
                        child: Text(
                          appt.ownerName != null ? 'Owner: ${appt.ownerName}' : 'Unknown Owner',
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11,
                            color: Color(0xFF9B8CB8),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        child: Text(
                          appt.isVirtual ? 'Virtual Consultation' : 'In-Person Visit',
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11,
                            color: Color(0xFFB0A4C8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeLabel.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            // Meta Row
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEDE8F8))),
              ),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF9B8CB8)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(appt.appointmentDate),
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 11,
                          color: Color(0xFF9B8CB8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Color(0xFF9B8CB8)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(appt.timeSlot),
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 11,
                          color: Color(0xFF9B8CB8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Row
            if (appt.status == AppointmentStatus.pending)
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _processing ? null : () => _act(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9B8CB8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _processing ? null : () => _act(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _processing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Accept',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
