import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/ai_scan_model.dart';

/// Enum to represent which image source the user chose
enum ImagePickerSource { camera, gallery }

class SmartAnalyzerController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

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

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ── Image Picking ─────────────────────────────────────────────────────────

  /// Mock image picking – in production this would call image_picker plugin.
  /// Returns true if an image was "selected" (always succeeds in mock).
  Future<bool> pickImage(ImagePickerSource source) async {
    // Simulate a short picker delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock: use a placeholder path that indicates the source
    _selectedImagePath = source == ImagePickerSource.camera
        ? 'mock://camera_capture_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : 'mock://gallery_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Clear previous result when a new image is selected
    _currentScanResult = null;
    notifyListeners();
    return true;
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

  /// Sends the image data to the backend for AI analysis and receives results.
  Future<void> analyzeImage({required String petId}) async {
    if (_selectedImagePath == null) return;

    _isAnalyzing = true;
    notifyListeners();

    try {
      final token = await _getToken();

      final response = await _apiService.post('/pets/$petId/ai-scans', {
        'image_url': _selectedImagePath!,
        'pet_id': petId,
      }, token);

      final scanData = response['data'] ?? response;
      _currentScanResult = AIScan.fromJson(scanData);
    } catch (e) {
      print('Error analyzing image: $e');
    }

    _isAnalyzing = false;
    notifyListeners();
  }

  // ── Save Scan to Log ──────────────────────────────────────────────────────

  /// The scan is already persisted by the POST in analyzeImage().
  /// This method adds it to the local history and returns success.
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
}
