import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pet_controller.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/appointment_model.dart';

import '../../models/daily_routine_model.dart';
import '../profile/profile_settings_view.dart';
import 'pets/my_pets_list_view.dart';
import 'booking/available_vets_view.dart';
import 'analyzer/smart_analyzer_intro_view.dart';
import 'visits/my_visits_view.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(),
    const MyPetsListView(),
    const Center(child: Text('')), // placeholder for center FAB
    const MyVisitsView(),
    const SmartAnalyzerIntroView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<PetController>().fetchPets(auth.currentUser!.userId);
        context.read<AppointmentController>().fetchAppointments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                index: 0,
                selected: _selectedIndex == 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavItem(
                index: 1,
                selected: _selectedIndex == 1,
                icon: Icons.pets_outlined,
                activeIcon: Icons.pets,
                label: 'Pets',
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              // Centre FAB
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvailableVetsView(),
                  ),
                ),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF9333EA), Color(0xFF8A2BE2), Color(0xFF6B21A8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A2BE2).withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              _NavItem(
                index: 3,
                selected: _selectedIndex == 3,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Visits',
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              _NavItem(
                index: 4,
                selected: _selectedIndex == 4,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Analyze',
                onTap: () => setState(() => _selectedIndex = 4),
              ),
            ],
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

  const _NavItem({
    required this.index,
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected ? activeIcon : icon,
                color: selected ? _purple : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: selected ? 10 : 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _purple : Colors.grey.shade400,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 3),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: selected ? 5 : 0,
              height: selected ? 5 : 0,
              decoration: const BoxDecoration(
                color: _purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Home Content ───────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _getPetEmoji(String species) {
    final s = species.toLowerCase();
    if (s.contains('dog')) return '🐶';
    if (s.contains('cat')) return '🐱';
    if (s.contains('bird')) return '🐦';
    if (s.contains('rabbit')) return '🐰';
    if (s.contains('fish')) return '🐠';
    return '🐾';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final apptCtrl = context.watch<AppointmentController>();
    final petCtrl = context.watch<PetController>();
    final firstName = auth.currentUser?.name.split(' ').first ?? 'there';
    final upcoming = apptCtrl.upcomingVisits;
    final myPets = petCtrl.pets;

    final allRoutines = <Map<String, dynamic>>[];
    for (var pet in myPets) {
      for (var log in pet.dailyRoutines) {
        allRoutines.add({
          'petName': pet.name,
          'log': log,
        });
      }
    }
    allRoutines.sort((a, b) => (b['log'].date as DateTime).compareTo(a['log'].date as DateTime));
    final recentRoutines = allRoutines.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        firstName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSettingsView(),
                    ),
                  ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: _purple,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Upcoming Appointment Banner ─────────────────────────
            _UpcomingBanner(upcoming: upcoming),

            const SizedBox(height: 28),

            // ── Quick Actions ───────────────────────────────────────
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.calendar_month_outlined,
                    label: 'Book Vet',
                    iconColor: _purple,
                    bgColor: _lightPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AvailableVetsView(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.document_scanner_outlined,
                    label: 'AI Scan',
                    iconColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFEDE9FE),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SmartAnalyzerIntroView(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.pets,
                    label: 'My Pets',
                    iconColor: const Color(0xFFDB2777),
                    bgColor: const Color(0xFFFCE7F3),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPetsListView()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Pet Health Summary ──────────────────────────────────
            Row(
              children: [
                const Text(
                  "Pet Health",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: _purple,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: myPets.isEmpty
                    ? [
                        Text(
                          'No pets added yet.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade500,
                          ),
                        )
                      ]
                    : myPets.map((pet) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _PetHealthCard(
                            emoji: _getPetEmoji(pet.species),
                            name: pet.name,
                            species: pet.species,
                            status: 'Healthy',
                            statusColor: const Color(0xFF16A34A),
                            statusBg: const Color(0xFFDCFCE7),
                          ),
                        );
                      }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Recent Activity Logs ─────────────────────────────────────
            const Text(
              "Recent Logs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            recentRoutines.isEmpty
                ? Text(
                    'No routine logs recently.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade500,
                    ),
                  )
                : Column(
                    children: recentRoutines.map((r) {
                      final petName = r['petName'] as String;
                      final log = r['log'] as DailyRoutineLog;
                      
                      IconData getIcon(String act) {
                        if (act.toLowerCase().contains('high')) return Icons.directions_run;
                        if (act.toLowerCase().contains('low')) return Icons.bedtime;
                        return Icons.pets;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _RoutineItem(
                          icon: getIcon(log.activityLevel),
                          title: '$petName log',
                          subtitle: 'Activity: ${log.activityLevel} | W: ${log.weight}kg',
                          time: DateFormat('MMM d').format(log.date),
                          done: true,
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _UpcomingBanner extends StatelessWidget {
  final List<Appointment> upcoming;
  const _UpcomingBanner({required this.upcoming});

  @override
  Widget build(BuildContext context) {
    if (upcoming.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AvailableVetsView()),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8A2BE2), Color(0xFF6B21A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No upcoming visits',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Book a consultation with a vet today',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final next = upcoming.first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8A2BE2), Color(0xFF6B21A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(next.status.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                DateFormat('h:mm a').format(next.timeSlot),
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            next.reason,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            next.vetName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pet: ${next.petName}  ·  ${DateFormat('EEE, MMM d').format(next.appointmentDate)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String s) => s[0].toUpperCase() + s.substring(1);
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetHealthCard extends StatelessWidget {
  final String emoji, name, species, status;
  final Color statusColor, statusBg;

  const _PetHealthCard({
    required this.emoji,
    required this.name,
    required this.species,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          Text(
            species,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, time;
  final bool done;

  const _RoutineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: done ? const Color(0xFFDCFCE7) : const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: done ? const Color(0xFF16A34A) : const Color(0xFF8A2BE2),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  done ? 'Done' : 'Pending',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: done
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF8A2BE2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
