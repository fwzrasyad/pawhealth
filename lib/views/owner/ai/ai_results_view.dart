import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../booking/book_appointment_view.dart';

class AIResultsView extends StatelessWidget {
  final File imageFile;
  final String label;
  final double confidence;

  const AIResultsView({
    super.key,
    required this.imageFile,
    required this.label,
    required this.confidence,
  });

  // Data Map for the 6 labels
  static const Map<String, Map<String, String>> diseaseData = {
    'Ear Mites': {
      'Information': 'Ear mites are common parasites that live in the ear canal. They are highly contagious and can cause intense itching, head shaking, and dark, coffee-ground-like discharge.',
      'Care Steps': '1. Do not use Q-tips to clean the ear.\n2. Keep infected pets separated from other animals.\n3. Veterinary prescribed ear drops are required for effective treatment.',
    },
    'Feline Acne': {
      'Information': 'Feline acne is a condition where blackheads or pimples form on a cat\'s chin. It can be triggered by stress, poor grooming, or plastic food bowls harboring bacteria.',
      'Care Steps': '1. Switch from plastic bowls to stainless steel or ceramic.\n2. Clean the chin area daily with a vet-approved gentle cleanser.\n3. Do not pop or pick at the bumps.',
    },
    'Fleas': {
      'Information': 'Fleas are small, wingless insects that feed on the blood of animals. They cause severe itching and can transmit other diseases like tapeworms.',
      'Care Steps': '1. Use a fast-acting flea treatment approved by your vet.\n2. Wash all pet bedding in hot water.\n3. Vacuum carpets and furniture to remove flea eggs and larvae.',
    },
    'Healthy Cat': {
      'Information': 'No visible signs of the trained skin conditions or parasites were detected. Your cat\'s skin and coat appear normal in the scanned area.',
      'Care Steps': '1. Continue your regular grooming routine.\n2. Maintain a balanced diet.\n3. Schedule routine veterinary checkups to ensure overall health.',
    },
    'Ringworm': {
      'Information': 'Ringworm is a highly contagious fungal infection of the skin, hair, or claws. It often presents as circular, bald, scaly patches and can be transmitted to humans.',
      'Care Steps': '1. Wash your hands thoroughly after handling your pet.\n2. Isolate the pet to prevent spreading the fungus.\n3. Requires vet-prescribed antifungal medication (topical or oral).',
    },
    'Scabies': {
      'Information': 'Also known as Sarcoptic mange, scabies is caused by mites burrowing into the skin. It causes intense itching, hair loss, and crusty skin, and is highly contagious.',
      'Care Steps': '1. Keep the pet isolated from other animals.\n2. Wash bedding in hot water and sanitize the environment.\n3. Immediate veterinary intervention is needed for prescription parasiticides.',
    },
    'Uncertain': {
      'Information': 'The AI could not identify the condition with high confidence (>95%). This can happen if the image is blurry, poorly lit, or does not clearly show a recognized condition.',
      'Care Steps': '1. Take a clearer, closer photo of the affected area.\n2. Ensure the area is well-lit.\n3. If you remain concerned, consult a veterinarian.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = label.toLowerCase() == 'healthy cat';
    final bool isUncertain = label.toLowerCase() == 'uncertain';
    final data = diseaseData[label] ?? {
      'Information': 'Information not available for this condition.',
      'Care Steps': 'Consult your veterinarian for appropriate care steps.'
    };

    final int confidencePercentage = (confidence * 100).round();
    
    // The required pre-filled reason text
    final String preFilledReason = isUncertain 
        ? "Seeking clinical confirmation for uncertain symptoms."
        : "PawHealth AI detected a $confidencePercentage% probability of $label. Seeking clinical confirmation and treatment.";

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image and basic result
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                imageFile,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUncertain 
                                        ? const Color(0xFFF3EFFF)
                                        : (isHealthy ? const Color(0xFFECFDF3) : const Color(0xFFFEF2F2)),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    isUncertain 
                                        ? Icons.help_outline_rounded 
                                        : (isHealthy ? Icons.check_circle : Icons.warning_rounded),
                                    color: isUncertain 
                                        ? const Color(0xFF7C3AED)
                                        : (isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A0F2E),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isUncertain 
                                              ? const Color(0xFF7C3AED)
                                              : (isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isUncertain 
                                              ? 'Too low ($confidencePercentage%)' 
                                              : '$confidencePercentage% Confidence',
                                          style: const TextStyle(
                                            fontFamily: 'Figtree',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Information Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Information', Icons.info_outline),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFEDE8F8)),
                              ),
                              child: Text(
                                data['Information']!,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 14,
                                  color: Color(0xFF1A0F2E),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            _buildSectionHeader('Care Steps', Icons.health_and_safety_outlined),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFEDE8F8)),
                              ),
                              child: Text(
                                data['Care Steps']!,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 14,
                                  color: Color(0xFF1A0F2E),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Smart Recommender Action Card
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isUncertain 
                              ? const Color(0xFFF3EFFF)
                              : (isHealthy ? const Color(0xFFECFDF3) : const Color(0xFFFEF2F2)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUncertain 
                              ? const Color(0xFFDDD8F5)
                              : (isHealthy ? const Color(0xFFD1FAE5) : const Color(0xFFFECACA)),
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isUncertain 
                                      ? Icons.camera_alt_outlined 
                                      : (isHealthy ? Icons.thumb_up_alt_outlined : Icons.medical_services_outlined),
                                  color: isUncertain 
                                      ? const Color(0xFF7C3AED)
                                      : (isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isUncertain 
                                      ? 'Please Try Again'
                                      : (isHealthy ? 'Recommendation' : 'Urgent Action Required'),
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isUncertain 
                                        ? const Color(0xFF5B4B8A)
                                        : (isHealthy ? const Color(0xFF166534) : const Color(0xFF991B1B)),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isUncertain
                                  ? 'We couldn\'t confidently analyze the image. Please take a clearer photo, or consult a clinic if you are concerned.'
                                  : (isHealthy 
                                      ? 'Continue your standard daily care. Consider booking a routine checkup to keep your pet in top shape.'
                                      : 'A potential skin condition or parasite has been detected. We highly recommend booking an appointment with a clinic for proper diagnosis and treatment.'),
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 13,
                                color: isUncertain 
                                    ? const Color(0xFF7C3AED)
                                    : (isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isUncertain) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BookAppointmentView(
                                          initialReason: preFilledReason,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUncertain 
                                      ? const Color(0xFF7C3AED)
                                      : (isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isUncertain 
                                      ? 'Scan Again'
                                      : (isHealthy ? 'Book Routine Checkup' : 'Find a Clinic Now'),
                                  style: const TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Analysis Results',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7C3AED), size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1A0F2E),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}