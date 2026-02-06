import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';


/// Business rule: Document image must exist
class UploadDocument {
  final VerificationRepository repository;

  UploadDocument(this.repository);

  Future<VerificationResult> call(String imagePath) async {
    // Business validation
    if (imagePath.isEmpty) {
      return VerificationResult.failure(
        message: 'No document image selected',
      );
    }

    // Call repository
    return await repository.uploadDocument(imagePath);
  }
}