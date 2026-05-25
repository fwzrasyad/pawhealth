import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
import '../../utils/constants.dart';
import 'manage_appointments_view.dart';
import 'manage_availability_view.dart';
import 'vet_appointment_details_view.dart';
import 'vet_profile_view.dart';

class VetDashboardView extends StatefulWidget {
  const VetDashboardView({super.key});

  @override
  State<VetDashboardView> createState() => _VetDashboardViewState();
}

class _VetDashboardViewState extends State<VetDashboardView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vc = context.read<VetController>();
      vc.fetchAppointments();
      vc.fetchPatients();
      vc.fetchMyVetProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _VetHomeContent(),
      const ManageAppointmentsView(embeddedMode: true),
      const ManageAvailabilityView(embeddedMode: true),
      const VetProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, selected: _selectedIndex == 0, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', onTap: () => setState(() => _selectedIndex = 0)),
                _NavItem(index: 1, selected: _selectedIndex == 1, icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: 'Appointments', onTap: () => setState(() => _selectedIndex = 1)),
                _NavItem(index: 2, selected: _selectedIndex == 2, icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Schedule', onTap: () => setState(() => _selectedIndex = 2)),
                _NavItem(index: 3, selected: _selectedIndex == 3, icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', onTap: () => setState(() => _selectedIndex = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.index, required this.selected, required this.icon, required this.activeIcon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: selected ? AppColors.primary : AppColors.navInactive, size: 24),
            SizedBox(height: 4),
            Text(label, style: AppFonts.dmSans(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: selected ? AppColors.primary : AppColors.navInactive)),
          ],
        ),
      ),
    );
  }
}

// ─── Vet Home Content ─────────────────────────────────────────────────────────

class _VetHomeContent extends StatelessWidget {
  const _VetHomeContent();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final vc = context.watch<VetController>();
    final firstName = auth.currentUser?.name.split(' ').first ?? 'Doctor';
    final todayFmt = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(), style: AppFonts.caption(fontSize: 13, color: AppColors.metaText)),
                      SizedBox(height: 2),
                      Text(firstName, style: AppFonts.headline(fontSize: 26)),
                      Text(todayFmt, style: AppFonts.caption(fontSize: 13, color: AppColors.metaText)),
                    ],
                  ),
                ),
                Container(
                  width: 48, height: 48,
                  decoration: AppDecor.squareChip(),
                  child: Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Quick Stats
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.calendar_today, label: "Today's\nAppointments", value: '${vc.todaysAppointments.length}', color: AppColors.primary, bg: AppColors.chipBg)),
                const SizedBox(width: 14),
                Expanded(child: _StatCard(icon: Icons.pending_actions, label: 'Pending\nRequests', value: '${vc.pendingAppointments.length}', color: AppColors.pendingText, bg: AppColors.pendingBg)),
              ],
            ),

            const SizedBox(height: 28),

            // Today's Schedule
            Text("Today's Schedule", style: AppFonts.fraunces(fontSize: 18)),
            const SizedBox(height: 14),

            if (vc.todaysAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppDecor.card(),
                child: Row(
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No appointments today!', style: AppFonts.bodyBold()),
                        Text('Enjoy your day off.', style: AppFonts.caption(color: AppColors.metaText)),
                      ],
                    ),
                  ],
                ),
              )
            else
              ...vc.todaysAppointments.asMap().entries.map((entry) {
                final i = entry.key;
                final appt = entry.value;
                final isLast = i == vc.todaysAppointments.length - 1;
                return _TimelineCard(appointment: appt, isLast: isLast);
              }),

            SizedBox(height: 28),

            // Pending Requests Preview
            Row(
              children: [
                Text('Pending Requests', style: AppFonts.fraunces(fontSize: 18)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAppointmentsView())),
                  child: Text('See all', style: AppFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (vc.pendingAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecor.card(),
                child: Center(child: Text('No pending requests', style: AppFonts.body(color: AppColors.metaText))),
              )
            else
              ...vc.pendingAppointments.take(2).map((a) => _PendingPreviewCard(appointment: a)),

            const SizedBox(height: 28),

            // History Section
            Text('History', style: AppFonts.fraunces(fontSize: 18)),
            const SizedBox(height: 6),
            Text('Completed appointments', style: AppFonts.caption(color: AppColors.metaText)),
            const SizedBox(height: 14),
            if (vc.completedAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecor.card(),
                child: Center(child: Text('No completed appointments yet', style: AppFonts.body(color: AppColors.metaText))),
              )
            else
              ...vc.completedAppointments.take(5).map((a) => _HistoryCard(appointment: a)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecor.card(radius: 18),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: AppDecor.squareChip(color: bg),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppFonts.fraunces(fontSize: 24, color: color)),
                Text(label, style: AppFonts.caption(fontSize: 11, color: AppColors.metaText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Appointment appointment;
  final bool isLast;

  const _TimelineCard({required this.appointment, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.cardBorder)),
              ],
            ),
          ),
          // Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentDetailsView(appointment: appointment)));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
                padding: const EdgeInsets.all(16),
                decoration: AppDecor.card(),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('h:mm a').format(appointment.timeSlot), style: AppFonts.bodyBold(color: AppColors.primary)),
                        SizedBox(height: 4),
                        Text(appointment.petName, style: AppFonts.fraunces(fontSize: 15)),
                        Text(appointment.reason, style: AppFonts.caption(color: AppColors.metaText), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: AppColors.navInactive),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPreviewCard extends StatelessWidget {
  final Appointment appointment;
  const _PendingPreviewCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentDetailsView(appointment: appointment))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: AppDecor.squareChip(color: AppColors.pendingBg),
              child: Icon(Icons.pending_actions, color: AppColors.pendingText, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${appointment.petName} – ${appointment.reason}', style: AppFonts.bodyBold(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(DateFormat('EEE, MMM d · h:mm a').format(appointment.timeSlot), style: AppFonts.caption(color: AppColors.metaText)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.navInactive, size: 18),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Appointment appointment;
  const _HistoryCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentDetailsView(appointment: appointment))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: AppDecor.squareChip(color: AppColors.completedBg),
              child: Icon(Icons.check_circle, color: AppColors.completedText, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.petName, style: AppFonts.fraunces(fontSize: 13)),
                  Text(DateFormat('EEE, MMM d · h:mm a').format(appointment.timeSlot), style: AppFonts.caption(color: AppColors.metaText)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.completedBg, borderRadius: BorderRadius.circular(8)),
              child: Text('Completed', style: AppFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 10, color: AppColors.completedText)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppColors.navInactive, size: 18),
          ],
        ),
      ),
    );
  }
}
