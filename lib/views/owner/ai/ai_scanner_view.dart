import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/ai_scanner_service.dart';
import 'ai_results_view.dart';

class AIScannerView extends StatefulWidget {
  const AIScannerView({super.key});

  @override
  State<AIScannerView> createState() => _AIScannerViewState();
}

class _AIScannerViewState extends State<AIScannerView> {
  final AIScannerService _aiService = AIScannerService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isModelLoaded = false;
  String? _errorMessage;
  
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _aiService.loadModel();
    setState(() {
      _isModelLoaded = true;
    });
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_isModelLoaded) return;
    
    setState(() {
      _errorMessage = null;
    });

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _analyzeImage(File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _aiService.analyzeImage(imageFile);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      double confidence = result['confidence'];
      String label = result['label'];

      if (confidence < 0.95) {
        setState(() {
          _errorMessage = "Scan Inconclusive (Confidence: ${(confidence * 100).toStringAsFixed(1)}%). Please ensure the photo is well-lit, in focus, and clearly shows the affected area, then try again.";
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIResultsView(
              imageFile: imageFile,
              label: label,
              confidence: confidence,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Failed to analyze image. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _purple,
        elevation: 0,
        title: const Text(
          'AI Symptom Analyzer',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _purple),
                SizedBox(height: 16),
                Text(
                  "Analyzing scan...",
                  style: TextStyle(fontFamily: 'Poppins', color: _purple, fontWeight: FontWeight.w600),
                )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.document_scanner_outlined, size: 80, color: _purple),
                const SizedBox(height: 24),
                const Text(
                  "Scan your pet's affected area",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Our AI model will analyze the image to detect common skin conditions and parasites.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),
                
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.red.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isModelLoaded ? () => _pickImage(ImageSource.camera) : null,
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text("Camera", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isModelLoaded ? () => _pickImage(ImageSource.gallery) : null,
                        icon: const Icon(Icons.photo_library, color: _purple),
                        label: const Text("Gallery", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: _purple)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _lightPurple,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_isModelLoaded)
                  const Text(
                    "Loading AI Model...",
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 12),
                  )
              ],
            ),
          ),
    );
  }
}
