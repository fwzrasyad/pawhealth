import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      {
        'emoji': '🔬',
        'step': '01 OF 03',
        'title': 'Smart AI\nAnalyzer',
        'description': 'Simply snap a photo of your pet\'s visible symptoms. Our AI engine delivers a preliminary health assessment in seconds.',
        'buttonLabel': 'Next',
      },
      {
        'emoji': '📅',
        'step': '02 OF 03',
        'title': 'Seamless\nScheduling',
        'description': 'Browse top-rated veterinarians, check real-time availability, and book an appointment — all without a single phone call.',
        'buttonLabel': 'Next',
      },
      {
        'emoji': '📋',
        'step': '03 OF 03',
        'title': 'Centralized\nHealth Records',
        'description': 'Keep every vaccine, prescription, and medical document organized in one secure place. Access your pet\'s full history anytime.',
        'buttonLabel': 'Get Started',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF5B21B6),
      body: PageView.builder(
        controller: _pageController,
        itemCount: slides.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) {
          final slide = slides[index];

          return Column(
            children: [
              // Hero Area
              Expanded(
                flex: 45,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Blob 1
                      Positioned(
                        top: -70,
                        left: -70,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D28D9).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      // Blob 2
                      Positioned(
                        bottom: -50,
                        right: -50,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C1D95).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      // Skip Button
                      Positioned(
                        top: 48,
                        right: 20,
                        child: GestureDetector(
                          onTap: _goToLogin,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      // Logo Row
                      Positioned(
                        top: 48,
                        left: 20,
                        child: Row(
                          children: const [
                            Icon(Icons.pets, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'PawHealth',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Center Content
                      Center(
                        child: Text(
                          slide['emoji'] as String,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // White Card
              Expanded(
                flex: 55,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE8F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          slide['step'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED),
                            letterSpacing: 0.06,
                          ),
                        ),
                      ),
                      // Title
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          slide['title'] as String,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A0F2E),
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                        ),
                      ),
                      // Description
                      Expanded(
                        child: Text(
                          slide['description'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9B8CB8),
                            height: 1.6,
                          ),
                        ),
                      ),
                      // Bottom Row
                      Container(
                        margin: const EdgeInsets.only(top: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dots
                            Row(
                              children: List.generate(3, (dotIndex) {
                                final active = dotIndex == index;
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: active ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: active ? const Color(0xFF7C3AED) : const Color(0xFFDDD8F5),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                            // Button
                            ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide['buttonLabel'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                                ],
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
        },
      ),
    );
  }
}
