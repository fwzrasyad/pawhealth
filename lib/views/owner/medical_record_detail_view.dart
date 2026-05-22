import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medical_record_model.dart';

class MedicalRecordDetailView extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordDetailView({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Record Details',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
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
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      size: 40,
                      color: Color(0xFF8A2BE2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    record.diagnosis,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
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
                  const Text(
                    'Clinical Notes',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
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
                            style: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.doctorNotes!,
                            style: const TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (record.medicationsPrescribed?.isNotEmpty ?? false) ...[
                          const Text(
                            'Medications',
                            style: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.medicationsPrescribed!.join(', '),
                            style: const TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (record.followUpInstructions?.isNotEmpty ?? false) ...[
                          const Text(
                            'Follow-up Instructions',
                            style: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.followUpInstructions!,
                            style: const TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (record.treatment?.isNotEmpty ?? false) ...[
                          const Text(
                            'Treatment',
                            style: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.treatment!,
                            style: const TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.5),
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
                    const Text(
                      'Next Due Date',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A2BE2).withValues(alpha: 0.05),
                        border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available, color: Color(0xFF8A2BE2)),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMMd().format(record.nextDueDate!),
                            style: const TextStyle(
                              color: Color(0xFF333333),
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
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
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
                                const Text(
                                  'Scan_Report.pdf',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
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
