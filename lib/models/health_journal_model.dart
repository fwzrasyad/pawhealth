class HealthJournalEntry {
  final String id;
  final String petId;
  final DateTime date;
  final List<String> symptomTags; // e.g., ["Lethargic", "Vomiting", "Normal Appetite", "Wound Healing"]
  final String observations; // Multiline text field for detailed observations

  HealthJournalEntry({
    required this.id,
    required this.petId,
    required this.date,
    required this.symptomTags,
    required this.observations,
  });

  factory HealthJournalEntry.fromJson(Map<String, dynamic> json) {
    return HealthJournalEntry(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      date: DateTime.parse(json['date'] as String),
      symptomTags: List<String>.from(json['symptom_tags'] as List? ?? []),
      observations: json['observations'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'date': date.toIso8601String(),
      'symptom_tags': symptomTags,
      'observations': observations,
    };
  }
}
