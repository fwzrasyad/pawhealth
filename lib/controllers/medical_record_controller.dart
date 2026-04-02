import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/medical_record_model.dart';

class MedicalRecordController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MedicalRecord> _records = [];
  bool _isLoading = false;

  List<MedicalRecord> get records => _records;
  bool get isLoading => _isLoading;

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ── Fetch Medical Records ─────────────────────────────────────────────────

  /// Fetches all medical records for a specific pet from the backend.
  Future<void> fetchMedicalRecords(String petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/pets/$petId/medical-records', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _records = data.map((json) => MedicalRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching medical records: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Add Medical Record ────────────────────────────────────────────────────

  /// Creates a new medical record via the backend.
  Future<void> addMedicalRecord(String petId, MedicalRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.post(
        '/medical-records',
        record.toJson(),
        token,
      );

      final created = MedicalRecord.fromJson(response['data'] ?? response);
      _records.insert(0, created); // Add to top of list
    } catch (e) {
      print('Error adding medical record: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Get Records by Pet (local filter) ─────────────────────────────────────

  /// Filters the locally cached records by pet ID.
  List<MedicalRecord> getRecordsByPet(String petId) {
    return _records.where((record) => record.petId == petId).toList();
  }
}
