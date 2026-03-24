enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final String appointmentId;
  final String petId;
  final String petName;
  final String vetId;
  final String vetName;
  final String reason;
  final DateTime appointmentDate;
  final DateTime timeSlot;
  final AppointmentStatus status;

  Appointment({
    required this.appointmentId,
    required this.petId,
    required this.petName,
    required this.vetId,
    required this.vetName,
    required this.reason,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
  });

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      appointmentId: appointmentId,
      petId: petId,
      petName: petName,
      vetId: vetId,
      vetName: vetName,
      reason: reason,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      status: status ?? this.status,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'],
      petId: json['pet_id'],
      petName: json['pet_name'] ?? '',
      vetId: json['vet_id'],
      vetName: json['vet_name'] ?? '',
      reason: json['reason'] ?? '',
      appointmentDate: DateTime.parse(json['appointment_date']),
      timeSlot: DateTime.parse(json['time_slot']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'pet_id': petId,
      'pet_name': petName,
      'vet_id': vetId,
      'vet_name': vetName,
      'reason': reason,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot.toIso8601String(),
      'status': status.name,
    };
  }
}
