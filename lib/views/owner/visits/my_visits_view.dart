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
        backgroundColor: AppColors.lightSurface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('My Visits', style: AppFonts.headline(fontSize: 22)),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.navInactive,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: AppFonts.bodyBold(fontSize: 14),
            unselectedLabelStyle: AppFonts.body(fontSize: 14),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: Consumer<AppointmentController>(
          builder: (context, ctrl, _) {
            return TabBarView(
              children: [
                _AppointmentList(
                  appointments: ctrl.upcomingVisits,
                  emptyIcon: Icons.calendar_today_outlined,
                  emptyMessage: 'No upcoming visits',
                  emptySubtitle: 'Book a consultation to get started.',
                ),
                _AppointmentList(
                  appointments: ctrl.pastVisits,
                  emptyIcon: Icons.history,
                  emptyMessage: 'No past visits',
                  emptySubtitle: 'Your completed appointments will appear here.',
                ),
              ],
            );
          },
        ),
      ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(emptyIcon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptySubtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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

  Color _statusBg(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed: return AppColors.healthGreenBg;
      case AppointmentStatus.pending:   return const Color(0xFFFEF9C3);
      case AppointmentStatus.completed: return const Color(0xFFF0F0F0);
      case AppointmentStatus.cancelled: return const Color(0xFFFFE4E4);
    }
  }

  Color _statusFg(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed: return AppColors.completedText;
      case AppointmentStatus.pending:   return const Color(0xFF854D0E);
      case AppointmentStatus.completed: return const Color(0xFF555555);
      case AppointmentStatus.cancelled: return AppColors.cancelledText;
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(appt.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(appt.status),
                    style: TextStyle(
                      color: _statusFg(appt.status),
                      fontWeight: FontWeight.bold,
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
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  dateFmt.format(appt.appointmentDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 14),
                Icon(Icons.access_time,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  timeFmt.format(appt.timeSlot),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pet name
            Row(
              children: [
                Icon(Icons.pets, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Pet: ${appt.petName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Reason
            Row(
              children: [
                Icon(Icons.note_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appt.reason,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
