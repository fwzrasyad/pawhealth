import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/smart_analyzer_controller.dart';
import 'analysis_result_view.dart';

class AnalyzingLoadingView extends StatefulWidget {
  const AnalyzingLoadingView({super.key});

  @override
  State<AnalyzingLoadingView> createState() => _AnalyzingLoadingViewState();
}

class _AnalyzingLoadingViewState extends State<AnalyzingLoadingView>
    with SingleTickerProviderStateMixin {
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Once analysis finishes, navigate to result
    _waitForResult();
  }

  Future<void> _waitForResult() async {
    final controller = context.read<SmartAnalyzerController>();
    // Poll until analyzing is done
    while (controller.isAnalyzing) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (mounted && controller.currentScanResult != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AnalysisResultView()),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Pulsing scanner icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    size: 72,
                    color: _purple,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              const Text(
                'Analyzing Symptoms...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Our AI is carefully reviewing the image for visible symptoms. This takes just a moment.',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Progress indicator
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: _purple,
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(height: 16),

              // Scanning steps
              _buildScanStep('Uploading image...', true),
              const SizedBox(height: 8),
              _buildScanStep('Running symptom detection model...', true),
              const SizedBox(height: 8),
              _buildScanStep('Generating assessment report...', false),

              const Spacer(),

              // Bottom disclaimer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔒  Your photo is processed locally and never stored on external servers.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanStep(String label, bool done) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: done ? _purple : Colors.grey.shade400,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: done ? Colors.black : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
