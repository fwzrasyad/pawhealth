import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart' as picker;
import '../services/api_service.dart';
import '../services/ai_scanner_service.dart';
import '../models/ai_scan_model.dart';

/// Enum to represent which image source the user chose
enum ImagePickerSource { camera, gallery }

class SmartAnalyzerController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AIScannerService _aiScannerService = AIScannerService();
  final picker.ImagePicker _picker = picker.ImagePicker();

  String? _selectedImagePath;
  bool _isAnalyzing = false;
  AIScan? _currentScanResult;
  List<AIScan> _scanHistory = [];
  bool _isLoading = false;

  String? get selectedImagePath => _selectedImagePath;
  bool get isAnalyzing => _isAnalyzing;
  AIScan? get currentScanResult => _currentScanResult;
  List<AIScan> get scanHistory => _scanHistory;
  bool get isLoading => _isLoading;

  SmartAnalyzerController() {
    _initModel();
  }

  Future<void> _initModel() async {
    await _aiScannerService.loadModel();
  }

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ── Image Picking ─────────────────────────────────────────────────────────

  /// Real image picking using image_picker plugin.
  /// Returns true if an image was successfully selected.
  Future<bool> pickImage(ImagePickerSource source) async {
    final pickerSource = source == ImagePickerSource.camera
        ? picker.ImageSource.camera
        : picker.ImageSource.gallery;

    try {
      final pickedFile = await _picker.pickImage(source: pickerSource);
      
      if (pickedFile != null) {
        _selectedImagePath = pickedFile.path;
        // Clear previous result when a new image is selected
        _currentScanResult = null;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    
    return false;
  }

  // ── Fetch AI Scan History ─────────────────────────────────────────────────

  /// Fetches all past AI scans for a specific pet from the backend.
  Future<void> fetchAiScans(String petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/pets/$petId/ai-scans', token: token);
      final List<dynamic> data = response['data'] ?? response;
      _scanHistory = data.map((json) => AIScan.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching AI scans: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Analyze Image ─────────────────────────────────────────────────────────

  /// Analyzes the selected image using the local TFLite model.
  Future<void> analyzeImage({required String petId}) async {
    if (_selectedImagePath == null) return;

    _isAnalyzing = true;
    notifyListeners();

    try {
      final file = File(_selectedImagePath!);
      final result = await _aiScannerService.analyzeImage(file);

      if (result != null) {
        _currentScanResult = AIScan(
          scanId: 'local_${DateTime.now().millisecondsSinceEpoch}',
          petId: petId,
          scanDate: DateTime.now(),
          imageUrl: _selectedImagePath!,
          aiResultLabel: result['label'],
          confidenceScore: result['confidence'],
        );
      } else {
        print('TFLite inference returned null.');
        _currentScanResult = null;
      }
    } catch (e) {
      print('Error analyzing image locally: $e');
      _currentScanResult = null;
    }

    _isAnalyzing = false;
    notifyListeners();
  }

  // ── Save Scan to Log ──────────────────────────────────────────────────────

  /// This method adds it to the local history. 
  /// Since the scanning is purely local, this doesn't hit the DB anymore unless specifically implemented.
  Future<bool> saveScanToLog() async {
    if (_currentScanResult == null) return false;
    _scanHistory.add(_currentScanResult!);
    notifyListeners();
    return true;
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  /// Resets state for a new scan session.
  void resetScan() {
    _selectedImagePath = null;
    _currentScanResult = null;
    _isAnalyzing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _aiScannerService.dispose();
    super.dispose();
  }
}
