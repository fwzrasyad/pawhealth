import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pet_controller.dart';
import 'daily_routine_form_view.dart';
import 'package:intl/intl.dart';

class PetProfileView extends StatelessWidget {
  final String petId;

  const PetProfileView({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    final petController = Provider.of<PetController>(context);
    final pet = petController.pets.firstWhere((p) => p.petId == petId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF8A2BE2),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pet.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                color: const Color(0xFFE0F2F1),
                child: Center(
                  child: Icon(
                    pet.species.toLowerCase() == 'cat' ? Icons.pets : Icons.cruelty_free,
                    size: 100,
                    color: const Color(0xFF8A2BE2),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Species', pet.species, 'Breed', pet.breed),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFFF0F0F0)),
                        ),
                        _buildInfoRow(
                          'Age', 
                          '${pet.age} years old',
                          'Gender', 
                          pet.gender
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFFF0F0F0)),
                        ),
                        _buildInfoRow('Current Weight', '${pet.weight} kg', 'ID', '#${pet.petId.substring(4)}'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Daily Routine Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Routines',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DailyRoutineFormView(petId: pet.petId)),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Log'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF8A2BE2)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  pet.dailyRoutines.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No daily routines logged yet.', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pet.dailyRoutines.length,
                          itemBuilder: (context, index) {
                            final log = pet.dailyRoutines[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEBEBEB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('E, MMM dd, yyyy').format(log.date),
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2F1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${log.weight} kg',
                                          style: const TextStyle(color: Color(0xFF00897B), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Activity: ${log.activityLevel}', style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('Diet: ${log.dietNotes}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF333333))),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF333333))),
            ],
          ),
        ),
      ],
    );
  }
}
