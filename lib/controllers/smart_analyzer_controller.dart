import 'package:flutter/foundation.dart';
import '../models/ai_scan_model.dart';

/// Enum to represent which image source the user chose
enum ImagePickerSource { camera, gallery }

class SmartAnalyzerController extends ChangeNotifier {
  String? _selectedImagePath;
  bool _isAnalyzing = false;
  AIScan? _currentScanResult;
  final List<AIScan> _scanHistory = [];

  String? get selectedImagePath => _selectedImagePath;
  bool get isAnalyzing => _isAnalyzing;
  AIScan? get currentScanResult => _currentScanResult;
  List<AIScan> get scanHistory => _scanHistory;

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

  /// Simulates ML Kit analysis with a 2-second processing delay.
  Future<void> analyzeImage({String petId = 'pet_1'}) async {
    if (_selectedImagePath == null) return;

    _isAnalyzing = true;
    notifyListeners();

    // Simulate ML model inference time
    await Future.delayed(const Duration(seconds: 2));

    // Mock result pool – randomly pick one to feel realistic
    final mockResults = [
      {'label': 'Mild Skin Rash', 'confidence': 0.85},
      {'label': 'Possible Ear Infection', 'confidence': 0.78},
      {'label': 'Coat Appears Healthy', 'confidence': 0.92},
      {'label': 'Minor Wound Detected', 'confidence': 0.71},
      {'label': 'Eye Discharge Observed', 'confidence': 0.80},
    ];
    final pick = mockResults[DateTime.now().second % mockResults.length];

    _currentScanResult = AIScan(
      scanId: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      scanDate: DateTime.now(),
      imageUrl: _selectedImagePath!,
      aiResultLabel: pick['label'] as String,
      confidenceScore: pick['confidence'] as double,
    );

    _isAnalyzing = false;
    notifyListeners();
  }

  /// Simulates persisting the scan to the pet's history log.
  Future<bool> saveScanToLog() async {
    if (_currentScanResult == null) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    _scanHistory.add(_currentScanResult!);
    notifyListeners();
    return true;
  }

  /// Resets state for a new scan session.
  void resetScan() {
    _selectedImagePath = null;
    _currentScanResult = null;
    _isAnalyzing = false;
    notifyListeners();
  }
}
