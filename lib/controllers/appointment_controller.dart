import 'package:flutter/material.dart';
import '../models/veterinarian_model.dart';
import '../models/appointment_model.dart';

class AppointmentController extends ChangeNotifier {
  Veterinarian? _selectedVet;
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot;

  final List<Appointment> _appointments = [];
  final List<Veterinarian> _vets = [];

  Veterinarian? get selectedVet => _selectedVet;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedTimeSlot => _selectedTimeSlot;
  List<Veterinarian> get vets => _vets;

  List<Appointment> get upcomingVisits => _appointments
      .where((a) =>
          a.status == AppointmentStatus.pending ||
          a.status == AppointmentStatus.confirmed)
      .toList()
    ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

  List<Appointment> get pastVisits => _appointments
      .where((a) =>
          a.status == AppointmentStatus.completed ||
          a.status == AppointmentStatus.cancelled)
      .toList()
    ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

  AppointmentController() {
    _initMockVets();
    _initMockAppointments();
  }

  void _initMockVets() {
    final now = DateTime.now();

    List<DateTime> generateSlots() {
      List<DateTime> slots = [];
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        for (int hour = 9; hour <= 16; hour++) {
          slots.add(DateTime(date.year, date.month, date.day, hour, 0));
        }
      }
      return slots;
    }

    _vets.addAll([
      Veterinarian(
        vetId: 'vet_001',
        name: 'Dr. Rasyad Amin',
        profileImageUrl: 'assets/images/vet_rasyad.jpg',
        workingHours: '9:00 AM - 10:00 PM',
        specialties: ['Pet behavior', 'Pet Food', 'Pet Treatments'],
        bio: 'Dr. Rasyad Amin is a highly experienced veterinarian with 11 years of dedicated practice.',
        availableSlots: generateSlots(),
      ),
      Veterinarian(
        vetId: 'vet_002',
        name: 'Dr. Geoff Neill',
        profileImageUrl: 'assets/images/vet_geoff.jpg',
        workingHours: '9:00 AM - 10:00 PM',
        specialties: ['Surgery', 'Orthopedics'],
        bio: 'Dr. Geoff Neill specializes in advanced orthopedic procedures and general surgery with over 15 years of experience.',
        availableSlots: generateSlots(),
      ),
      Veterinarian(
        vetId: 'vet_003',
        name: 'Dr. John Smith',
        profileImageUrl: 'assets/images/vet_john.jpg',
        workingHours: '9:00 AM - 10:00 PM',
        specialties: ['Internal Medicine', 'Dermatology'],
        bio: 'Dr. John Smith is passionate about complex internal medicine cases and skin health for cats and dogs.',
        availableSlots: generateSlots(),
      ),
      Veterinarian(
        vetId: 'vet_004',
        name: 'Dr. Muhammad Aiman',
        profileImageUrl: 'assets/images/vet_aiman.jpg',
        workingHours: '9:00 AM - 10:00 PM',
        specialties: ['Exotic Pets', 'Nutrition'],
        bio: 'Dr. Muhammad Aiman is an expert in exotic animal care and dietary management.',
        availableSlots: generateSlots(),
      ),
    ]);
  }

  void _initMockAppointments() {
    final now = DateTime.now();
    _appointments.addAll([
      Appointment(
        appointmentId: 'appt_001',
        petId: 'pet_2',
        petName: 'Cola',
        vetId: 'vet_001',
        vetName: 'Dr. Rasyad Amin',
        reason: 'Annual vaccination & health check',
        appointmentDate: now.add(const Duration(days: 3)),
        timeSlot: DateTime(now.year, now.month, now.day + 3, 10, 0),
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        appointmentId: 'appt_002',
        petId: 'pet_1',
        petName: 'Buddy',
        vetId: 'vet_002',
        vetName: 'Dr. Geoff Neill',
        reason: 'Post-surgery follow-up',
        appointmentDate: now.add(const Duration(days: 7)),
        timeSlot: DateTime(now.year, now.month, now.day + 7, 14, 0),
        status: AppointmentStatus.pending,
      ),
      Appointment(
        appointmentId: 'appt_003',
        petId: 'pet_2',
        petName: 'Cola',
        vetId: 'vet_003',
        vetName: 'Dr. John Smith',
        reason: 'Skin rash assessment',
        appointmentDate: now.subtract(const Duration(days: 12)),
        timeSlot: DateTime(now.year, now.month, now.day - 12, 11, 0),
        status: AppointmentStatus.completed,
      ),
      Appointment(
        appointmentId: 'appt_004',
        petId: 'pet_1',
        petName: 'Buddy',
        vetId: 'vet_004',
        vetName: 'Dr. Muhammad Aiman',
        reason: 'Dietary consultation',
        appointmentDate: now.subtract(const Duration(days: 30)),
        timeSlot: DateTime(now.year, now.month, now.day - 30, 9, 0),
        status: AppointmentStatus.cancelled,
      ),
    ]);
  }

  void selectVet(Veterinarian vet) {
    _selectedVet = vet;
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void selectTimeSlot(DateTime timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: AppointmentStatus.cancelled);
      notifyListeners();
    }
  }

  Future<bool> bookConsultation({String petId = 'pet_1', String petName = 'My Pet'}) async {
    if (_selectedVet == null || _selectedDate == null || _selectedTimeSlot == null) return false;

    await Future.delayed(const Duration(seconds: 1));

    _appointments.add(Appointment(
      appointmentId: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      petName: petName,
      vetId: _selectedVet!.vetId,
      vetName: _selectedVet!.name,
      reason: 'General Consultation',
      appointmentDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      status: AppointmentStatus.pending,
    ));

    _selectedVet = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
    return true;
  }
}
