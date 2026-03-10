import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_progress.dart';
import '../../domain/entities/verification_result.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial / blank slate
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Any async operation in flight
class OnboardingLoading extends OnboardingState {
  final String? message;
  const OnboardingLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Consent recorded
class ConsentSaved extends OnboardingState {
  const ConsentSaved();
}

/// Personal info saved locally
class PersonalInfoSaved extends OnboardingState {
  const PersonalInfoSaved();
}

/// BVN successfully verified with NIBSS
class BvnVerified extends OnboardingState {
  const BvnVerified();
}

/// Document uploaded to backend
class DocumentUploaded extends OnboardingState {
  final String frontImagePath;
  const DocumentUploaded({required this.frontImagePath});

  @override
  List<Object?> get props => [frontImagePath];
}

/// Selfie/face capture uploaded
class FaceCaptureUploaded extends OnboardingState {
  const FaceCaptureUploaded();
}

/// Full verification result returned
class VerificationComplete extends OnboardingState {
  final VerificationResult result;
  const VerificationComplete({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Saved progress restored from storage
class ProgressLoaded extends OnboardingState {
  final OnboardingProgress progress;
  const ProgressLoaded({required this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Any recoverable error
class OnboardingError extends OnboardingState {
  final String message;
  final String? code;

  const OnboardingError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}