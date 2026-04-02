import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/appointment_model.dart';
import '../models/pet_model.dart';
import '../models/medical_record_model.dart';
import '../models/veterinarian_model.dart';

class VetController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Appointment> _appointments = [];
  List<Pet> _pets = [];
  List<MedicalRecord> _medicalRecords = [];
  List<Veterinarian> _veterinarians = [];

  /// The currently logged-in vet's own profile.
  Veterinarian? _myProfile;

  /// Weekly schedule being edited (local state before saving).
  Map<String, List<String>> _weeklySchedule = {};

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
  List<Veterinarian> get veterinarians => _veterinarians;
  Veterinarian? get myProfile => _myProfile;
  Map<String, List<String>> get weeklySchedule => Map.unmodifiable(_weeklySchedule);

  /// All 7 day names used as keys.
  static const List<String> dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  /// Default time slots vets can toggle (9am–5pm, hourly).
  static const List<String> defaultTimeSlots = [
    '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00',
  ];

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  VET PROFILE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a new veterinarian profile for the currently authenticated user.
  /// Called once during vet registration.
  Future<bool> createVetProfile({
    required String name,
    String bio = '',
    String workingHours = '9:00 AM - 5:00 PM',
    List<String> specialties = const [],
  }) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/veterinarians', {
        'name': name,
        'bio': bio,
        'working_hours': workingHours,
        'specialties': specialties,
        'weekly_schedule': {},
      }, token);

      final profileData = response['data'] ?? response;
      _myProfile = Veterinarian.fromJson(profileData);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating vet profile: $e');
      return false;
    }
  }

  /// Fetches the current vet's own profile from the backend.
  Future<void> fetchMyVetProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/veterinarians/me', token: token);
      final profileData = response['data'] ?? response;
      _myProfile = Veterinarian.fromJson(profileData);
      _weeklySchedule = Map<String, List<String>>.from(
        _myProfile!.weeklySchedule.map((k, v) => MapEntry(k, List<String>.from(v))),
      );
    } catch (e) {
      debugPrint('Error fetching vet profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Updates the vet's profile (bio, specialties, working hours, etc.).
  Future<bool> updateVetProfile({
    String? name,
    String? bio,
    String? workingHours,
    List<String>? specialties,
  }) async {
    if (_myProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (workingHours != null) body['working_hours'] = workingHours;
      if (specialties != null) body['specialties'] = specialties;

      final response = await _apiService.put(
        '/veterinarians/${_myProfile!.vetId}',
        body,
        token,
      );

      final profileData = response['data'] ?? response;
      _myProfile = Veterinarian.fromJson(profileData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating vet profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  WEEKLY SCHEDULE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Toggles a time slot for a specific day in the local schedule.
  void toggleDaySlot(String day, String time) {
    final slots = List<String>.from(_weeklySchedule[day] ?? []);
    if (slots.contains(time)) {
      slots.remove(time);
    } else {
      slots.add(time);
      slots.sort();
    }
    _weeklySchedule[day] = slots;
    notifyListeners();
  }

  /// Checks if a specific time slot is enabled for a day.
  bool isDaySlotEnabled(String day, String time) {
    return (_weeklySchedule[day] ?? []).contains(time);
  }

  /// Saves the current weekly schedule to the backend.
  Future<bool> saveWeeklySchedule() async {
    if (_myProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.put(
        '/veterinarians/${_myProfile!.vetId}',
        {'weekly_schedule': _weeklySchedule},
        token,
      );

      _myProfile = _myProfile!.copyWith(weeklySchedule: Map.from(_weeklySchedule));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving weekly schedule: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH DATA (existing, unchanged)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetches the list of all veterinarians from the backend.
  Future<void> fetchVeterinarians() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/veterinarians', token: token);
      final List<dynamic> vetData = response['data'] ?? response;
      _veterinarians = vetData.map((json) => Veterinarian.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching veterinarians: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches details for a single veterinarian.
  Future<Veterinarian?> fetchVetDetails(String vetId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/veterinarians/$vetId', token: token);
      final vetData = response['data'] ?? response;
      return Veterinarian.fromJson(vetData);
    } catch (e) {
      debugPrint('Error fetching vet details: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches appointments assigned to the currently logged-in vet.
  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/appointments', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _appointments = data.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching vet appointments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches patient pets the vet has access to.
  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/pets', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _pets = data.map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching patients: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches medical records for a specific pet.
  Future<void> fetchMedicalRecords(String petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/pets/$petId/medical-records', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _medicalRecords = data.map((json) => MedicalRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching medical records: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  APPOINTMENT MANAGEMENT (existing, unchanged)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> acceptAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.put('/appointments/$appointmentId', {
        'status': AppointmentStatus.confirmed.name,
      }, token);

      final idx = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
      if (idx != -1) {
        _appointments[idx] = _appointments[idx].copyWith(status: AppointmentStatus.confirmed);
      }
    } catch (e) {
      debugPrint('Error accepting appointment: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.put('/appointments/$appointmentId', {
        'status': AppointmentStatus.cancelled.name,
      }, token);

      final idx = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
      if (idx != -1) {
        _appointments[idx] = _appointments[idx].copyWith(status: AppointmentStatus.cancelled);
      }
    } catch (e) {
      debugPrint('Error rejecting appointment: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Convenience Getters ───────────────────────────────────────────────────

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
