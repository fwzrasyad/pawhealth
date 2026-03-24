import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/medical_record_controller.dart';
import '../../models/pet_model.dart';
import 'add_medical_record_view.dart';
import 'medical_record_detail_view.dart';

class MedicalRecordListView extends StatelessWidget {
  final Pet pet; // Accept the clicked pet

  const MedicalRecordListView({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicalRecordController>();
    // In a real app we'd pass pet.id. Here we use the mock pet ID from the controller
    // or you could use controller.getRecordsByPet(pet.id) if schemas align perfectly.
    // For now we'll match mock data since Phase 3 requested mock data integration.
    final records = controller.getRecordsByPet(controller.mockPetId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Health History',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins', 
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: Column(
        children: [
          // Elegant Pet Details Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8A2BE2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.species} • ${pet.breed}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${pet.weight} kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // History Title section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Records Timeline',
                style: TextStyle(
                  color: const Color(0xFF333333).withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Timeline List
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Text(
                      'No medical records found.',
                      style: TextStyle(color: Color(0xFF333333), fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isDueSoon = record.nextDueDate != null &&
                          record.nextDueDate!.difference(DateTime.now()).inDays <= 30;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicalRecordDetailView(record: record),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A2BE2).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.medical_services_outlined,
                                  color: Color(0xFF8A2BE2),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.diagnosis,
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (record.vaccinationDate != null)
                                      Text(
                                        'Date: ${DateFormat.yMMMd().format(record.vaccinationDate!)}',
                                        style: TextStyle(
                                          color: const Color(0xFF333333).withValues(alpha: 0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    if (record.nextDueDate != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDueSoon
                                              ? Colors.orange.withValues(alpha: 0.1)
                                              : const Color(0xFF8A2BE2).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isDueSoon
                                                  ? Icons.warning_amber_rounded
                                                  : Icons.calendar_today_rounded,
                                              size: 14,
                                              color: isDueSoon
                                                  ? Colors.orange
                                                  : const Color(0xFF8A2BE2),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Due: ${DateFormat.yMMMd().format(record.nextDueDate!)}',
                                              style: TextStyle(
                                                color: isDueSoon
                                                    ? Colors.orange
                                                    : const Color(0xFF8A2BE2),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
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
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicalRecordView(),
            ),
          );
        },
        backgroundColor: const Color(0xFF8A2BE2),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
