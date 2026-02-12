import 'package:equatable/equatable.dart';

/// Onboarding Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event: User gave consent
class ConsentGiven extends OnboardingEvent {}

/// NEW: Save consent event for BLoC
class SaveConsentEvent extends OnboardingEvent {}

/// Event: User submitted personal information
class PersonalInfoSubmitted extends OnboardingEvent {
  final String fullName;
  final String dateOfBirth;
  final String phoneNumber;
  final String? email;

  const PersonalInfoSubmitted({
    required this.fullName,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [fullName, dateOfBirth, phoneNumber, email];
}

/// NEW: Save personal info event for BLoC
class SavePersonalInfoEvent extends OnboardingEvent {
  final String fullName;
  final String dateOfBirth;
  final String phoneNumber;
  final String? email;

  const SavePersonalInfoEvent({
    required this.fullName,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [fullName, dateOfBirth, phoneNumber, email];
}

/// Event: User submitted BVN for verification
class BvnSubmitted extends OnboardingEvent {
  final String bvn;

  const BvnSubmitted({required this.bvn});

  @override
  List<Object?> get props => [bvn];
}

/// NEW: Verify BVN event for BLoC
class VerifyBvnEvent extends OnboardingEvent {
  final String bvn;

  const VerifyBvnEvent({required this.bvn});

  @override
  List<Object?> get props => [bvn];
}

/// Event: User captured and submitted document
class DocumentSubmitted extends OnboardingEvent {
  final String imagePath;

  const DocumentSubmitted({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// NEW: Upload document event for BLoC
class UploadDocumentEvent extends OnboardingEvent {
  final String documentType;
  final String frontImagePath;
  final String? backImagePath;

  const UploadDocumentEvent({
    required this.documentType,
    required this.frontImagePath,
    this.backImagePath,
  });

  @override
  List<Object?> get props => [documentType, frontImagePath, backImagePath];
}

/// Event: User captured and submitted face photo
class FaceCaptureSubmitted extends OnboardingEvent {
  final String imagePath;

  const FaceCaptureSubmitted({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// NEW: Upload face capture event for BLoC
class UploadFaceCaptureEvent extends OnboardingEvent {
  final String imagePath;
  final bool livenessVerified;
  final Map<String, dynamic>? livenessData;

  const UploadFaceCaptureEvent({
    required this.imagePath,
    this.livenessVerified = false,
    this.livenessData,
  });

  @override
  List<Object?> get props => [imagePath, livenessVerified, livenessData];
}

/// Event: Check verification status
class VerificationStatusChecked extends OnboardingEvent {}

/// Event: Load saved progress
class LoadSavedProgress extends OnboardingEvent {}

/// NEW: Load saved progress event for BLoC
class LoadSavedProgressEvent extends OnboardingEvent {}

/// Event: Retry failed step
class RetryRequested extends OnboardingEvent {}

/// Event: Clear all data and restart
class OnboardingRestarted extends OnboardingEvent {}

/// NEW: Reset onboarding event for BLoC
class ResetOnboardingEvent extends OnboardingEvent {}