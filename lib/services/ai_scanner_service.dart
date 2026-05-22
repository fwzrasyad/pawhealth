import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AIScannerService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      print("Model not loaded");
      return null;
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Convert image to a 3D float array (1, 224, 224, 3)
      var input = List.generate(
          1,
          (i) => List.generate(
              224,
              (y) => List.generate(
                  224,
                  (x) {
                    final pixel = resizedImage.getPixel(x, y);
                    // Standard Teachable Machine normalization
                    return [
                      (pixel.r - 127.5) / 127.5,
                      (pixel.g - 127.5) / 127.5,
                      (pixel.b - 127.5) / 127.5,
                    ];
                  })));

      var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

      _interpreter!.run(input, output);

      final probabilities = output[0];
      double maxProb = 0.0;
      int maxIndex = -1;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1) {
        String label = _labels![maxIndex];
        // Remove class number if present (e.g. "0 Ear Mites" -> "Ear Mites")
        label = label.replaceFirst(RegExp(r'^\d+\s+'), '');
        
        return {
          'label': label,
          'confidence': maxProb,
        };
      }
    } catch (e) {
      print("Error running inference: $e");
    }
    return null;
  }

  void dispose() {
    _interpreter?.close();
  }
}
