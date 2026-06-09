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
import 'package:cached_network_image/cached_network_image.dart';

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
      backgroundColor: const Color(0xFF7C3AED),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: const Color(0xFFF7F5FF),
        child: Container(
          decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            )
          ],
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
            Icon(selected ? activeIcon : icon, color: selected ? const Color(0xFF7C3AED) : const Color(0xFF9B8CB8), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? const Color(0xFF7C3AED) : const Color(0xFF9B8CB8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

    return Column(
      children: [
        _buildHero(firstName, todayFmt, vc),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Today\'s Schedule', context, 1),
                    if (vc.todaysAppointments.isEmpty)
                      _buildEmptyScheduleCard()
                    else
                      ...vc.todaysAppointments.map((a) => _AppointmentCard(appointment: a)),
                    
                    const SizedBox(height: 16),
                    _buildSectionHeader('Pending Requests', context, 1),
                    if (vc.pendingAppointments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDE8F8)),
                        ),
                        child: const Center(
                          child: Text(
                            'No pending requests',
                            style: TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
                          ),
                        ),
                      )
                    else
                      ...vc.pendingAppointments.take(2).map((a) => _PendingPreviewCard(appointment: a)),

                    const SizedBox(height: 16),
                    _buildSectionHeader('History', context, 1),
                    if (vc.completedAppointments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDE8F8)),
                        ),
                        child: const Center(
                          child: Text(
                            'No completed appointments yet',
                            style: TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
                          ),
                        ),
                      )
                    else
                      ...vc.completedAppointments.take(5).map((a) => _HistoryCard(appointment: a)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(String name, String date, VetController vc) {
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '${vc.todaysAppointments.length}',
                          label: 'Today\'s\nAppointments',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '${vc.pendingAppointments.length}',
                          label: 'Pending\nRequests',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context, int tabIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A0F2E),
            ),
          ),
          GestureDetector(
            onTap: () {
              final state = context.findAncestorStateOfType<_VetDashboardViewState>();
              if (state != null) {
                state.setState(() {
                  state._selectedIndex = tabIndex;
                });
              }
            },
            child: const Text(
              'See all',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'No appointments today',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A0F2E),
                ),
              ),
              Text(
                'Enjoy your day off',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 11,
                  color: Color(0xFF9B8CB8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final vc = context.read<VetController>();
    final fallbackPet = vc.getPetById(appointment.petId);
    final imgUrl = (appointment.petProfileUrl != null && appointment.petProfileUrl!.isNotEmpty)
        ? appointment.petProfileUrl
        : fallbackPet?.profileImageUrl;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentDetailsView(appointment: appointment))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE8F8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.petName,
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
                          appointment.ownerName != null ? 'Owner: ${appointment.ownerName}' : 'Unknown Owner',
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
                          appointment.isVirtual ? 'Virtual Consultation' : 'In-Person Visit',
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D), // Confirmed badge color
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CONFIRMED',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
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
                        DateFormat('MMM d, yyyy').format(appointment.appointmentDate),
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
                        DateFormat('h:mm a').format(appointment.timeSlot),
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
          ],
        ),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE8F8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF7C3AED), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appointment.petName} – ${appointment.reason}',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A0F2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('EEE, MMM d · h:mm a').format(appointment.timeSlot),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      color: Color(0xFF9B8CB8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 16),
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
    final vc = context.read<VetController>();
    final fallbackPet = vc.getPetById(appointment.petId);
    final imgUrl = (appointment.petProfileUrl != null && appointment.petProfileUrl!.isNotEmpty)
        ? appointment.petProfileUrl
        : fallbackPet?.profileImageUrl;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentDetailsView(appointment: appointment))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE8F8)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8F8),
                borderRadius: BorderRadius.circular(10),
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
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        vc.getPetEmoji(fallbackPet?.species ?? ''),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.petName,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A0F2E),
                    ),
                  ),
                  Text(
                    DateFormat('EEE, MMM d · h:mm a').format(appointment.timeSlot),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      color: Color(0xFF9B8CB8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'COMPLETED',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 16),
          ],
        ),
      ),
    );
  }
}
