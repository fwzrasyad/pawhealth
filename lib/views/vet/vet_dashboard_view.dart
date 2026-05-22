import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
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

  static const _purple = Color(0xFF8A2BE2);

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(color: selected ? const Color(0xFFF3E8FF) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
              child: Icon(selected ? activeIcon : icon, color: selected ? _purple : Colors.grey.shade500, size: 24),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? _purple : Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// ─── Vet Home Content ─────────────────────────────────────────────────────────

class _VetHomeContent extends StatelessWidget {
  const _VetHomeContent();

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

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
                      Text(_greeting(), style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500)),
                      const SizedBox(height: 2),
                      Text(firstName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(todayFmt, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: _lightPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_outlined, color: _purple, size: 22),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Quick Stats
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.calendar_today, label: "Today's\nAppointments", value: '${vc.todaysAppointments.length}', color: _purple, bg: _lightPurple)),
                const SizedBox(width: 14),
                Expanded(child: _StatCard(icon: Icons.pending_actions, label: 'Pending\nRequests', value: '${vc.pendingAppointments.length}', color: const Color(0xFFEA580C), bg: const Color(0xFFFFF7ED))),
              ],
            ),

            const SizedBox(height: 28),

            // Today's Schedule
            const Text("Today's Schedule", style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 14),

            if (vc.todaysAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))]),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No appointments today!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Enjoy your day off.', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
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

            const SizedBox(height: 28),

            // Pending Requests Preview
            Row(
              children: [
                const Text('Pending Requests', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAppointmentsView())),
                  child: Text('See all', style: const TextStyle(fontFamily: 'Poppins', color: _purple, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (vc.pendingAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))]),
                child: Center(child: Text('No pending requests', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 14))),
              )
            else
              ...vc.pendingAppointments.take(2).map((a) => _PendingPreviewCard(appointment: a)),

            const SizedBox(height: 28),

            // History Section
            const Text('History', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Text('Completed appointments', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 14),
            if (vc.completedAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))]),
                child: Center(child: Text('No completed appointments yet', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 14))),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24, color: color)),
                Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade500, height: 1.3)),
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

  static const _purple = Color(0xFF8A2BE2);

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
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: _purple, shape: BoxShape.circle)),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: const Color(0xFFE8D5FF))),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('h:mm a').format(appointment.timeSlot), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: _purple)),
                        const SizedBox(height: 4),
                        Text(appointment.petName, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                        Text(appointment.reason, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFFF7ED), shape: BoxShape.circle), child: const Icon(Icons.pending_actions, color: Color(0xFFEA580C), size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appointment.petName} – ${appointment.reason}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(DateFormat('EEE, MMM d · h:mm a').format(appointment.timeSlot), style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBBF7D0)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.petName, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                  Text(DateFormat('EEE, MMM d · h:mm a').format(appointment.timeSlot), style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
              child: const Text('Completed', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF166534))),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
