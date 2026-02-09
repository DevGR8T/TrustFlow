import '../entities/verification_result.dart';
import '../entities/onboarding_progress.dart';
import '../entities/user_data.dart';


/// Defines the contract for data operations
/// Implementation will be in the data layer
abstract class VerificationRepository {
  /// Verify BVN
  Future<VerificationResult> verifyBvn(String bvn);

  /// Upload document
  Future<VerificationResult> uploadDocument(String imagePath);

  /// Upload face capture
  Future<VerificationResult> uploadFaceCapture(String imagePath);

  /// Check final verification status
  Future<VerificationResult> checkVerificationStatus();

  /// Save user progress
  Future<void> saveProgress(OnboardingProgress progress, UserData userData);

  /// Get saved progress
  Future<OnboardingProgress?> getSavedProgress();

  /// Get saved user data
  Future<UserData?> getSavedUserData();

  /// Clear all saved data
  Future<void> clearAllData();
}