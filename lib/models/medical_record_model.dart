class MedicalRecord {
  final String recordId;
  final String petId;
  final String vetId;
  final String diagnosis;
  final String treatment;
  final DateTime? vaccinationDate;
  final DateTime? nextDueDate;
  final String? attachmentUrl;

  MedicalRecord({
    required this.recordId,
    required this.petId,
    required this.vetId,
    required this.diagnosis,
    required this.treatment,
    this.vaccinationDate,
    this.nextDueDate,
    this.attachmentUrl,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordId: json['record_id'],
      petId: json['pet_id'],
      vetId: json['vet_id'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
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
      'diagnosis': diagnosis,
      'treatment': treatment,
      'vaccination_date': vaccinationDate?.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
      'attachment_url': attachmentUrl,
    };
  }
}
