import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/smart_analyzer_controller.dart';
import '../../../controllers/pet_controller.dart';
import 'analyzing_loading_view.dart';

class SmartAnalyzerIntroView extends StatelessWidget {
  const SmartAnalyzerIntroView({super.key});

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  void _onPickImage(BuildContext context, ImagePickerSource source) async {
    final controller = context.read<SmartAnalyzerController>();
    final petCtrl = context.read<PetController>();

    // Choose the selected pet, or fallback to the first available pet
    final petId =
        petCtrl.selectedPet?.petId ??
        (petCtrl.pets.isNotEmpty ? petCtrl.pets.first.petId : 'default_pet');

    controller.resetScan();
    final picked = await controller.pickImage(source);
    if (picked && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnalyzingLoadingView()),
      );
      // Kick off analysis
      await controller.analyzeImage(petId: petId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Smart Analyzer',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Hero Icon Area
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: _lightPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.search, size: 56, color: _purple),
                          Positioned(
                            bottom: 26,
                            right: 26,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: _purple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_fix_high,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'AI Symptom Checker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Upload or capture a photo of your pet\'s visible symptoms. Our AI will provide a preliminary assessment to guide your next steps.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // How it Works row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStep(
                          '1',
                          'Take or\nUpload Photo',
                          Icons.camera_alt_outlined,
                        ),
                        _buildArrow(),
                        _buildStep(
                          '2',
                          'AI Scans\nSymptoms',
                          Icons.document_scanner_outlined,
                        ),
                        _buildArrow(),
                        _buildStep(
                          '3',
                          'Get\nResults',
                          Icons.task_alt_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Disclaimer Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber.shade700,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Important Disclaimer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.amber.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'This tool provides a preliminary AI-based assessment only. It is NOT a substitute for a professional veterinary diagnosis. Always consult a licensed vet for medical decisions.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: Colors.amber.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () =>
                            _onPickImage(context, ImagePickerSource.camera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: _purple,
                          size: 20,
                        ),
                        label: const Text(
                          'Upload from Gallery',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _purple,
                          ),
                        ),
                        onPressed: () =>
                            _onPickImage(context, ImagePickerSource.gallery),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: _purple, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: _lightPurple,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _purple, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'Poppins',
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 14);
  }
}
