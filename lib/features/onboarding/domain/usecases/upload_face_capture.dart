import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';


/// Business rule: Face image must exist
class UploadFaceCapture {
  final VerificationRepository repository;

  UploadFaceCapture(this.repository);

  Future<VerificationResult> call(String imagePath) async {
    // Business validation
    if (imagePath.isEmpty) {
      return VerificationResult.failure(
        message: 'No face image captured',
      );
    }

    // Call repository
    return await repository.uploadFaceCapture(imagePath);
  }
}