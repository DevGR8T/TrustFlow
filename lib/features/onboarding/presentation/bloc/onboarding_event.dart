import 'package:equatable/equatable.dart';

/// Onboarding Events
/// Represents all user actions in the onboarding flow
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event: User gave consent
class ConsentGiven extends OnboardingEvent {}

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

/// Event: User submitted BVN for verification
class BvnSubmitted extends OnboardingEvent {
  final String bvn;

  const BvnSubmitted({required this.bvn});

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

/// Event: User captured and submitted face photo
class FaceCaptureSubmitted extends OnboardingEvent {
  final String imagePath;

  const FaceCaptureSubmitted({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Event: Check verification status
class VerificationStatusChecked extends OnboardingEvent {}

/// Event: Load saved progress
class LoadSavedProgress extends OnboardingEvent {}

/// Event: Retry failed step
class RetryRequested extends OnboardingEvent {}

/// Event: Clear all data and restart
class OnboardingRestarted extends OnboardingEvent {}