import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/pet_controller.dart';
import '../../../models/pet_model.dart';
import '../medical_record_list_view.dart';
import '../daily_routine_form_view.dart';
import '../ai/ai_scanner_view.dart';
import 'add_edit_pet_view.dart';

class PetDetailView extends StatelessWidget {
  const PetDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final pet = controller.selectedPet;

    if (pet == null) {
      return const Scaffold(body: Center(child: Text('No pet selected')));
    }

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: Stack(
        children: [
          // Hero photo area — DO NOT TOUCH
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              clipBehavior: Clip.hardEdge,

              child:
                  (pet.profileImageUrl != null &&
                      pet.profileImageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: pet.profileImageUrl!,

                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          _emoji(pet.species),
                          style: const TextStyle(fontSize: 90),
                        ),
                      ),
                    )
                  : Center(
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
                              color: Color(0xFF1A0F2E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            '${pet.species} • ${pet.breed}',
                            style: const TextStyle(
                              color: Color(0xFF9B8CB8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Info Grid
                        _buildInfoGrid(pet),

                        const SizedBox(height: 32),

                        // Quick Actions Label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'QUICK ACTIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9B8CB8),
                              letterSpacing: 0.08,
                            ),
                          ),
                        ),

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
            child: GestureDetector(
              onTap: () {
                controller.clearSelectedPet();
                Navigator.pop(context);
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: Color(0xFF7C3AED),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          // Edit button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditPetView(petToEdit: pet),
                  ),
                );
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF7C3AED),
                    size: 18,
                  ),
                ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 16),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9B8CB8),
              letterSpacing: 0.06,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A0F2E),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Pet pet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Row 1: Species, Gender, Age
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.category_outlined,
                  label: 'Species',
                  value: pet.species,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.transgender_outlined,
                  label: 'Gender',
                  value: pet.gender,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: '${pet.age} yrs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Breed, Weight
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pets_outlined,
                  label: 'Breed',
                  value: pet.breed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: '${pet.weight} kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Pet pet) {
    final actions = [
      {
        'icon': Icons.medical_services_outlined,
        'label': 'Medical Records',
        'subtitle': 'Vaccines, Docs',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicalRecordListView(pet: pet)),
        ),
      },
      {
        'icon': Icons.document_scanner_outlined,
        'label': 'Smart Analyzer',
        'subtitle': 'AI Symptom Check',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AIScannerView()),
          );
        },
      },
    ];

    return Column(
      children: actions.map((a) {
        return GestureDetector(
          onTap: a['onTap'] as VoidCallback,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDE8F8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Icon(
                      a['icon'] as IconData,
                      color: const Color(0xFF7C3AED),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['label'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A0F2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B8CB8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFC4B5FD),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
