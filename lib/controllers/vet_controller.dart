import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../models/pet_model.dart';
import '../models/medical_record_model.dart';
import '../models/daily_routine_model.dart';

class VetController extends ChangeNotifier {
  final List<Appointment> _appointments = [];
  final List<Pet> _pets = [];
  final List<MedicalRecord> _medicalRecords = [];
  // Available slots: key = 'yyyy-MM-dd HH:mm', value = true (available) / false (blocked)
  final Map<String, bool> _availabilitySlots = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Appointment> get pendingAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.pending).toList()
        ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

  List<Appointment> get confirmedAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.confirmed).toList()
        ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

  List<Appointment> get todaysAppointments {
    final today = DateTime.now();
    return confirmedAppointments.where((a) =>
        a.appointmentDate.year == today.year &&
        a.appointmentDate.month == today.month &&
        a.appointmentDate.day == today.day).toList();
  }

  List<Pet> get patients => _pets;
  Map<String, bool> get availabilitySlots => Map.unmodifiable(_availabilitySlots);

  VetController() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();

    // Mock Pets
    _pets.addAll([
      Pet(
        petId: 'pet_2',
        ownerId: 'user_001',
        name: 'Cola',
        species: 'Cat',
        breed: 'Domestic Shorthair',
        age: 3,
        gender: 'Female',
        weight: 3.8,
        dailyRoutines: [
          DailyRoutineLog(
            id: 'log_1',
            petId: 'pet_2',
            date: now.subtract(const Duration(days: 1)),
            dietNotes: 'Dry kibble, 80g morning and evening',
            weight: 3.8,
            activityLevel: 'Moderate',
          ),
        ],
      ),
      Pet(
        petId: 'pet_1',
        ownerId: 'user_001',
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        age: 4,
        gender: 'Male',
        weight: 28.5,
        dailyRoutines: [
          DailyRoutineLog(
            id: 'log_2',
            petId: 'pet_1',
            date: now.subtract(const Duration(days: 2)),
            dietNotes: 'High-protein dry food, 200g twice daily',
            weight: 28.5,
            activityLevel: 'High',
          ),
        ],
      ),
    ]);

    // Mock Medical Records
    _medicalRecords.addAll([
      MedicalRecord(
        recordId: 'rec_1',
        petId: 'pet_2',
        vetId: 'vet_001',
        diagnosis: 'Mild skin rash – contact dermatitis',
        treatment: 'Topical corticosteroid cream, antihistamine',
        vaccinationDate: DateTime(2024, 3, 10),
        nextDueDate: DateTime(2025, 3, 10),
      ),
      MedicalRecord(
        recordId: 'rec_2',
        petId: 'pet_2',
        vetId: 'vet_001',
        diagnosis: 'Annual health check – all clear',
        treatment: 'Rabies & FVRCP booster administered',
        vaccinationDate: DateTime(2024, 11, 5),
        nextDueDate: DateTime(2025, 11, 5),
      ),
      MedicalRecord(
        recordId: 'rec_3',
        petId: 'pet_1',
        vetId: 'vet_002',
        diagnosis: 'ACL partial tear – right hind leg',
        treatment: 'Rest, anti-inflammatory medication, physio plan',
        vaccinationDate: null,
        nextDueDate: now.add(const Duration(days: 7)),
      ),
    ]);

    // Mock Appointments
    _appointments.addAll([
      Appointment(
        appointmentId: 'vt_appt_001',
        petId: 'pet_2',
        petName: 'Cola',
        vetId: 'vet_001',
        vetName: 'Dr. Rasyad Amin',
        reason: 'Annual vaccination & health check',
        appointmentDate: DateTime(now.year, now.month, now.day),
        timeSlot: DateTime(now.year, now.month, now.day, 10, 0),
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        appointmentId: 'vt_appt_002',
        petId: 'pet_1',
        petName: 'Buddy',
        vetId: 'vet_001',
        vetName: 'Dr. Rasyad Amin',
        reason: 'Post-surgery follow-up',
        appointmentDate: DateTime(now.year, now.month, now.day),
        timeSlot: DateTime(now.year, now.month, now.day, 14, 0),
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        appointmentId: 'vt_appt_003',
        petId: 'pet_2',
        petName: 'Cola',
        vetId: 'vet_001',
        vetName: 'Dr. Rasyad Amin',
        reason: 'Skin rash follow-up consultation',
        appointmentDate: now.add(const Duration(days: 2)),
        timeSlot: DateTime(now.year, now.month, now.day + 2, 11, 0),
        status: AppointmentStatus.pending,
      ),
      Appointment(
        appointmentId: 'vt_appt_004',
        petId: 'pet_1',
        petName: 'Buddy',
        vetId: 'vet_001',
        vetName: 'Dr. Rasyad Amin',
        reason: 'Dietary and nutrition consultation',
        appointmentDate: now.add(const Duration(days: 3)),
        timeSlot: DateTime(now.year, now.month, now.day + 3, 9, 0),
        status: AppointmentStatus.pending,
      ),
      Appointment(
        appointmentId: 'vt_appt_005',
        petId: 'pet_2',
        petName: 'Cola',
        vetId: 'vet_001',
        vetName: 'Dr. Rasyad Amin',
        reason: 'New patient wellness check',
        appointmentDate: now.add(const Duration(days: 5)),
        timeSlot: DateTime(now.year, now.month, now.day + 5, 13, 0),
        status: AppointmentStatus.pending,
      ),
    ]);

    // Default availability – 9am to 4pm for the next 7 days
    for (int d = 0; d < 7; d++) {
      final date = now.add(Duration(days: d));
      for (int h = 9; h <= 16; h++) {
        final key = _slotKey(DateTime(date.year, date.month, date.day, h, 0));
        _availabilitySlots[key] = true;
      }
    }
  }

  String _slotKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:00';

  Future<void> acceptAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
    if (idx != -1) {
      _appointments[idx] = _appointments[idx].copyWith(status: AppointmentStatus.confirmed);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
    if (idx != -1) {
      _appointments[idx] = _appointments[idx].copyWith(status: AppointmentStatus.cancelled);
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleAvailability(DateTime slot) {
    final key = _slotKey(slot);
    _availabilitySlots[key] = !(_availabilitySlots[key] ?? false);
    notifyListeners();
  }

  bool isSlotAvailable(DateTime slot) => _availabilitySlots[_slotKey(slot)] ?? false;

  List<MedicalRecord> getPatientRecords(String petId) =>
      _medicalRecords.where((r) => r.petId == petId).toList()
        ..sort((a, b) => (b.vaccinationDate ?? DateTime.now())
            .compareTo(a.vaccinationDate ?? DateTime.now()));

  Pet? getPetById(String petId) {
    try {
      return _pets.firstWhere((p) => p.petId == petId);
    } catch (_) {
      return null;
    }
  }
}
