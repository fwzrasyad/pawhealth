class DailyRoutineLog {
  final String id;
  final String petId;
  final DateTime date;
  final double weight;
  final String dietNotes;
  final String activityLevel;

  DailyRoutineLog({
    required this.id,
    required this.petId,
    required this.date,
    required this.weight,
    required this.dietNotes,
    required this.activityLevel,
  });

  factory DailyRoutineLog.fromJson(Map<String, dynamic> json) {
    return DailyRoutineLog(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      dietNotes: json['diet_notes'] as String,
      activityLevel: json['activity_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'date': date.toIso8601String(),
      'weight': weight,
      'diet_notes': dietNotes,
      'activity_level': activityLevel,
    };
  }
}
