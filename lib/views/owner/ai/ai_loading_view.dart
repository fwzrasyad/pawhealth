import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../controllers/smart_analyzer_controller.dart';
import 'ai_results_view.dart';

class AnalyzingLoadingView extends StatefulWidget {
  const AnalyzingLoadingView({super.key});

  @override
  State<AnalyzingLoadingView> createState() => _AnalyzingLoadingViewState();
}

class _AnalyzingLoadingViewState extends State<AnalyzingLoadingView>
    with SingleTickerProviderStateMixin {
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

    // Once analysis finishes, navigate to result — deferred to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitForResult());
  }

  Future<void> _waitForResult() async {
    final controller = context.read<SmartAnalyzerController>();
    // Poll until analyzing is done
    while (controller.isAnalyzing) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    
    // Schedule navigation for after the current frame to avoid navigator locks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.currentScanResult != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AIResultsView(
              imageFile: File(controller.selectedImagePath ?? ''),
              label: controller.currentScanResult!.aiResultLabel,
              confidence: controller.currentScanResult!.confidenceScore,
            ),
          ),
        );
      } else {
        // Analysis failed
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to analyze image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.document_scanner_outlined,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
              ),

              SizedBox(height: 48),

              Text(
                'Analyzing Symptoms...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Our AI is carefully reviewing the image for visible symptoms. This takes just a moment.',
                style: TextStyle(
                  fontSize: 14,
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
                  color: AppColors.primary,
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
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔒  Your photo is processed locally and never stored on external servers.',
                  style: TextStyle(
                    fontSize: 12,
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
          color: done ? AppColors.primary : Colors.grey.shade400,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: done ? Colors.black : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
