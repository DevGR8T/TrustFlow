import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceMatchService {
  static const String _modelPath = 'assets/models/facenet.tflite';
  static const int _inputSize = 112;
  static const double _matchThreshold = 0.60;

  Interpreter? _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.1,
    ),
  );

  Future<void> initialize() async {
    _interpreter ??= await Interpreter.fromAsset(_modelPath);
  }

  Future<void> dispose() async {
    _interpreter?.close();
    await _faceDetector.close();
  }

  /// Extract face embedding from an image file path
Future<List<double>?> extractEmbedding(String imagePath, {bool isSelfie = false}) async {
  await initialize();

  try {
    final imageBytes = await File(imagePath).readAsBytes();
    var decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    // Flip BEFORE face detection so ML Kit sees the correct orientation
    if (isSelfie) decoded = img.flipHorizontal(decoded);

    // Save flipped image to temp file for ML Kit
    final tempDir = await Directory.systemTemp.createTemp();
    final tempPath = '${tempDir.path}/temp_face.jpg';
    await File(tempPath).writeAsBytes(img.encodeJpg(decoded, quality: 95));

   
   // Detect face on the corrected image
    final inputImage = InputImage.fromFilePath(tempPath);
    final faces = await _faceDetector.processImage(inputImage);
    print('[FaceMatchService] isSelfie=$isSelfie, faces found: ${faces.length}, tempPath: $tempPath');

    if (faces.isEmpty) {
      print('[FaceMatchService] No face detected — returning null');
      return null;
    }

    // Use the largest face found
    final face = faces.reduce((a, b) =>
        a.boundingBox.width > b.boundingBox.width ? a : b);

    // Crop, resize and run inference on already-decoded image
    final cropped = _cropFace(decoded, face.boundingBox);
    final resized = img.copyResize(
      cropped,
      width: _inputSize,
      height: _inputSize,
    );

    final input = _imageToFloat32(resized);
   final output = List.generate(1, (_) => List<double>.filled(128, 0));
    _interpreter!.run(input, output);

    // Clean up temp file
    await tempDir.delete(recursive: true);

    return output[0];
} catch (e) {
    print('[FaceMatchService] ERROR: $e');
    return null;
  }
}

  /// Compare two embeddings using cosine similarity
  /// Returns similarity score between 0.0 and 1.0
  double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// Returns true if selfie matches ID photo above threshold
  bool isMatch(double similarity) => similarity >= _matchThreshold;

  double get matchThreshold => _matchThreshold;

  // ── Private helpers ──────────────────────────────────────────

  img.Image _cropFace(img.Image source, Rect boundingBox) {
    // Add 20% padding around the face
    final padding = boundingBox.width * 0.2;

    final x = (boundingBox.left - padding).clamp(0, source.width - 1).toInt();
    final y = (boundingBox.top - padding).clamp(0, source.height - 1).toInt();
    final w = (boundingBox.width + padding * 2)
        .clamp(1, source.width - x)
        .toInt();
    final h = (boundingBox.height + padding * 2)
        .clamp(1, source.height - y)
        .toInt();

    return img.copyCrop(source, x: x, y: y, width: w, height: h);
  }

  List<List<List<List<double>>>> _imageToFloat32(img.Image image) {
    return List.generate(1, (_) =>
      List.generate(_inputSize, (y) =>
        List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);
          return [
            (pixel.r / 127.5) - 1.0,
            (pixel.g / 127.5) - 1.0,
            (pixel.b / 127.5) - 1.0,
          ];
        })
      )
    );
  }
}