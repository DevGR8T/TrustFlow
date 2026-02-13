import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../models/verification_response_model.dart';

/// Mock implementation for development and testing
/// 
/// This repository simulates backend responses with configurable delays
/// and error scenarios. Replace with [VerificationRepositoryImpl] in production.
/// 
/// Usage:
/// ```dart
/// // Normal flow
/// final repository = MockVerificationRepository();
/// 
/// // Simulate BVN errors
/// final repository = MockVerificationRepository(simulateBvnError: true);
/// ```
class MockVerificationRepository implements VerificationRepository {
  final bool simulateBvnError;
  final bool simulateDocumentError;
  final bool simulateFaceError;
  final Duration responseDelay;

  const MockVerificationRepository({
    this.simulateBvnError = false,
    this.simulateDocumentError = false,
    this.simulateFaceError = false,
    this.responseDelay = const Duration(seconds: 2),
  });

  @override
  Future<Either<Failure, void>> verifyBvn(String bvn) async {
    await Future.delayed(responseDelay);

    // Simulate network timeout
    if (bvn == '00000000000') {
      return const Left(NetworkFailure(
        message: 'Request timeout. Please check your connection.',
      ));
    }

    // Simulate BVN not found
    if (simulateBvnError || bvn == '12345678901') {
      return const Left(BvnFailure(
        message: 'BVN not found in NIBSS database. Please verify your BVN.',
        code: 'BVN_NOT_FOUND',
      ));
    }

    // Simulate BVN mismatch
    if (bvn == '11111111111') {
      return const Left(BvnFailure(
        message: 'BVN details do not match provided information.',
        code: 'BVN_MISMATCH',
      ));
    }

    // Success
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> uploadDocument({
    required String documentType,
    required String frontImagePath,
    String? backImagePath,
  }) async {
    await Future.delayed(responseDelay);

    // Simulate file size error
    if (frontImagePath.contains('large')) {
      return const Left(DocumentUploadFailure(
        message: 'File size exceeds 5MB limit.',
        code: 'FILE_TOO_LARGE',
      ));
    }

    // Simulate invalid format
    if (frontImagePath.contains('invalid')) {
      return const Left(DocumentUploadFailure(
        message: 'Invalid file format. Please upload JPG or PNG.',
        code: 'INVALID_FORMAT',
      ));
    }

    // Simulate upload error
    if (simulateDocumentError) {
      return const Left(DocumentUploadFailure(
        message: 'Failed to upload document. Please try again.',
        code: 'UPLOAD_FAILED',
      ));
    }

    // Success
    return const Right(null);
  }

@override
Future<Either<Failure, void>> uploadFaceCapture(
  String imagePath, {
  bool livenessVerified = false,
  Map<String, dynamic>? livenessData,
}) async {
  await Future.delayed(responseDelay);


  // REQUIRE liveness verification
  if (!livenessVerified) {
    return const Left(FaceCaptureFailure(
      message: 'Liveness verification required. Please complete all checks.',
      code: 'LIVENESS_REQUIRED',
    ));
  }

  // Validate all liveness checks passed
  if (livenessData != null) {
   
    
    final allPassed = livenessData['blink_detected'] == true &&
                      livenessData['smile_detected'] == true &&
                      livenessData['head_turn_left'] == true &&
                      livenessData['head_turn_right'] == true;
    
    if (!allPassed) {
      return const Left(FaceCaptureFailure(
        message: 'Incomplete liveness verification. Please retry.',
        code: 'LIVENESS_INCOMPLETE',
      ));
    }
  }

  if (imagePath.contains('no_face')) {
    return const Left(FaceCaptureFailure(
      message: 'No face detected. Please ensure your face is visible.',
      code: 'FACE_NOT_DETECTED',
    ));
  }

  if (imagePath.contains('blurry')) {
    return const Left(FaceCaptureFailure(
      message: 'Image quality too low. Please retake in good lighting.',
      code: 'POOR_QUALITY',
    ));
  }

  if (simulateFaceError) {
    return const Left(FaceCaptureFailure(
      message: 'Failed to upload selfie. Please try again.',
      code: 'UPLOAD_FAILED',
    ));
  }

  
  return const Right(null);
}

  @override
  Future<Either<Failure, VerificationResult>> getVerificationStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulate approved status
    return Right(VerificationResponseModel(
      referenceId: 'VTX-${DateTime.now().millisecondsSinceEpoch}',
      status: VerificationStatus.approved,
      message: 'Your identity has been successfully verified.',
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, void>> saveProgress(
    Map<String, dynamic> progress,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock local storage - always succeeds
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSavedProgress() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Return empty map if no saved progress
    // In real implementation, this would read from SharedPreferences/Hive
    return const Right({});
  }
}