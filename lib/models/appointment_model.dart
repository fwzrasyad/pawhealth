import 'medical_record_model.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final String appointmentId;
  final String clinicId;
  final String clinicName;
  final String petId;
  final String petName;
  final String vetId;
  final String vetName;
  final String reason;
  final DateTime appointmentDate;
  final DateTime timeSlot;
  final AppointmentStatus status;
  final MedicalRecord? medicalRecord;
  final double? amount;
  final String? paymentIntentId;
  final String? paymentStatus;

  Appointment({
    required this.appointmentId,
    this.clinicId = '',
    this.clinicName = '',
    required this.petId,
    required this.petName,
    this.vetId = '',
    this.vetName = '',
    required this.reason,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.medicalRecord,
    this.amount,
    this.paymentIntentId,
    this.paymentStatus,
  });

  Appointment copyWith({AppointmentStatus? status, MedicalRecord? medicalRecord, String? paymentStatus}) {
    return Appointment(
      appointmentId: appointmentId,
      clinicId: clinicId,
      clinicName: clinicName,
      petId: petId,
      petName: petName,
      vetId: vetId,
      vetName: vetName,
      reason: reason,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      status: status ?? this.status,
      medicalRecord: medicalRecord ?? this.medicalRecord,
      amount: amount,
      paymentIntentId: paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id']?.toString() ?? '',
      clinicId: json['clinic_id']?.toString() ?? '',
      clinicName: json['clinic_name'] ?? '',
      petId: json['pet_id']?.toString() ?? '',
      petName: json['pet_name'] ?? '',
      vetId: json['vet_id']?.toString() ?? '',
      vetName: json['vet_name'] ?? '',
      reason: json['reason'] ?? '',
      appointmentDate: DateTime.parse(json['appointment_date']),
      timeSlot: DateTime.parse(json['time_slot']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      medicalRecord: json['medical_record'] != null ? MedicalRecord.fromJson(json['medical_record']) : null,
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      paymentIntentId: json['payment_intent_id']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (appointmentId.isNotEmpty) 'appointment_id': appointmentId,
      if (clinicId.isNotEmpty) 'clinic_id': clinicId,
      if (clinicName.isNotEmpty) 'clinic_name': clinicName,
      'pet_id': petId,
      'pet_name': petName,
      if (vetId.isNotEmpty) 'vet_id': vetId,
      if (vetName.isNotEmpty) 'vet_name': vetName,
      'reason': reason,
      'appointment_date': appointmentDate.toIso8601String().split('T').join(' ').split('.')[0],
      'time_slot': timeSlot.toIso8601String().split('T').join(' ').split('.')[0],
      'status': status.name,
      if (amount != null) 'amount': amount,
      if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
      if (paymentStatus != null) 'payment_status': paymentStatus,
    };
  }
}
