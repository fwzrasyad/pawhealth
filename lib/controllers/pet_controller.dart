import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../models/daily_routine_model.dart';

class PetController extends ChangeNotifier {
  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _isLoading = false;

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void clearSelectedPet() {
    _selectedPet = null;
    notifyListeners();
  }

  /// Fetch pets (mock data including the black cat Cola)
  Future<void> fetchPets(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _pets = [
      Pet(
        petId: 'pet_1',
        ownerId: ownerId,
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        age: 3,
        gender: 'Male',
        weight: 29.5,
        dailyRoutines: [
          DailyRoutineLog(
            id: 'log_1',
            petId: 'pet_1',
            date: DateTime.now().subtract(const Duration(days: 1)),
            weight: 29.5,
            dietNotes: 'Ate normal portions. Dry food.',
            activityLevel: 'High Activity',
          )
        ],
      ),
      Pet(
        petId: 'pet_2',
        ownerId: ownerId,
        name: 'Cola',
        species: 'Cat',
        breed: 'Domestic Shorthair (Black)',
        age: 1,
        gender: 'Female',
        weight: 4.8,
        dailyRoutines: [
          DailyRoutineLog(
            id: 'log_2',
            petId: 'pet_2',
            date: DateTime.now().subtract(const Duration(days: 2)),
            weight: 4.8,
            dietNotes: 'Wet food morning and evening. Good appetite.',
            activityLevel: 'Moderate',
          )
        ],
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new pet
  Future<void> addPet(Pet newPet) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _pets.add(newPet);
    _isLoading = false;
    notifyListeners();
  }

  /// Update an existing pet
  Future<void> updatePet(Pet updatedPet) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _pets.indexWhere((p) => p.petId == updatedPet.petId);
    if (index != -1) {
      _pets[index] = updatedPet;
      // Keep selectedPet in sync
      if (_selectedPet?.petId == updatedPet.petId) {
        _selectedPet = updatedPet;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Add a daily routine log to a specific pet
  Future<void> addDailyRoutineLog(String petId, DailyRoutineLog log) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _pets.indexWhere((p) => p.petId == petId);
    if (index != -1) {
      final updatedRoutines = List<DailyRoutineLog>.from(_pets[index].dailyRoutines)..add(log);
      final updatedPet = _pets[index].copyWith(
        dailyRoutines: updatedRoutines,
        weight: log.weight,
      );
      _pets[index] = updatedPet;
      if (_selectedPet?.petId == petId) _selectedPet = updatedPet;
    }

    _isLoading = false;
    notifyListeners();
  }
}
