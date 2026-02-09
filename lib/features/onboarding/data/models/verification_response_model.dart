import 'dart:convert';
import '../../domain/entities/verification_result.dart';

/// Verification Response Model
/// Handles API response structure
class VerificationResponseModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const VerificationResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  /// Convert to VerificationResult entity
  VerificationResult toEntity() {
    if (success) {
      return VerificationResult.success(
        message: message,
        data: data,
      );
    } else {
      return VerificationResult.failure(
        message: message,
        data: data,
      );
    }
  }

  /// Create from Map
  factory VerificationResponseModel.fromMap(Map<String, dynamic> map) {
    return VerificationResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: map['data'],
    );
  }

  /// Create from JSON
  factory VerificationResponseModel.fromJson(String source) {
    return VerificationResponseModel.fromMap(json.decode(source));
  }
}