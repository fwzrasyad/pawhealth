import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../models/appointment_model.dart';
import 'visit_detail_view.dart';

class MyVisitsView extends StatefulWidget {
  const MyVisitsView({super.key});

  @override
  State<MyVisitsView> createState() => _MyVisitsViewState();
}

class _MyVisitsViewState extends State<MyVisitsView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentController>().fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF7C3AED),
        body: Column(
          children: [
            _buildHero(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F5FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Tab bar
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDE8F8)),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF9B8CB8),
                          labelStyle: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Upcoming'),
                            Tab(text: 'History'),
                          ],
                        ),
                      ),
                      // Tab content
                      Expanded(
                        child: Consumer<AppointmentController>(
                          builder: (context, ctrl, _) {
                            return TabBarView(
                              children: [
                                _AppointmentList(
                                  appointments: ctrl.upcomingVisits,
                                  emptyIcon: Icons.calendar_today_outlined,
                                  emptyMessage: 'No upcoming consultations',
                                  emptySubtitle: 'Book a consultation to get started.',
                                ),
                                _AppointmentList(
                                  appointments: ctrl.pastVisits,
                                  emptyIcon: Icons.history,
                                  emptyMessage: 'No past consultations',
                                  emptySubtitle: 'Your completed appointments will appear here.',
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
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
          top: -20,
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
        SafeArea(
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'My Consultations',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your appointments and visit history',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final IconData emptyIcon;
  final String emptyMessage;
  final String emptySubtitle;

  const _AppointmentList({
    required this.appointments,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: const Color(0xFFC4B5FD)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A0F2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptySubtitle,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                color: Color(0xFF9B8CB8),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return AppointmentCard(
          appointment: appt,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitDetailView(appointment: appt),
              ),
            );
          },
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed: return const Color(0xFF15803D);
      case AppointmentStatus.pending:   return const Color(0xFFB45309);
      case AppointmentStatus.completed: return const Color(0xFF5B4B8A);
      case AppointmentStatus.cancelled: return const Color(0xFF991B1B);
    }
  }

  String _statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed: return 'Confirmed';
      case AppointmentStatus.pending:   return 'Pending';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appt = appointment;
    final dateFmt = DateFormat('EEE, MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE8F8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: vet name + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    appt.vetName,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A0F2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(appt.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(appt.status),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                Text(
                  dateFmt.format(appt.appointmentDate),
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    color: Color(0xFF9B8CB8),
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                Text(
                  timeFmt.format(appt.timeSlot),
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    color: Color(0xFF9B8CB8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pet name
            Row(
              children: [
                const Icon(Icons.pets, size: 14, color: Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                Text(
                  'Pet: ${appt.petName}',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    color: Color(0xFF9B8CB8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Reason
            Row(
              children: [
                const Icon(Icons.note_outlined, size: 14, color: Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appt.reason,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      color: Color(0xFF9B8CB8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
