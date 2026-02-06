import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';


/// Business rule: BVN must be exactly 11 digits
class VerifyBvn {
  final VerificationRepository repository;

  VerifyBvn(this.repository);

  Future<VerificationResult> call(String bvn) async {
    // Business validation
    if (bvn.isEmpty) {
      return VerificationResult.failure(
        message: 'BVN cannot be empty',
      );
    }

    if (bvn.length != 11) {
      return VerificationResult.failure(
        message: 'BVN must be exactly 11 digits',
      );
    }

    if (!_isNumeric(bvn)) {
      return VerificationResult.failure(
        message: 'BVN must contain only numbers',
      );
    }

    // Call repository
    return await repository.verifyBvn(bvn);
  }

  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }
}