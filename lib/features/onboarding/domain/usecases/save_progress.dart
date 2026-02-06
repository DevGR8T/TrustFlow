import '../entities/onboarding_progress.dart';
import '../entities/user_data.dart';
import '../repositories/verification_repository.dart';


/// Allows user to exit and resume onboarding
class SaveProgress {
  final VerificationRepository repository;

  SaveProgress(this.repository);

  Future<void> call(OnboardingProgress progress, UserData userData) async {
    await repository.saveProgress(progress, userData);
  }
}