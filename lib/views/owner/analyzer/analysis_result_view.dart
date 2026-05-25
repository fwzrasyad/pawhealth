import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/smart_analyzer_controller.dart';
import '../../owner/booking/book_appointment_view.dart';
import 'smart_analyzer_intro_view.dart';

class AnalysisResultView extends StatelessWidget {
  const AnalysisResultView({super.key});

  
  

  Color _confidenceColor(double score) {
    if (score >= 0.85) return Colors.green;
    if (score >= 0.65) return Colors.orange;
    return Colors.red;
  }

  String _confidenceLabel(double score) {
    if (score >= 0.85) return 'High Confidence';
    if (score >= 0.65) return 'Moderate Confidence';
    return 'Low Confidence';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SmartAnalyzerController>();
    final scan = controller.currentScanResult;

    if (scan == null) {
      return const Scaffold(
          body: Center(child: Text('No scan result available.')));
    }

    final pct = (scan.confidenceScore * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: Stack(
        children: [
          // Top image / placeholder area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              color: const Color(0xFFEDE0FF),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 8),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3),
                    ),
                    child: Icon(Icons.pets, size: 60, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Scan captured ${DateFormat('MMM d, yyyy').format(scan.scanDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  controller.resetScan();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SmartAnalyzerIntroView()),
                    (route) => false,
                  );
                },
              ),
            ),
          ),

          // Scrollable result content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.38 - 24),

                  // Result Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Result header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.chipBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'AI Result',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Detected label
                        Text(
                          scan.aiResultLabel,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Confidence meter
                        Row(
                          children: [
                            Text(
                              'Confidence',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$pct% — ${_confidenceLabel(scan.confidenceScore)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _confidenceColor(scan.confidenceScore),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: scan.confidenceScore,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _confidenceColor(scan.confidenceScore)),
                            minHeight: 10,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // What this means card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '💡 What this means',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The AI detected signs consistent with "${scan.aiResultLabel}" based on the visual features in your photo. Please consult a veterinarian for a proper diagnosis and treatment plan.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Medical disclaimer
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.amber.shade700, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This is a preliminary AI assessment, not a veterinary diagnosis. Always seek professional veterinary advice for your pet\'s health.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Primary action: Book Vet
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                            label: const Text(
                              'Book Vet Appointment',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BookAppointmentView()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Secondary action: Save to log
                        _SaveToLogButton(scan: scan),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveToLogButton extends StatefulWidget {
  final dynamic scan;
  const _SaveToLogButton({required this.scan});

  @override
  State<_SaveToLogButton> createState() => _SaveToLogButtonState();
}

class _SaveToLogButtonState extends State<_SaveToLogButton> {
  
  bool _saved = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(
          _saved ? Icons.check_circle : Icons.save_outlined,
          color: _saved ? Colors.green : AppColors.primary,
          size: 20,
        ),
        label: Text(
          _saved ? 'Saved to Pet Log!' : 'Save to Pet Log',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: _saved ? Colors.green : AppColors.primary,
          ),
        ),
        onPressed: _saved || _saving
            ? null
            : () async {
                setState(() => _saving = true);
                final ok =
                    await context.read<SmartAnalyzerController>().saveScanToLog();
                setState(() {
                  _saving = false;
                  _saved = ok;
                });
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Scan saved to pet log!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: _saved ? Colors.green : AppColors.primary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
