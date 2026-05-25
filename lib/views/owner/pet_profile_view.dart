import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../controllers/pet_controller.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/health_journal_model.dart';
import 'daily_routine_form_view.dart';
import 'health_journal_form_view.dart';
import 'package:intl/intl.dart';

class PetProfileView extends StatefulWidget {
  final String petId;

  const PetProfileView({super.key, required this.petId});

  @override
  State<PetProfileView> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<PetProfileView> {
  List<HealthJournalEntry> _healthJournalEntries = [];
  bool _loadingJournal = false;

  @override
  void initState() {
    super.initState();
    _fetchHealthJournalEntries();
  }

  Future<void> _fetchHealthJournalEntries() async {
    setState(() => _loadingJournal = true);
    final petController = context.read<PetController>();
    final entries = await petController.fetchHealthJournalEntries(widget.petId);
    if (mounted) {
      setState(() {
        _healthJournalEntries = entries;
        _loadingJournal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final petController = Provider.of<PetController>(context);
    final apptController = Provider.of<AppointmentController>(context);
    final pet = petController.pets.firstWhere((p) => p.petId == widget.petId);
    
    final medicalHistory = apptController.pastVisits
        .where((a) => a.petId == widget.petId && a.medicalRecord != null)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
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
                    color: AppColors.primary,
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
                  
                  // Medical History Section
                  const Text(
                    'Medical History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  medicalHistory.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No medical history available.', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medicalHistory.length,
                          itemBuilder: (context, index) {
                            final appt = medicalHistory[index];
                            final record = appt.medicalRecord!;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
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
                                        DateFormat('EEE, MMM dd, yyyy').format(appt.appointmentDate),
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkText),
                                      ),
                                      Text(
                                        appt.vetName,
                                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Diagnosis: ${record.diagnosis}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    record.doctorNotes ?? record.treatment ?? 'No clinical notes provided',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  
                  const SizedBox(height: 40),
                  
                  // Health Journal Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recovery & Health Journal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HealthJournalFormView(petId: pet.petId)),
                          ).then((_) {
                            // Refresh health journal entries when returning
                            _fetchHealthJournalEntries();
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Add Entry'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      )
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  _loadingJournal
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      : _healthJournalEntries.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No health journal entries yet.', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _healthJournalEntries.length,
                              itemBuilder: (context, index) {
                                final entry = _healthJournalEntries[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
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
                                            DateFormat('EEE, MMM dd, yyyy').format(entry.date),
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkText),
                                          ),
                                          if (entry.symptomTags.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.chipBg,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${entry.symptomTags.length} symptom${entry.symptomTags.length > 1 ? 's' : ''}',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (entry.symptomTags.isNotEmpty) ...[
                                        SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: entry.symptomTags.map((tag) {
                                            return Chip(
                                              label: Text(
                                                tag,
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                              backgroundColor: AppColors.primary,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Text(
                                        entry.observations,
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),                ],
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
              Text(label1, style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.darkText)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value2, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.darkText)),
            ],
          ),
        ),
      ],
    );
  }
}