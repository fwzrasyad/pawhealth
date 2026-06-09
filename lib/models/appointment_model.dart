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
  final String? ownerName;
  final String? ownerProfileUrl;
  final String reason;
  final DateTime appointmentDate;
  final DateTime timeSlot;
  final AppointmentStatus status;
  final MedicalRecord? medicalRecord;
  final double? amount;
  final String? paymentIntentId;
  final String? paymentStatus;

  // Video call fields
  final String consultationType; // 'in_person' or 'virtual'
  final String? videoCallChannel;
  final String videoCallStatus; // 'none', 'active', 'ended'
  final DateTime? videoCallStartedAt;
  final DateTime? videoCallEndedAt;
  final String? petProfileUrl;

  Appointment({
    required this.appointmentId,
    required this.clinicId,
    required this.clinicName,
    required this.petId,
    required this.petName,
    required this.vetId,
    required this.vetName,
    this.ownerName,
    this.ownerProfileUrl,
    required this.reason,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.medicalRecord,
    this.amount,
    this.paymentIntentId,
    this.paymentStatus = 'pending',
    this.consultationType = 'in_person',
    this.videoCallChannel,
    this.videoCallStatus = 'none',
    this.videoCallStartedAt,
    this.videoCallEndedAt,
    this.petProfileUrl,
  });

  /// Whether the appointment is a virtual consultation.
  bool get isVirtual => consultationType == 'virtual';

  /// Whether the video call is active.
  bool get isCallActive => videoCallStatus == 'active';

  /// Whether the video call has ended.
  bool get isCallEnded => videoCallStatus == 'ended';

  Appointment copyWith({
    AppointmentStatus? status,
    MedicalRecord? medicalRecord,
    String? paymentStatus,
    String? consultationType,
    String? videoCallChannel,
    String? videoCallStatus,
    DateTime? videoCallStartedAt,
    DateTime? videoCallEndedAt,
    String? petProfileUrl,
    String? ownerName,
    String? ownerProfileUrl,
  }) {
    return Appointment(
      appointmentId: appointmentId,
      clinicId: clinicId,
      clinicName: clinicName,
      petId: petId,
      petName: petName,
      vetId: vetId,
      vetName: vetName,
      ownerName: ownerName ?? this.ownerName,
      ownerProfileUrl: ownerProfileUrl ?? this.ownerProfileUrl,
      reason: reason,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      status: status ?? this.status,
      medicalRecord: medicalRecord ?? this.medicalRecord,
      amount: amount,
      paymentIntentId: paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      consultationType: consultationType ?? this.consultationType,
      videoCallChannel: videoCallChannel ?? this.videoCallChannel,
      videoCallStatus: videoCallStatus ?? this.videoCallStatus,
      videoCallStartedAt: videoCallStartedAt ?? this.videoCallStartedAt,
      videoCallEndedAt: videoCallEndedAt ?? this.videoCallEndedAt,
      petProfileUrl: petProfileUrl ?? this.petProfileUrl,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String? ownerName;
    String? ownerProfileUrl;
    
    if (json['owner'] != null) {
      final ownerObj = json['owner'];
      final fn = ownerObj['first_name']?.toString() ?? '';
      final ln = ownerObj['last_name']?.toString() ?? '';
      ownerName = fn.isNotEmpty ? (ln.isNotEmpty ? '$fn $ln' : fn) : ownerObj['name']?.toString();
      ownerProfileUrl = ownerObj['profile_image_url']?.toString();
    }

    return Appointment(
      appointmentId: json['appointment_id']?.toString() ?? '',
      clinicId: json['clinic_id']?.toString() ?? '',
      clinicName: json['clinic_name']?.toString() ?? '',
      petId: json['pet_id']?.toString() ?? '',
      petName: json['pet_name'] ?? '',
      vetId: json['vet_id']?.toString() ?? '',
      vetName: json['vet_name'] ?? '',
      ownerName: ownerName,
      ownerProfileUrl: ownerProfileUrl,
      reason: json['reason']?.toString() ?? '',
      appointmentDate: json['appointment_date'] != null 
          ? DateTime.parse(json['appointment_date']) 
          : DateTime.now(),
      timeSlot: json['time_slot'] != null 
          ? DateTime.parse(json['time_slot']) 
          : DateTime.now(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      medicalRecord: json['medical_record'] != null ? MedicalRecord.fromJson(json['medical_record']) : null,
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      paymentIntentId: json['payment_intent_id']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      consultationType: json['consultation_type']?.toString() ?? 'in_person',
      videoCallChannel: json['video_call_channel']?.toString(),
      videoCallStatus: json['video_call_status']?.toString() ?? 'none',
      videoCallStartedAt: json['video_call_started_at'] != null ? DateTime.tryParse(json['video_call_started_at']) : null,
      videoCallEndedAt: json['video_call_ended_at'] != null ? DateTime.tryParse(json['video_call_ended_at']) : null,
      petProfileUrl: _extractPetImage(json),
    );
  }

  static String? _extractPetImage(Map<String, dynamic> json) {
    if (json['pet'] != null) {
      if (json['pet']['profile_image_url'] != null) return json['pet']['profile_image_url']?.toString();
      if (json['pet']['profile_image'] != null) return json['pet']['profile_image']?.toString();
      if (json['pet']['image_url'] != null) return json['pet']['image_url']?.toString();
    }
    return json['pet_profile_image_url']?.toString() ?? 
           json['pet_image_url']?.toString() ?? 
           json['pet_profile_url']?.toString();
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
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerProfileUrl != null) 'owner_profile_url': ownerProfileUrl,
      'reason': reason,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot.toIso8601String(),
      'status': status.toString().split('.').last,
      if (medicalRecord != null) 'medical_record': medicalRecord!.toJson(),
      if (amount != null) 'amount': amount,
      if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      'consultation_type': consultationType,
      if (videoCallChannel != null) 'video_call_channel': videoCallChannel,
      'video_call_status': videoCallStatus,
      if (videoCallStartedAt != null) 'video_call_started_at': videoCallStartedAt!.toIso8601String(),
      if (videoCallEndedAt != null) 'video_call_ended_at': videoCallEndedAt!.toIso8601String(),
    };
  }
}
