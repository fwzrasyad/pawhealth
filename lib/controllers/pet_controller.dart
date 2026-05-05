import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/pet_model.dart';
import '../models/daily_routine_model.dart';

class PetController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

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

  // ── Add Daily Routine Log ─────────────────────────────────────────────────

  /// Adds a daily routine log for a specific pet via the backend API.
  Future<void> addDailyRoutineLog(String petId, DailyRoutineLog log) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      await _apiService.post(
        '/pets/$petId/daily-routines',
        log.toJson(),
        token,
      );

      // Update local state to reflect the new log
      final index = _pets.indexWhere((p) => p.petId == petId);
      if (index != -1) {
        final updatedRoutines = List<DailyRoutineLog>.from(
          _pets[index].dailyRoutines,
        )..add(log);
        final updatedPet = _pets[index].copyWith(
          dailyRoutines: updatedRoutines,
          weight: log.weight,
        );
        _pets[index] = updatedPet;
        if (_selectedPet?.petId == petId) _selectedPet = updatedPet;
      }
    } catch (e) {
      debugPrint('Error adding daily routine log: $e');
    }

    _isLoading = false;
    notifyListeners();
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
      final String downloadUrl = await _storageService.uploadPetProfileImage(petId, imageFile);

      final index = _pets.indexWhere((p) => p.petId == petId);
      if (index != -1) {
        final updatedPet = _pets[index].copyWith(profileImageUrl: downloadUrl);
        await updatePet(updatedPet); 
      } else {
        final token = await _getToken();
        await _apiService.put(
          '/pets/$petId',
          {'profile_image_url': downloadUrl},
          token,
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
