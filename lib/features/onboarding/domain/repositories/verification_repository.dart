import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/verification_result.dart';

abstract class VerificationRepository {
  Future<Either<Failure, void>> verifyBvn(String bvn);

  Future<Either<Failure, void>> uploadDocument({
    required String documentType,
    required String frontImagePath,
    String? backImagePath,
  });

  Future<Either<Failure, void>> uploadFaceCapture(
  String imagePath, {
  bool livenessVerified,
  Map<String, dynamic>? livenessData,
});

  Future<Either<Failure, VerificationResult>> getVerificationStatus();

  Future<Either<Failure, void>> saveProgress(Map<String, dynamic> progress);

  Future<Either<Failure, Map<String, dynamic>>> getSavedProgress();
}