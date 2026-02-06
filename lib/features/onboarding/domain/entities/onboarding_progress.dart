
/// Tracks which steps the user has completed
enum OnboardingStep {
  welcome,
  consent,
  personalInfo,
  bvnVerification,
  documentCapture,
  faceCapture,
  verification,
  complete,
}

class OnboardingProgress {
  final OnboardingStep currentStep;
  final bool isConsentGiven;
  final bool isPersonalInfoComplete;
  final bool isBvnVerified;
  final bool isDocumentUploaded;
  final bool isFaceCaptured;
  final bool isVerificationComplete;

  const OnboardingProgress({
    required this.currentStep,
    this.isConsentGiven = false,
    this.isPersonalInfoComplete = false,
    this.isBvnVerified = false,
    this.isDocumentUploaded = false,
    this.isFaceCaptured = false,
    this.isVerificationComplete = false,
  });

  /// Initial state
  factory OnboardingProgress.initial() {
    return const OnboardingProgress(
      currentStep: OnboardingStep.welcome,
    );
  }

  /// Create copy with updated fields
  OnboardingProgress copyWith({
    OnboardingStep? currentStep,
    bool? isConsentGiven,
    bool? isPersonalInfoComplete,
    bool? isBvnVerified,
    bool? isDocumentUploaded,
    bool? isFaceCaptured,
    bool? isVerificationComplete,
  }) {
    return OnboardingProgress(
      currentStep: currentStep ?? this.currentStep,
      isConsentGiven: isConsentGiven ?? this.isConsentGiven,
      isPersonalInfoComplete: isPersonalInfoComplete ?? this.isPersonalInfoComplete,
      isBvnVerified: isBvnVerified ?? this.isBvnVerified,
      isDocumentUploaded: isDocumentUploaded ?? this.isDocumentUploaded,
      isFaceCaptured: isFaceCaptured ?? this.isFaceCaptured,
      isVerificationComplete: isVerificationComplete ?? this.isVerificationComplete,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'currentStep': currentStep.index,
      'isConsentGiven': isConsentGiven,
      'isPersonalInfoComplete': isPersonalInfoComplete,
      'isBvnVerified': isBvnVerified,
      'isDocumentUploaded': isDocumentUploaded,
      'isFaceCaptured': isFaceCaptured,
      'isVerificationComplete': isVerificationComplete,
    };
  }

  /// Create from Map
  factory OnboardingProgress.fromMap(Map<String, dynamic> map) {
    return OnboardingProgress(
      currentStep: OnboardingStep.values[map['currentStep'] ?? 0],
      isConsentGiven: map['isConsentGiven'] ?? false,
      isPersonalInfoComplete: map['isPersonalInfoComplete'] ?? false,
      isBvnVerified: map['isBvnVerified'] ?? false,
      isDocumentUploaded: map['isDocumentUploaded'] ?? false,
      isFaceCaptured: map['isFaceCaptured'] ?? false,
      isVerificationComplete: map['isVerificationComplete'] ?? false,
    );
  }

  /// Calculate completion percentage
  double get completionPercentage {
    int completedSteps = 0;
    const totalSteps = 6;

    if (isConsentGiven) completedSteps++;
    if (isPersonalInfoComplete) completedSteps++;
    if (isBvnVerified) completedSteps++;
    if (isDocumentUploaded) completedSteps++;
    if (isFaceCaptured) completedSteps++;
    if (isVerificationComplete) completedSteps++;

    return completedSteps / totalSteps;
  }

  @override
  String toString() {
    return 'OnboardingProgress(step: $currentStep, completion: ${(completionPercentage * 100).toStringAsFixed(0)}%)';
  }
}