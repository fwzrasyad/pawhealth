import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';
import '../../models/medical_record_model.dart';

class MedicalRecordDetailView extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordDetailView({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          'Record Details',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    record.diagnosis,
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  if (record.vaccinationDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.yMMMMd().format(record.vaccinationDate!),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical Notes',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record.doctorNotes?.isNotEmpty ?? false) ...[
                          const Text(
                            'Doctor Notes',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.doctorNotes!,
                            style: TextStyle(color: AppColors.darkText, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (record.medicationsPrescribed?.isNotEmpty ?? false) ...[
                          const Text(
                            'Medications',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.medicationsPrescribed!.join(', '),
                            style: TextStyle(color: AppColors.darkText, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (record.followUpInstructions?.isNotEmpty ?? false) ...[
                          const Text(
                            'Follow-up Instructions',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.followUpInstructions!,
                            style: TextStyle(color: AppColors.darkText, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (record.treatment?.isNotEmpty ?? false) ...[
                          const Text(
                            'Treatment',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.treatment!,
                            style: TextStyle(color: AppColors.darkText, fontSize: 14, height: 1.5),
                          ),
                        ],
                        if ((record.doctorNotes?.isEmpty ?? true) &&
                            (record.medicationsPrescribed?.isEmpty ?? true) &&
                            (record.followUpInstructions?.isEmpty ?? true) &&
                            (record.treatment?.isEmpty ?? true))
                          const Text(
                            'No notes recorded.',
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (record.nextDueDate != null) ...[
                    Text(
                      'Next Due Date',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_available, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMMd().format(record.nextDueDate!),
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (record.attachmentUrl != null) ...[
                    Text(
                      'Attachments',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan_Report.pdf',
                                  style: TextStyle(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to view document',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}