import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
import '../../../models/medical_record_model.dart';

class VetPatientRecordView extends StatelessWidget {
  final Appointment appointment;

  const VetPatientRecordView({super.key, required this.appointment});

  String _emojiForSpecies(String species) {
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

  @override
  Widget build(BuildContext context) {
    final vc = context.read<VetController>();
    final pet = vc.getPetById(appointment.petId);
    final records = vc.getPatientRecords(appointment.petId);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Patient Record'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: Text('Pet not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: AppColors.darkText),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: (pet.profileImageUrl != null && pet.profileImageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: pet.profileImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    _emojiForSpecies(pet.species),
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  _emojiForSpecies(pet.species),
                                  style: const TextStyle(fontSize: 44),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${pet.species} · ${pet.breed}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment context banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visit Reason',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                appointment.reason,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.healthGreenBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('h:mm a').format(appointment.timeSlot),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.completedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Basic Info Grid
                  const Text(
                    'Pet Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _InfoRow('Age', '${pet.age} years old'),
                        _InfoRow('Gender', pet.gender),
                        _InfoRow('Weight', '${pet.weight} kg'),
                        _InfoRow('Species', pet.species),
                        _InfoRow('Breed', pet.breed, isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recovery Plans
                  if (pet.recoveryPlans.isNotEmpty) ...[
                    const Text(
                      'Recovery Plans',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...pet.recoveryPlans.map(
                      (plan) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: plan.status == 'active' ? const Color(0xFFF7F5FF) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: plan.status == 'active' ? Border.all(color: const Color(0xFFEDE8F8)) : Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [
                            if (plan.status != 'active')
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.healing,
                                  size: 14,
                                  color: plan.status == 'active' ? const Color(0xFF7C3AED) : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Duration: ${plan.durationDays} days',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: plan.status == 'active' ? const Color(0xFF7C3AED) : AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: plan.status == 'active' ? const Color(0xFF7C3AED).withValues(alpha: 0.1) : AppColors.chipBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    plan.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: plan.status == 'active' ? const Color(0xFF7C3AED) : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _LogDetail(
                              icon: Icons.notes,
                              label: 'Instructions',
                              value: plan.instructions,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Vaccination History
                  if (pet.vaccinations.isNotEmpty) ...[
                    const Text(
                      'Vaccination History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pet.vaccinations.map((v) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.vaccines, size: 14, color: const Color(0xFF16A34A)),
                                  const SizedBox(width: 6),
                                  Text(
                                    v.vaccineName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('MMM d, yyyy').format(v.dateAdministered)} • ${v.isCore ? 'Core' : 'Non-Core'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Medical Records
                  const Text(
                    'Medical History',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No medical records found.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    )
                  else
                    ...records.map(
                      (record) => _MedicalRecordCard(record: record),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}

class _LogDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LogDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 7),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  const _MedicalRecordCard({required this.record});

  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_information_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.diagnosis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RecordRow(
            icon: Icons.healing_outlined,
            label: 'Treatment',
            value: record.doctorNotes ?? "No clinical notes provided",
          ),
          if (record.vaccinationDate != null)
            _RecordRow(
              icon: Icons.vaccines_outlined,
              label: 'Vaccination Date',
              value: DateFormat('MMM d, yyyy').format(record.vaccinationDate!),
            ),
          if (record.nextDueDate != null)
            _RecordRow(
              icon: Icons.event_repeat,
              label: 'Next Due',
              value: DateFormat('MMM d, yyyy').format(record.nextDueDate!),
            ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
