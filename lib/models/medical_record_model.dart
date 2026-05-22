class MedicalRecord {
  final String recordId;
  final String petId;
  final String vetId;
  final String? appointmentId;
  final String diagnosis;
  final String? treatment;
  final String? doctorNotes;
  final List<String>? medicationsPrescribed;
  final String? followUpInstructions;
  final DateTime? vaccinationDate;
  final DateTime? nextDueDate;
  final String? attachmentUrl;

  MedicalRecord({
    required this.recordId,
    required this.petId,
    required this.vetId,
    this.appointmentId,
    required this.diagnosis,
    this.treatment,
    this.doctorNotes,
    this.medicationsPrescribed,
    this.followUpInstructions,
    this.vaccinationDate,
    this.nextDueDate,
    this.attachmentUrl,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordId: json['record_id']?.toString() ?? '',
      petId: json['pet_id']?.toString() ?? '',
      vetId: json['vet_id']?.toString() ?? '',
      appointmentId: json['appointment_id']?.toString(),
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'],
      doctorNotes: json['doctor_notes'],
      medicationsPrescribed: json['medications_prescribed'] != null ? List<String>.from(json['medications_prescribed']) : null,
      followUpInstructions: json['follow_up_instructions'],
      vaccinationDate: json['vaccination_date'] != null ? DateTime.parse(json['vaccination_date']) : null,
      nextDueDate: json['next_due_date'] != null ? DateTime.parse(json['next_due_date']) : null,
      attachmentUrl: json['attachment_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'pet_id': petId,
      'vet_id': vetId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      'diagnosis': diagnosis,
      if (treatment != null) 'treatment': treatment,
      if (doctorNotes != null) 'doctor_notes': doctorNotes,
      if (medicationsPrescribed != null) 'medications_prescribed': medicationsPrescribed,
      if (followUpInstructions != null) 'follow_up_instructions': followUpInstructions,
      'vaccination_date': vaccinationDate?.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
      'attachment_url': attachmentUrl,
    };
  }
}
