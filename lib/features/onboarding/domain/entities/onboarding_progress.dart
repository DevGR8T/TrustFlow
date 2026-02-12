import 'package:equatable/equatable.dart';

enum OnboardingStep {
  consent,
  personalInfo,
  bvn,
  document,
  face,
  complete,
}

class OnboardingProgress extends Equatable {
  final OnboardingStep currentStep;
  final bool consentGiven;
  final bool personalInfoComplete;
  final bool bvnVerified;
  final bool documentUploaded;
  final bool faceUploaded;

  const OnboardingProgress({
    this.currentStep = OnboardingStep.consent,
    this.consentGiven = false,
    this.personalInfoComplete = false,
    this.bvnVerified = false,
    this.documentUploaded = false,
    this.faceUploaded = false,
  });

  int get stepIndex => currentStep.index;

  // Add fromJson factory
  factory OnboardingProgress.fromJson(Map<String, dynamic> json) {
    return OnboardingProgress(
      currentStep: OnboardingStep.values[json['currentStep'] as int? ?? 0],
      consentGiven: json['consentGiven'] as bool? ?? false,
      personalInfoComplete: json['personalInfoComplete'] as bool? ?? false,
      bvnVerified: json['bvnVerified'] as bool? ?? false,
      documentUploaded: json['documentUploaded'] as bool? ?? false,
      faceUploaded: json['faceUploaded'] as bool? ?? false,
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep.index,
      'consentGiven': consentGiven,
      'personalInfoComplete': personalInfoComplete,
      'bvnVerified': bvnVerified,
      'documentUploaded': documentUploaded,
      'faceUploaded': faceUploaded,
    };
  }

  OnboardingProgress copyWith({
    OnboardingStep? currentStep,
    bool? consentGiven,
    bool? personalInfoComplete,
    bool? bvnVerified,
    bool? documentUploaded,
    bool? faceUploaded,
  }) {
    return OnboardingProgress(
      currentStep:          currentStep          ?? this.currentStep,
      consentGiven:         consentGiven         ?? this.consentGiven,
      personalInfoComplete: personalInfoComplete ?? this.personalInfoComplete,
      bvnVerified:          bvnVerified          ?? this.bvnVerified,
      documentUploaded:     documentUploaded     ?? this.documentUploaded,
      faceUploaded:         faceUploaded         ?? this.faceUploaded,
    );
  }

  @override
  List<Object?> get props => [
    currentStep, consentGiven, personalInfoComplete,
    bvnVerified, documentUploaded, faceUploaded,
  ];
}