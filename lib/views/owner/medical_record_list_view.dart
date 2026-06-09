import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/medical_record_controller.dart';
import '../../models/pet_model.dart';
import 'add_medical_record_view.dart';
import 'medical_record_detail_view.dart';

class MedicalRecordListView extends StatefulWidget {
  final Pet pet; // Accept the clicked pet

  const MedicalRecordListView({super.key, required this.pet});

  @override
  State<MedicalRecordListView> createState() => _MedicalRecordListViewState();
}

class _MedicalRecordListViewState extends State<MedicalRecordListView> {
  Pet get pet => widget.pet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalRecordController>().fetchMedicalRecords(pet.petId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicalRecordController>();
    final records = controller.getRecordsByPet(pet.petId);

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          'Health History',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
      ),
      body: Column(
        children: [
          // Elegant Pet Details Header with profile picture
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pet profile picture
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: pet.profileImageUrl != null &&
                            pet.profileImageUrl!.isNotEmpty
                        ? Image.network(
                            pet.profileImageUrl!,
                            fit: BoxFit.cover,
                            width: 68,
                            height: 68,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 32,
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 32,
                          ),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${pet.age} ${pet.age == 1 ? 'yr' : 'yrs'} old',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // History Title section with record count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Records Timeline',
                  style: TextStyle(
                    color: AppColors.darkText.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                if (records.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${records.length}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Timeline List
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medical_information_outlined,
                          size: 56,
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No medical records yet',
                          style: TextStyle(
                            color: AppColors.darkText.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add one',
                          style: TextStyle(
                            color: AppColors.mutedText.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isDueSoon = record.nextDueDate != null &&
                          record.nextDueDate!
                                  .difference(DateTime.now())
                                  .inDays <=
                              30;
                      final isLast = index == records.length - 1;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MedicalRecordDetailView(record: record),
                            ),
                          );
                        },
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline connector column
                              SizedBox(
                                width: 32,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: isDueSoon
                                            ? Colors.orange
                                            : AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDueSoon
                                                    ? Colors.orange
                                                    : AppColors.primary)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Card content
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row: icon + diagnosis + date
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.medical_services_outlined,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  record.diagnosis,
                                                  style: TextStyle(
                                                    color: AppColors.darkText,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                if (record.vaccinationDate !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_month_rounded,
                                                          size: 13,
                                                          color: AppColors
                                                              .mutedText,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(record
                                                                  .vaccinationDate!),
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .mutedText,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Chevron
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: AppColors.mutedText
                                                .withValues(alpha: 0.5),
                                            size: 22,
                                          ),
                                        ],
                                      ),

                                      // Treatment info
                                      if (record.treatment != null &&
                                          record.treatment!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          icon: Icons.healing_rounded,
                                          label: 'Treatment',
                                          value: record.treatment!,
                                        ),
                                      ],

                                      // Doctor notes
                                      if (record.doctorNotes != null &&
                                          record.doctorNotes!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          icon: Icons.notes_rounded,
                                          label: 'Notes',
                                          value: record.doctorNotes!,
                                          maxLines: 2,
                                        ),
                                      ],

                                      // Medications
                                      if (record.medicationsPrescribed !=
                                              null &&
                                          record.medicationsPrescribed!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: record
                                              .medicationsPrescribed!
                                              .map((med) => Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.chipBg,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .medication_rounded,
                                                          size: 12,
                                                          color: AppColors
                                                              .primary,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            med,
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primary,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ],

                                      // Follow-up instructions
                                      if (record.followUpInstructions !=
                                              null &&
                                          record.followUpInstructions!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          icon: Icons.assignment_rounded,
                                          label: 'Follow-up',
                                          value:
                                              record.followUpInstructions!,
                                          maxLines: 2,
                                        ),
                                      ],

                                      // Next due date badge
                                      if (record.nextDueDate != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDueSoon
                                                ? Colors.orange
                                                    .withValues(alpha: 0.1)
                                                : AppColors.primary
                                                    .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isDueSoon
                                                    ? Icons
                                                        .warning_amber_rounded
                                                    : Icons
                                                        .calendar_today_rounded,
                                                size: 14,
                                                color: isDueSoon
                                                    ? Colors.orange
                                                    : AppColors.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Next due: ${DateFormat.yMMMd().format(record.nextDueDate!)}',
                                                style: TextStyle(
                                                  color: isDueSoon
                                                      ? Colors.orange
                                                      : AppColors.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
              builder: (_) => AddMedicalRecordView(petId: pet.petId),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Helper widget for info rows (treatment, notes, follow-up)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedText),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}