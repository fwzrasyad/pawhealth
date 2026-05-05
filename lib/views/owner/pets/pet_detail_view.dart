import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/pet_controller.dart';
import '../../../models/pet_model.dart';
import '../medical_record_list_view.dart';
import '../daily_routine_form_view.dart';
import '../analyzer/smart_analyzer_intro_view.dart';
import 'add_edit_pet_view.dart';

class PetDetailView extends StatelessWidget {
  const PetDetailView({super.key});

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final pet = controller.selectedPet;

    if (pet == null) {
      return const Scaffold(body: Center(child: Text('No pet selected')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Hero photo area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: _lightPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: Text(
                  _emoji(pet.species),
                  style: const TextStyle(fontSize: 90),
                ),
              ),
            ),
          ),

          // Scrollable content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35 - 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Center(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            '${pet.species} • ${pet.breed}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Info Grid
                        _buildInfoGrid(pet),

                        const SizedBox(height: 32),

                        // Quick Actions Label
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Action Cards
                        _buildQuickActions(context, pet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  controller.clearSelectedPet();
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Edit button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: _purple),
                onPressed: () {
                  print('redirect');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditPetView(petToEdit: pet),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _emoji(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return '🐱';
      case 'dog':
        return '🐶';
      case 'rabbit':
        return '🐰';
      case 'bird':
        return '🦜';
      default:
        return '🐾';
    }
  }

  Widget _buildInfoGrid(Pet pet) {
    final infoItems = [
      {
        'label': 'Species',
        'value': pet.species,
        'icon': Icons.category_outlined,
      },
      {
        'label': 'Gender',
        'value': pet.gender,
        'icon': Icons.transgender_outlined,
      },
      {'label': 'Age', 'value': '${pet.age} yrs', 'icon': Icons.cake_outlined},
      {'label': 'Breed', 'value': pet.breed, 'icon': Icons.pets_outlined},
      {
        'label': 'Weight',
        'value': '${pet.weight} kg',
        'icon': Icons.monitor_weight_outlined,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        final item = infoItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'] as IconData,
                color: const Color(0xFF8A2BE2),
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                item['value'] as String,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, Pet pet) {
    final actions = [
      {
        'icon': Icons.today_outlined,
        'label': 'Log Daily\nRoutine',
        'subtitle': 'Diet, Weight, Activity',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DailyRoutineFormView(petId: pet.petId),
          ),
        ),
      },
      {
        'icon': Icons.medical_services_outlined,
        'label': 'Medical\nRecords',
        'subtitle': 'Vaccines, Docs',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicalRecordListView(pet: pet)),
        ),
      },
      {
        'icon': Icons.document_scanner_outlined,
        'label': 'Smart\nAnalyzer',
        'subtitle': 'AI Symptom Check',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SmartAnalyzerIntroView()),
          );
        },
      },
    ];

    return Column(
      children: actions.map((a) {
        return GestureDetector(
          onTap: a['onTap'] as VoidCallback,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3E8FF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    a['icon'] as IconData,
                    color: const Color(0xFF8A2BE2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (a['label'] as String).replaceAll('\n', ' '),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
