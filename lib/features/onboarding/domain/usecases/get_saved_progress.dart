import '../entities/onboarding_progress.dart';
import '../repositories/verification_repository.dart';


/// Retrieves previously saved progress
class GetSavedProgress {
  final VerificationRepository repository;

  GetSavedProgress(this.repository);

  Future<OnboardingProgress?> call() async {
    return await repository.getSavedProgress();
  }
}