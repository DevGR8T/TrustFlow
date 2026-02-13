import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';

abstract class LivenessDetectorRepository {
  bool isFaceValid(Face face, Size imageSize);
  String getFaceValidationMessage();
  int updateBlinkState(double leftEye, double rightEye, int currentState);
  bool isSmileDetected(double? smileProbability, int frames, int required);
  bool isLeftTurnDetected(double? headY, int frames, int required);
  bool isRightTurnDetected(double? headY, int frames, int required);
  Future<String> capturePhoto(dynamic cameraController);
}