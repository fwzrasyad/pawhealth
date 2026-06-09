class RecoveryLog {
  final String id;
  final String recoveryPlanId;
  final DateTime date;
  final Map<String, dynamic>? symptomStatus;
  final String? ownerNotes;
  final String? photoUrl;

  RecoveryLog({
    required this.id,
    required this.recoveryPlanId,
    required this.date,
    this.symptomStatus,
    this.ownerNotes,
    this.photoUrl,
  });

  factory RecoveryLog.fromJson(Map<String, dynamic> json) {
    return RecoveryLog(
      id: json['id'],
      recoveryPlanId: json['recovery_plan_id'],
      date: DateTime.parse(json['date']),
      symptomStatus: json['symptom_status'],
      ownerNotes: json['owner_notes'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recovery_plan_id': recoveryPlanId,
      'date': date.toIso8601String(),
      'symptom_status': symptomStatus,
      'owner_notes': ownerNotes,
      'photo_url': photoUrl,
    };
  }
}

class RecoveryPlan {
  final String id;
  final String petId;
  final String? appointmentId;
  final String vetId;
  final String instructions;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<RecoveryLog> recoveryLogs;

  RecoveryPlan({
    required this.id,
    required this.petId,
    this.appointmentId,
    required this.vetId,
    required this.instructions,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.recoveryLogs = const [],
  });

  factory RecoveryPlan.fromJson(Map<String, dynamic> json) {
    return RecoveryPlan(
      id: json['id'],
      petId: json['pet_id'],
      appointmentId: json['appointment_id'],
      vetId: json['vet_id'],
      instructions: json['instructions'],
      durationDays: json['duration_days'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      recoveryLogs: (json['recovery_logs'] as List<dynamic>?)
              ?.map((e) => RecoveryLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'appointment_id': appointmentId,
      'vet_id': vetId,
      'instructions': instructions,
      'duration_days': durationDays,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'recovery_logs': recoveryLogs.map((log) => log.toJson()).toList(),
    };
  }
}
