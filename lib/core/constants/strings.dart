/// App Strings
class AppStrings {
  // Welcome Screen
  static const String welcomeTitle = 'Welcome to TrustFlow';
  static const String welcomeSubtitle =
      'Complete your verification to get started';
  static const String getStartedButton = 'Get Started';

  // Consent Screen
  static const String consentTitle = 'Your Data & Privacy';
  static const String consentMessage =
      'We collect your personal information to verify your identity, '
      'comply with regulatory requirements, and protect against fraud.';
  static const String consentCheckbox =
      'I agree to the terms and consent to data processing';

  // Personal Info Screen
  static const String personalInfoTitle = 'Personal Information';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'As shown on your ID';
  static const String dateOfBirthLabel = 'Date of Birth';
  static const String phoneLabel = 'Phone Number';
  static const String emailLabel = 'Email (Optional)';

  // BVN Screen
  static const String bvnTitle = 'BVN Verification';
  static const String bvnLabel = 'Bank Verification Number';
  static const String bvnHint = 'Enter 11-digit BVN';
  static const String bvnInfo =
      'Your BVN helps us confirm your identity is real and matches your provided information.';

  // Document Screen
  static const String documentTitle = 'Upload ID Document';
  static const String documentTips = 'Tips for a clear photo:\n'
      '• Ensure good lighting\n'
      '• Place ID on flat surface\n'
      '• Avoid glare and shadows\n'
      '• All text must be readable';

  // Face Capture Screen
  static const String faceTitle = 'Face Verification';
  static const String faceInstructions = 'Instructions:\n'
      '• Remove glasses/hat\n'
      '• Face camera directly\n'
      '• Ensure good lighting\n'
      '• Keep still';

  // Verification Status
  static const String verificationPending = 'Verifying Your Information';
  static const String verificationPendingMessage =
      'This usually takes a few moments. Please wait...';
  static const String verificationApproved = 'Verification Complete!';
  static const String verificationApprovedMessage =
      'Your account has been successfully verified.';
  static const String verificationFailed = 'Verification Failed';

  // Buttons
  static const String continueButton = 'Continue';
  static const String retryButton = 'Try Again';
  static const String captureButton = 'Capture';
  static const String retakeButton = 'Retake';
  static const String submitButton = 'Submit';
  static const String cancelButton = 'Cancel';

  // Errors
  static const String genericError = 'An unexpected error occurred';
  static const String networkError = 'Network error. Please check your connection.';
  static const String validationError = 'Please check your input and try again';
}