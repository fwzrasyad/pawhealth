import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/veterinarian_model.dart';
import '../models/appointment_model.dart';

class AppointmentController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Veterinarian? _selectedVet;
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot;

  List<Appointment> _appointments = [];
  List<Veterinarian> _vets = [];
  bool _isLoading = false;

  Veterinarian? get selectedVet => _selectedVet;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedTimeSlot => _selectedTimeSlot;
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

  // ── Fetch Veterinarians ───────────────────────────────────────────────────

  /// Fetches the list of all available veterinarians from the backend.
  Future<void> fetchVeterinarians() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/veterinarians', token: token);
      final List<dynamic> vetData = response['data'] ?? response;
      _vets = vetData.map((json) => Veterinarian.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching veterinarians: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches details for a single veterinarian by ID.
  Future<Veterinarian?> fetchVetDetails(String vetId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/veterinarians/$vetId', token: token);
      final vetData = response['data'] ?? response;
      return Veterinarian.fromJson(vetData);
    } catch (e) {
      print('Error fetching vet details: $e');
      return null;
    }
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

  /// Books a consultation using the currently selected vet, date, and time slot.
  /// Creates a real appointment via the API.
  Future<bool> bookConsultation({String petId = 'pet_1', String petName = 'My Pet'}) async {
    if (_selectedVet == null || _selectedDate == null || _selectedTimeSlot == null) return false;

    final appointment = Appointment(
      appointmentId: '', // Backend will assign the real ID
      petId: petId,
      petName: petName,
      vetId: _selectedVet!.vetId,
      vetName: _selectedVet!.name,
      reason: 'General Consultation',
      appointmentDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      status: AppointmentStatus.pending,
    );

    final success = await createAppointment(appointment);

    if (success) {
      _selectedVet = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
      notifyListeners();
    }

    return success;
  }
}
