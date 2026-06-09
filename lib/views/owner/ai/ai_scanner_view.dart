import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../controllers/smart_analyzer_controller.dart';
import '../../../controllers/pet_controller.dart';
import 'ai_loading_view.dart';

class SmartAnalyzerIntroView extends StatelessWidget {
  const SmartAnalyzerIntroView({super.key});

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
      // Kick off analysis before pushing the route to ensure state is ready
      final analysisFuture = controller.analyzeImage(petId: petId);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnalyzingLoadingView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      body: Column(
        children: [
          _buildHero(context),
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    children: [
                      // Scan zone card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C1D95),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            Positioned(
                              top: -40,
                              right: -40,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -20,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 28,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    margin: const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.document_scanner_outlined,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Ready to scan',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Take or upload a clear photo of your cat's affected area for analysis",
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.6),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _onPickImage(context, ImagePickerSource.camera),
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 17,
                              ),
                              label: const Text(
                                'Camera',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _onPickImage(context, ImagePickerSource.gallery),
                              icon: const Icon(
                                Icons.photo_outlined,
                                color: Color(0xFF7C3AED),
                                size: 17,
                              ),
                              label: const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                side: const BorderSide(
                                  color: Color(0xFFEDE8F8),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Detectable conditions card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDE8F8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.biotech_outlined,
                                  color: Color(0xFF7C3AED),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detectable conditions',
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A0F2E),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDB2777),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🐱', style: TextStyle(fontSize: 11)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Cats only',
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                "Ear mites",
                                "Feline acne",
                                "Fleas",
                                "Healthy cat",
                                "Ringworm",
                                "Scabies",
                              ]
                                  .map(
                                    (chipText) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        chipText,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Disclaimer card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Preliminary scan only',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'This scan provides an early indication only and is not a substitute for a professional veterinary diagnosis. Always consult a licensed vet for medical advice.',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 11,
                                      color: Color(0xFFB45309),
                                      height: 1.5,
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
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
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AI Analyzer',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan your pet for early health detection',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
