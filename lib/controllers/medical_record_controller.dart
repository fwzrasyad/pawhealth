import 'package:flutter/material.dart';
import '../models/medical_record_model.dart';

class MedicalRecordController extends ChangeNotifier {
  final String _mockPetId = 'pet_123';
  
  final List<MedicalRecord> _records = [
    MedicalRecord(
      recordId: 'rec_001',
      petId: 'pet_123',
      vetId: 'vet_001',
      diagnosis: 'Annual Physical Examination',
      treatment: 'General checkup, healthy. Found minor tartar build-up.',
      vaccinationDate: DateTime.now().subtract(const Duration(days: 100)),
      nextDueDate: DateTime.now().add(const Duration(days: 265)),
      attachmentUrl: 'https://example.com/report1.pdf',
    ),
    MedicalRecord(
      recordId: 'rec_002',
      petId: 'pet_123',
      vetId: 'vet_001',
      diagnosis: 'Rabies Vaccination',
      treatment: 'Administered 1 dose of Rabies vaccine.',
      vaccinationDate: DateTime.now().subtract(const Duration(days: 350)),
      nextDueDate: DateTime.now().add(const Duration(days: 15)), // Highlighting due soon
    ),
    MedicalRecord(
      recordId: 'rec_003',
      petId: 'pet_123',
      vetId: 'vet_002',
      diagnosis: 'Allergic Reaction',
      treatment: 'Prescribed antihistamines for mild skin allergy.',
      vaccinationDate: null,
      nextDueDate: null,
    ),
  ];

  List<MedicalRecord> get records => _records;
  
  // Get records for a specific pet
  List<MedicalRecord> getRecordsByPet(String petId) {
    return _records.where((record) => record.petId == petId).toList();
  }

  void addRecord(MedicalRecord record) {
    _records.insert(0, record); // Add to top of list
    notifyListeners();
  }
  
  String get mockPetId => _mockPetId;
}
