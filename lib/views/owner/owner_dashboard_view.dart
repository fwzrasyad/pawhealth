import 'package:flutter/material.dart';
import 'package:pawhealth/views/owner/pets/pet_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pet_controller.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/appointment_model.dart';

import '../../models/daily_routine_model.dart';
import '../../utils/constants.dart';
import '../profile/profile_settings_view.dart';
import 'pets/my_pets_list_view.dart';
import 'pets/pet_detail_view.dart';
import 'booking/book_appointment_view.dart';
import 'ai/ai_scanner_view.dart';
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
    const AIScannerView(),
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
      backgroundColor: AppColors.lightSurface,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
              // Centre FAB — square
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookAppointmentView(),
                  ),
                ),
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
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
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.primary : AppColors.navInactive,
              size: 22,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Home Content ───────────────────────────────────────────────────

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  List<NewsArticle>? _newsArticles;
  bool _isLoadingNews = true;
  bool _hasNewsError = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=%22pet%20health%22%20OR%20%22dog%20health%22%20OR%20%22cat%20health%22&language=en&sortBy=relevancy&pageSize=10&apiKey=7d25372bd825421c8206ac9deeca4cfa',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((json) => NewsArticle.fromJson(json))
            .where((a) => a.title.isNotEmpty && a.url.isNotEmpty)
            .take(10)
            .toList();
        if (mounted) {
          setState(() {
            _newsArticles = articles;
            _isLoadingNews = false;
          });
        }
      } else {
        if (mounted)
          setState(() {
            _isLoadingNews = false;
            _hasNewsError = true;
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoadingNews = false;
          _hasNewsError = true;
        });
    }
  }

  String _getRelativeTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

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
                        style: AppFonts.caption(
                          fontSize: 13,
                          color: AppColors.metaText,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(firstName, style: AppFonts.headline(fontSize: 26)),
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
                    decoration: AppDecor.squareChip(),
                    clipBehavior: Clip.hardEdge,
                    child:
                        (auth.currentUser?.profileImageUrl != null &&
                            auth.currentUser!.profileImageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: auth.currentUser!.profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Upcoming Appointment Banner ─────────────────────────
            _UpcomingBanner(upcoming: upcoming),

            const SizedBox(height: 28),

            // ── Pet Health Summary ──────────────────────────────────
            Row(
              children: [
                Text("Pet Health", style: AppFonts.fraunces(fontSize: 18)),
                const Spacer(),

                Text(
                  'See all',
                  style: AppFonts.dmSans(
                    color: AppColors.primary,
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
                          style: AppFonts.body(color: AppColors.metaText),
                        ),
                      ]
                    : myPets.map((pet) {
                        return GestureDetector(
                          onTap: () {
                            petCtrl.selectPet(pet);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PetDetailView(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: _PetHealthCard(
                              emoji: _getPetEmoji(pet.species),
                              name: pet.name,
                              species: pet.species,
                              status: 'Healthy',
                              profileImageUrl: pet.profileImageUrl,
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Pet Health News ──────────────────────────────────────
            Row(
              children: [
                const Text(
                  "Pet Health News",
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1A0F2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (_isLoadingNews)
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(right: index == 2 ? 20 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDE8F8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EFFF),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 11,
                                  width: 80,
                                  color: const Color(0xFFF3EFFF),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 13,
                                  width: double.infinity,
                                  color: const Color(0xFFF3EFFF),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 13,
                                  width: 100,
                                  color: const Color(0xFFF3EFFF),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else if (_hasNewsError ||
                _newsArticles == null ||
                _newsArticles!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Couldn't load news at this time.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _newsArticles!.length,
                  itemBuilder: (context, index) {
                    final article = _newsArticles![index];
                    return GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(article.url);
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.inAppBrowserView,
                          );
                        } catch (e) {
                          try {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (_) {}
                        }
                      },
                      child: Container(
                        width: 200,
                        margin: EdgeInsets.only(
                          right: index == _newsArticles!.length - 1 ? 20 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEDE8F8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: article.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: article.imageUrl!,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          _buildFallbackImage(),
                                    )
                                  : _buildFallbackImage(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.source.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: Color(0xFF7C3AED),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF1A0F2E),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getRelativeTime(article.publishedAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFB0A4C8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 100,
      width: double.infinity,
      color: const Color(0xFFF3EFFF),
      child: const Center(
        child: Icon(Icons.pets, color: Color(0xFF7C3AED), size: 32),
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
          MaterialPageRoute(builder: (_) => const BookAppointmentView()),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppDecor.darkCard(),
          child: Stack(
            children: [
              // Decorative glow blobs
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.glowPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No upcoming visits',
                          style: AppFonts.fraunces(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Book a consultation with a vet today',
                          style: AppFonts.dmSans(
                            color: AppColors.metaText,
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
                      color: AppColors.badgePurpleBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Book Now',
                      style: AppFonts.bodyBold(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
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
      decoration: AppDecor.darkCard(),
      child: Stack(
        children: [
          // Decorative glow blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.glowPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Column(
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
                      color: AppColors.badgePurpleBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(next.status.name),
                      style: AppFonts.dmSans(
                        color: AppColors.badgePurpleText,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, color: AppColors.metaText, size: 16),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('h:mm a').format(next.timeSlot),
                    style: AppFonts.dmSans(
                      color: AppColors.metaText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                next.reason,
                style: AppFonts.fraunces(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                next.vetName,
                style: AppFonts.dmSans(
                  color: AppColors.badgePurpleText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pet: ${next.petName}  ·  ${DateFormat('EEE, MMM d').format(next.appointmentDate)}',
                style: AppFonts.dmSans(color: AppColors.metaText, fontSize: 12),
              ),
            ],
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
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: AppDecor.card(),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: AppDecor.squareChip(),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: AppFonts.caption(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetHealthCard extends StatelessWidget {
  final String emoji, name, species, status;
  final String? profileImageUrl;

  const _PetHealthCard({
    required this.emoji,
    required this.name,
    required this.species,
    required this.status,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (profileImageUrl != null && profileImageUrl!.isNotEmpty)
              ? Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: profileImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) =>
                        Text(emoji, style: const TextStyle(fontSize: 36)),
                  ),
                )
              : Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(name, style: AppFonts.fraunces(fontSize: 16)),
          Text(species, style: AppFonts.caption(color: AppColors.metaText)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.healthGreenBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.healthGreen,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.healthGreen,
                  ),
                ),
              ],
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
      decoration: AppDecor.card(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: AppDecor.squareChip(
              color: done ? AppColors.healthGreenBg : AppColors.chipBg,
            ),
            child: Icon(
              icon,
              color: done ? AppColors.healthGreen : AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.bodyBold()),
                Text(
                  subtitle,
                  style: AppFonts.caption(color: AppColors.metaText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: done ? AppColors.healthGreenBg : AppColors.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  done ? 'Done' : 'Pending',
                  style: AppFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: done ? AppColors.healthGreen : AppColors.primary,
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

class NewsArticle {
  final String title;
  final String source;
  final String? imageUrl;
  final String url;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.source,
    this.imageUrl,
    required this.url,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
      imageUrl: json['urlToImage'],
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}
