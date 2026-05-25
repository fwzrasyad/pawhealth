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
  };

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = label.toLowerCase() == 'healthy cat';
    final data = diseaseData[label] ?? {
      'Information': 'Information not available for this condition.',
      'Care Steps': 'Consult your veterinarian for appropriate care steps.'
    };

    final int confidencePercentage = (confidence * 100).round();
    
    // The required pre-filled reason text
    final String preFilledReason = "PawHealth AI detected a $confidencePercentage% probability of $label. Seeking clinical confirmation and treatment.";

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analysis Results',
          style: AppFonts.bodyBold(fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image and basic result
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isHealthy ? Icons.check_circle : Icons.warning_rounded,
                        color: isHealthy ? Colors.green : Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Confidence: $confidencePercentage%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Information', Icons.info_outline),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Text(
                      data['Information']!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Care Steps', Icons.health_and_safety_outlined),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Text(
                      data['Care Steps']!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Smart Recommender Action Card
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHealthy ? const Color(0xFFC8E6C9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isHealthy ? Icons.thumb_up_alt_outlined : Icons.medical_services_outlined,
                        color: isHealthy ? Colors.green.shade700 : Colors.deepOrange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isHealthy ? 'Recommendation' : 'Urgent Action Required',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isHealthy ? Colors.green.shade900 : Colors.deepOrange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHealthy 
                        ? 'Continue your standard daily care. Consider booking a routine checkup to keep your pet in top shape.'
                        : 'A potential skin condition or parasite has been detected. We highly recommend booking an appointment with a clinic for proper diagnosis and treatment.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isHealthy ? Colors.green.shade900 : Colors.deepOrange.shade900,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppointmentView(
                              initialReason: preFilledReason,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHealthy ? Colors.green.shade600 : Colors.deepOrange.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        isHealthy ? 'Book Routine Checkup' : 'Find a Clinic Now',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}