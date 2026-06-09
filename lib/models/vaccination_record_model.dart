class VaccinationRecord {
  final String id;
  final String petId;
  final String? recordId;
  final String? administeredByVetId;
  final String vaccineName;
  final bool isCore;
  final DateTime dateAdministered;
  final DateTime? nextDueDate;

  VaccinationRecord({
    required this.id,
    required this.petId,
    this.recordId,
    this.administeredByVetId,
    required this.vaccineName,
    this.isCore = false,
    required this.dateAdministered,
    this.nextDueDate,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: json['id'],
      petId: json['pet_id'],
      recordId: json['record_id'],
      administeredByVetId: json['administered_by_vet_id'],
      vaccineName: json['vaccine_name'],
      isCore: json['is_core'] == 1 || json['is_core'] == true,
      dateAdministered: DateTime.parse(json['date_administered']),
      nextDueDate: json['next_due_date'] != null ? DateTime.parse(json['next_due_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'record_id': recordId,
      'administered_by_vet_id': administeredByVetId,
      'vaccine_name': vaccineName,
      'is_core': isCore,
      'date_administered': dateAdministered.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
    };
  }
}
