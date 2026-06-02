import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/appointment_model.dart';
import '../models/clinic_model.dart';
import '../models/veterinarian_model.dart';

class AppointmentController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Clinic? _selectedClinic;
  Veterinarian? _selectedVet;
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot;
  String _reason = 'General Consultation';

  List<Clinic> _clinics = [];
  List<Veterinarian> _vets = [];
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  Clinic? get selectedClinic => _selectedClinic;
  Veterinarian? get selectedVet => _selectedVet;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedTimeSlot => _selectedTimeSlot;
  String get reason => _reason;
  
  List<Clinic> get clinics => _clinics;
  List<Veterinarian> get vets => _vets;
  bool get isLoading => _isLoading;

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

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ── Fetch Appointments ────────────────────────────────────────────────────

  /// Fetches all appointments for the currently logged-in user.
  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/appointments', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _appointments = data.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching appointments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Fetch Clinics & Vets ──────────────────────────────────────────────────

  Future<void> fetchClinics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/clinics', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _clinics = data.map((json) => Clinic.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching clinics: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVetsForClinic(String clinicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/clinics/$clinicId/vets', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _vets = data.map((json) => Veterinarian.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching vets for clinic: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Create Appointment ────────────────────────────────────────────────────

  /// Creates a new appointment via the backend.
  Future<bool> createAppointment(Appointment appointment) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.post(
        '/appointments',
        appointment.toJson(),
        token,
      );

      final created = Appointment.fromJson(response['data'] ?? response);
      _appointments.add(created);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating appointment: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Update Appointment Status ─────────────────────────────────────────────

  /// Updates the status of an appointment (e.g. cancel, complete).
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.put('/appointments/$appointmentId', {
        'status': status.name,
      }, token);

      // Update local state
      final index = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(status: status);
      }
    } catch (e) {
      print('Error updating appointment status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Cancel Appointment (convenience) ──────────────────────────────────────

  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  // ── Booking Flow Selection Helpers ────────────────────────────────────────

  void selectClinic(Clinic clinic) {
    _selectedClinic = clinic;
    _selectedVet = null; // Reset vet when clinic changes
    _selectedDate = null;
    _selectedTimeSlot = null;
    _vets = []; // Clear previous vets
    notifyListeners();
    fetchVetsForClinic(clinic.clinicId);
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

  void setReason(String reason) {
    _reason = reason;
    notifyListeners();
  }

  /// Resets the booking form state.
  void resetBookingForm() {
    _selectedClinic = null;
    _selectedVet = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    _reason = 'General Consultation';
    _vets = [];
    notifyListeners();
  }

  /// Books a clinic consultation with a specific vet.
  Future<bool> bookConsultation({
    required String petId,
    required String petName,
    String? reason,
  }) async {
    if (_selectedClinic == null || _selectedVet == null || _selectedDate == null || _selectedTimeSlot == null) return false;

    final appointment = Appointment(
      appointmentId: '', // Backend will assign the real ID
      clinicId: _selectedClinic!.clinicId,
      clinicName: _selectedClinic!.name,
      petId: petId,
      petName: petName,
      vetId: _selectedVet!.vetId,
      vetName: _selectedVet!.name,
      reason: reason ?? _reason,
      appointmentDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      status: AppointmentStatus.pending,
    );

    final success = await createAppointment(appointment);

    if (success) {
      resetBookingForm();
    }

    return success;
  }

  // ── Payment API ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> createPaymentIntent({
    required String petId,
    required String petName,
    String? reason,
  }) async {
    if (_selectedClinic == null || _selectedVet == null || _selectedDate == null || _selectedTimeSlot == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.post(
        '/payments/create-intent',
        {
          'clinic_id': _selectedClinic!.clinicId,
          'clinic_name': _selectedClinic!.name,
          'vet_id': _selectedVet!.vetId,
          'vet_name': _selectedVet!.name,
          'pet_id': petId,
          'pet_name': petName,
          'reason': reason ?? _reason,
          'appointment_date': _selectedDate!.toIso8601String().split('T').join(' ').split('.')[0],
          'time_slot': _selectedTimeSlot!.toIso8601String().split('T').join(' ').split('.')[0],
        },
        token,
      );

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print('Error creating payment intent: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmBookingWithPayment({
    required String paymentIntentId,
    required String petId,
    required String petName,
    String? reason,
  }) async {
    if (_selectedClinic == null || _selectedVet == null || _selectedDate == null || _selectedTimeSlot == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.post(
        '/payments/confirm-booking',
        {
          'payment_intent_id': paymentIntentId,
          'clinic_id': _selectedClinic!.clinicId,
          'clinic_name': _selectedClinic!.name,
          'vet_id': _selectedVet!.vetId,
          'vet_name': _selectedVet!.name,
          'pet_id': petId,
          'pet_name': petName,
          'reason': reason ?? _reason,
          'appointment_date': _selectedDate!.toIso8601String().split('T').join(' ').split('.')[0],
          'time_slot': _selectedTimeSlot!.toIso8601String().split('T').join(' ').split('.')[0],
        },
        token,
      );

      if (response != null && response['appointment'] != null) {
        final created = Appointment.fromJson(response['appointment']);
        _appointments.add(created);
        
        resetBookingForm();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error confirming booking: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
