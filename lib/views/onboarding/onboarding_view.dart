import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = [
    _OnboardingSlide(
      emoji: '🔬',
      color: Color(0xFFEDE0FF),
      iconBg: AppColors.chipBg,
      title: 'Smart AI Analyzer',
      subtitle:
          'Simply snap a photo of your pet\'s visible symptoms. Our AI engine delivers a preliminary health assessment in seconds — helping you know when it\'s time to see a vet.',
    ),
    _OnboardingSlide(
      emoji: '📅',
      color: Color(0xFFE0F2FF),
      iconBg: Color(0xFFDCEEFF),
      title: 'Seamless Scheduling',
      subtitle:
          'Browse top-rated veterinarians, check real-time availability, and book an appointment — all without a single phone call.',
    ),
    _OnboardingSlide(
      emoji: '📋',
      color: Color(0xFFE0FFF4),
      iconBg: Color(0xFFCCF5E3),
      title: 'Centralized Health Records',
      subtitle:
          'Keep every vaccine, prescription, and medical document organized in one secure place. Access your pet\'s full history anytime, anywhere.',
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
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
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'Skip',
                    style: AppFonts.body(color: AppColors.metaText, fontSize: 14),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration — rounded square
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: slide.color,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: slide.iconBg,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  slide.emoji,
                                  style: const TextStyle(fontSize: 56),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 48),

                        Text(
                          slide.title,
                          style: AppFonts.headline(fontSize: 26),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: AppFonts.body(
                            fontSize: 15,
                            color: AppColors.mutedText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page dots — rounded rectangles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.navInactive,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            // Bottom button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: AppDecor.ctaButton(),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: AppFonts.button(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String emoji;
  final Color color;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.emoji,
    required this.color,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });
}
