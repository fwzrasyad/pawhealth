import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/pet_controller.dart';
import '../../../models/pet_model.dart';
import '../medical_record_list_view.dart';
import '../ai/ai_scanner_view.dart';
import 'add_edit_pet_view.dart';
import '../../../utils/vaccine_utils.dart';
import '../recovery_log_form_view.dart';
import '../../../models/vaccination_record_model.dart';

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

                        // Active Recovery Plan (if any)
                        _buildActiveRecoveryPlan(context, pet),

                        // Vaccination Checklist
                        _buildVaccinationChecklist(context, pet),

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

  Widget _buildActiveRecoveryPlan(BuildContext context, Pet pet) {
    if (pet.recoveryPlans.isEmpty) return const SizedBox.shrink();
    
    final activePlan = pet.recoveryPlans.firstWhere(
      (p) => p.status == 'active',
      orElse: () => pet.recoveryPlans.first,
    );

    if (activePlan.status != 'active') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'ACTIVE RECOVERY PLAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9B8CB8),
              letterSpacing: 0.08,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDE8F8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.healing, color: Color(0xFF7C3AED), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Recovery Tracking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A0F2E),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Day 1 of ${activePlan.durationDays}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activePlan.instructions,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RecoveryLogFormView(plan: activePlan)),
                    );
                  },
                  icon: const Icon(Icons.add_chart, size: 16),
                  label: const Text('Add Daily Log'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationChecklist(BuildContext context, Pet pet) {
    if (pet.species.toLowerCase() == 'bird') return const SizedBox.shrink();

    final core = VaccineUtils.coreVaccines[pet.species.toLowerCase()] ?? [];
    final nonCore = VaccineUtils.nonCoreVaccines[pet.species.toLowerCase()] ?? [];
    if (core.isEmpty && nonCore.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'VACCINATION CHECKLIST',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9B8CB8),
              letterSpacing: 0.08,
            ),
          ),
        ),
        if (core.isNotEmpty) ...[
          const Text('Core Vaccines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A0F2E))),
          const SizedBox(height: 8),
          ...core.map((v) => _buildVaccineItem(pet, v, true)),
          const SizedBox(height: 16),
        ],
        if (nonCore.isNotEmpty) ...[
          const Text('Non-Core Vaccines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A0F2E))),
          const SizedBox(height: 8),
          ...nonCore.map((v) => _buildVaccineItem(pet, v, false)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showAddVaccineDialog(context, pet),
            icon: const Icon(Icons.add, size: 16, color: Color(0xFF16A34A)),
            label: const Text('Add Vaccine Log', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF0FDF4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddVaccineDialog(BuildContext context, Pet pet) {
    final speciesCore = VaccineUtils.coreVaccines[pet.species.toLowerCase()] ?? [];
    final speciesNonCore = VaccineUtils.nonCoreVaccines[pet.species.toLowerCase()] ?? [];

    final availableCore = speciesCore.where((v) => !pet.vaccinations.any((pv) => 
      pv.vaccineName.toLowerCase() == v.toLowerCase() || 
      (pv.isCore && pv.vaccineName.toLowerCase().contains(v.split(' ')[0].toLowerCase()))
    )).toList();

    final availableNonCore = speciesNonCore.where((v) => !pet.vaccinations.any((pv) => 
      pv.vaccineName.toLowerCase() == v.toLowerCase() || 
      (!pv.isCore && pv.vaccineName.toLowerCase().contains(v.split(' ')[0].toLowerCase()))
    )).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Add Vaccine Log',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A0F2E),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Select a vaccine to add to your pet\'s medical record.',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shrinkWrap: true,
                  children: [
                    if (availableCore.isEmpty && availableNonCore.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'Your pet is fully vaccinated!',
                            style: TextStyle(fontFamily: 'Figtree', color: Color(0xFF166534), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    if (availableCore.isNotEmpty) ...[
                      const Text(
                        'Core Vaccines',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B8CB8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...availableCore.map((v) => _buildVaccineSelectionTile(context, pet, v, true)),
                      const SizedBox(height: 24),
                    ],
                    if (availableNonCore.isNotEmpty) ...[
                      const Text(
                        'Non-Core Vaccines',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B8CB8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...availableNonCore.map((v) => _buildVaccineSelectionTile(context, pet, v, false)),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVaccineSelectionTile(BuildContext context, Pet pet, String vaccineName, bool isCore) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isSubmitting = false;

        return GestureDetector(
          onTap: isSubmitting ? null : () async {
            setState(() => isSubmitting = true);
            try {
              final petCtrl = context.read<PetController>();
              await petCtrl.addVaccinationRecord(pet.petId, VaccinationRecord(
                id: '',
                petId: pet.petId,
                vaccineName: vaccineName,
                isCore: isCore,
                dateAdministered: DateTime.now(),
              ));
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              if (context.mounted) {
                setState(() => isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDE8F8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccineName,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A0F2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCore ? 'Recommended for all ${pet.species.toLowerCase()}s' : 'Based on lifestyle & risk',
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSubmitting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                  )
                else
                  const Icon(Icons.add_circle, color: Color(0xFF7C3AED), size: 24),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildVaccineItem(Pet pet, String vaccineName, bool isCore) {
    final hasVaccine = pet.vaccinations.any((v) =>
        v.vaccineName.toLowerCase() == vaccineName.toLowerCase() ||
        (v.isCore && v.vaccineName.toLowerCase().contains(vaccineName.split(' ')[0].toLowerCase())));

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasVaccine ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: hasVaccine ? const Color(0xFFBBF7D0) : const Color(0xFFEDE8F8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              vaccineName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasVaccine ? FontWeight.w600 : FontWeight.w500,
                color: hasVaccine ? const Color(0xFF166534) : const Color(0xFF4B5563),
              ),
            ),
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
