import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trust_flow/features/onboarding/domain/repositories/liveness_detector_repository_impl.dart';


class LivenessDetectorRepositoryImpl implements LivenessDetectorRepository {
  static const double _eyesOpenThreshold = 0.80;
  static const double _eyesClosedThreshold = 0.20;
  static const double _minFaceSize = 0.20;
  static const double _maxFaceSize = 0.90;
  static const double _maxOffset = 0.35;

  String _validationMessage = '';

  @override
  bool isFaceValid(Face face, Size imageSize) {
    final faceW = face.boundingBox.width / imageSize.width;
    final faceH = face.boundingBox.height / imageSize.height;

    if (faceW < _minFaceSize || faceH < _minFaceSize) {
      _validationMessage = 'Move closer to the camera';
      return false;
    }

    if (faceW > _maxFaceSize || faceH > _maxFaceSize) {
      _validationMessage = 'Move further from the camera';
      return false;
    }

    final offsetX = (face.boundingBox.center.dx - imageSize.width / 2).abs();
    final offsetY = (face.boundingBox.center.dy - imageSize.height / 2).abs();

    if (offsetX > imageSize.width * _maxOffset || 
        offsetY > imageSize.height * _maxOffset) {
      _validationMessage = 'Center your face in the frame';
      return false;
    }

    return true;
  }

  @override
  String getFaceValidationMessage() => _validationMessage;

  @override
  int updateBlinkState(double leftEye, double rightEye, int currentState) {
    final minEye = min(leftEye, rightEye);

    switch (currentState) {
      case 0:
        if (minEye > _eyesOpenThreshold) {
          debugPrint('👁 State 0→1: Eyes confirmed OPEN');
          return 1;
        }
        return 0;
      case 1:
        if (minEye < _eyesClosedThreshold) {
          debugPrint('👁 State 1→2: Eyes CLOSED detected');
          return 2;
        }
        return 1;
      case 2:
        if (minEye > _eyesOpenThreshold) {
          debugPrint('✅ BLINK COMPLETE');
          return 3;
        }
        return 2;
      default:
        return currentState;
    }
  }

  @override
  bool isSmileDetected(double? smile, int frames, int required) {
    return smile != null && smile > 0.70 && frames >= required;
  }

  @override
  bool isLeftTurnDetected(double? headY, int frames, int required) {
    return headY != null && headY > 12 && frames >= required;
  }

  @override
  bool isRightTurnDetected(double? headY, int frames, int required) {
    return headY != null && headY < -12 && frames >= required;
  }

  @override
  Future<String> capturePhoto(dynamic cameraController) async {
    await cameraController.stopImageStream();
    await Future.delayed(const Duration(milliseconds: 500));

    final image = await cameraController.takePicture();
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/selfie_verified_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(image.path).copy(imagePath);

    debugPrint('✅ Photo captured: $imagePath');
    return imagePath;
  }
}