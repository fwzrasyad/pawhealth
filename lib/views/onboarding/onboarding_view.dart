import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  static const _purple = Color(0xFF8A2BE2);

  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = [
    _OnboardingSlide(
      emoji: '🔬',
      color: Color(0xFFEDE0FF),
      iconBg: Color(0xFFD4BBFF),
      title: 'Smart AI Analyzer',
      subtitle:
          'Simply snap a photo of your pet\'s visible symptoms. Our AI engine delivers a preliminary health assessment in seconds — helping you know when it\'s time to see a vet.',
    ),
    _OnboardingSlide(
      emoji: '📅',
      color: Color(0xFFE0F2FF),
      iconBg: Color(0xFFBAE0FF),
      title: 'Seamless Scheduling',
      subtitle:
          'Browse top-rated veterinarians, check real-time availability, and book an appointment — all without a single phone call.',
    ),
    _OnboardingSlide(
      emoji: '📋',
      color: Color(0xFFE0FFF4),
      iconBg: Color(0xFFB3F5DC),
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
      backgroundColor: Colors.white,
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
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
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
                        // Illustration
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: slide.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: slide.iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  slide.emoji,
                                  style: const TextStyle(fontSize: 60),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade500,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page dots
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
                    color: active ? _purple : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
