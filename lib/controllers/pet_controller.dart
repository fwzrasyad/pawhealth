import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/pet_model.dart';
import '../models/recovery_plan_model.dart';
import '../models/vaccination_record_model.dart';
import '../models/health_journal_model.dart';

class PetController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _isLoading = false;

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void clearSelectedPet() {
    _selectedPet = null;
    notifyListeners();
  }

  // ── Fetch Pets ────────────────────────────────────────────────────────────

  /// Fetches all pets for the currently authenticated user from the backend.
  Future<void> fetchPets(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/pets', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _pets = data.map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching pets: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add Pet ───────────────────────────────────────────────────────────────

  /// Creates a new pet via the backend API.
  Future<void> addPet(Pet newPet) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.post('/pets', newPet.toJson(), token);
      final created = Pet.fromJson(response['data'] ?? response);
      _pets.add(created);
    } catch (e) {
      debugPrint('Error adding pet: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Update Pet ────────────────────────────────────────────────────────────

  /// Updates an existing pet via the backend API.
  Future<void> updatePet(Pet updatedPet) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.put(
        '/pets/${updatedPet.petId}',
        updatedPet.toJson(),
        token,
      );
      final updated = Pet.fromJson(response['data'] ?? response);

      final index = _pets.indexWhere((p) => p.petId == updated.petId);
      if (index != -1) {
        _pets[index] = updated;
        if (_selectedPet?.petId == updated.petId) {
          _selectedPet = updated;
        }
      }
    } catch (e) {
      debugPrint('Error updating pet: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Recovery Plan & Logs ──

  Future<void> addRecoveryLog(String planId, RecoveryLog log) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.post(
        '/recovery-plans/$planId/logs',
        log.toJson(),
        token,
      );

      // We should ideally re-fetch the pet or the specific recovery plan
      // to keep it in sync. For now, we assume the UI will re-fetch or optimistically update.
    } catch (e) {
      debugPrint('Error adding recovery log: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Vaccinations ──

  Future<void> fetchVaccinations(String petId) async {
    // Usually called individually, or loaded with the pet
  }

  Future<void> addVaccinationRecord(String petId, VaccinationRecord record) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      final response = await _apiService.post(
        '/pets/$petId/vaccinations',
        record.toJson(),
        token,
      );
      
      // Update local pet vaccinations
      final petIndex = _pets.indexWhere((p) => p.petId == petId);
      if (petIndex != -1) {
        final currentPet = _pets[petIndex];
        final newVaccination = VaccinationRecord.fromJson(response['data'] ?? response);
        
        final updatedVaccinations = List<VaccinationRecord>.from(currentPet.vaccinations)..add(newVaccination);
        final updated = currentPet.copyWith(vaccinations: updatedVaccinations);
        _pets[petIndex] = updated;
        if (_selectedPet?.petId == petId) _selectedPet = updated;
      }
    } catch (e) {
      debugPrint('Error adding vaccination: $e');
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Add Health Journal Entry ──────────────────────────────────────────────

  /// Adds a health journal entry for a specific pet via the backend API.
  Future<void> addHealthJournalEntry(String petId, HealthJournalEntry entry) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.post(
        '/pets/$petId/health-journals',
        entry.toJson(),
        token,
      );

      debugPrint('Health journal entry added successfully');
    } catch (e) {
      debugPrint('Error adding health journal entry: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches all health journal entries for a specific pet.
  Future<List<HealthJournalEntry>> fetchHealthJournalEntries(String petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get(
        '/pets/$petId/health-journals',
        token: token,
      );
      final List<dynamic> data = response['data'] ?? response;
      final entries = data.map((json) => HealthJournalEntry.fromJson(json)).toList();
      
      _isLoading = false;
      notifyListeners();
      return entries;
    } catch (e) {
      debugPrint('Error fetching health journal entries: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // ── Upload Profile Picture ────────────────────────────────────────────────

  Future<void> uploadProfilePicture(String petId) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (image == null) return;

      _isLoading = true;
      notifyListeners();

      final File imageFile = File(image.path);
      final token = await _getToken();
      final multipartFile = await http.MultipartFile.fromPath('profile_image', imageFile.path);

      final response = await _apiService.multipartPost(
        '/pets/$petId',
        token,
        fields: {
          '_method': 'PUT',
        },
        file: multipartFile,
      );

      final updated = Pet.fromJson(response['data'] ?? response);
      final index = _pets.indexWhere((p) => p.petId == petId);
      if (index != -1) {
        _pets[index] = updated;
        if (_selectedPet?.petId == petId) _selectedPet = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
