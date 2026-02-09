import 'package:equatable/equatable.dart';
import '../../domain/entities/user_data.dart';
import '../../domain/entities/onboarding_progress.dart';

/// Onboarding States
/// Represents all possible states in the onboarding flow
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OnboardingInitial extends OnboardingState {}

/// Loading saved progress
class LoadingSavedProgress extends OnboardingState {}

/// Saved progress loaded
class SavedProgressLoaded extends OnboardingState {
  final OnboardingProgress progress;
  final UserData userData;

  const SavedProgressLoaded({
    required this.progress,
    required this.userData,
  });

  @override
  List<Object?> get props => [progress, userData];
}

/// No saved progress found
class NoSavedProgress extends OnboardingState {}

// ============================================================================
// CONSENT STATES
// ============================================================================

class ConsentAccepted extends OnboardingState {}

// ============================================================================
// PERSONAL INFO STATES
// ============================================================================

class PersonalInfoSaving extends OnboardingState {}

class PersonalInfoSaved extends OnboardingState {
  final UserData userData;

  const PersonalInfoSaved({required this.userData});

  @override
  List<Object?> get props => [userData];
}

// ============================================================================
// BVN VERIFICATION STATES
// ============================================================================

class BvnVerificationLoading extends OnboardingState {}

class BvnVerificationSuccess extends OnboardingState {
  final Map<String, dynamic> verifiedData;

  const BvnVerificationSuccess({required this.verifiedData});

  @override
  List<Object?> get props => [verifiedData];
}

class BvnVerificationError extends OnboardingState {
  final String message;

  const BvnVerificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// DOCUMENT UPLOAD STATES
// ============================================================================

class DocumentUploading extends OnboardingState {}

class DocumentUploadSuccess extends OnboardingState {
  final String documentId;

  const DocumentUploadSuccess({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}

class DocumentUploadError extends OnboardingState {
  final String message;

  const DocumentUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// FACE CAPTURE STATES
// ============================================================================

class FaceUploading extends OnboardingState {}

class FaceUploadSuccess extends OnboardingState {
  final String faceId;

  const FaceUploadSuccess({required this.faceId});

  @override
  List<Object?> get props => [faceId];
}

class FaceUploadError extends OnboardingState {
  final String message;

  const FaceUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// VERIFICATION STATUS STATES
// ============================================================================

class VerificationPending extends OnboardingState {}

class VerificationApproved extends OnboardingState {
  final Map<String, dynamic>? userData;

  const VerificationApproved({this.userData});

  @override
  List<Object?> get props => [userData];
}

class VerificationFailed extends OnboardingState {
  final String message;
  final bool canRetry;

  const VerificationFailed({
    required this.message,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

// ============================================================================
// ERROR STATES
// ============================================================================

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}