abstract class AppStrings {
  // ── App ──────────────────────────────────────────────────────
  static const String appName         = 'TrustFlow';
  static const String appTagline      = 'Identity Verification';

  // ── Welcome ──────────────────────────────────────────────────
  static const String welcomeTitle    = 'Verify Your\nIdentity';
  static const String welcomeSubtitle =
      'Complete your KYC in under 5 minutes to\nunlock full account access.';
  static const String getStartedButton = 'Get Started';

  // ── Consent ──────────────────────────────────────────────────
  static const String consentTitle    = 'Data Consent';
  static const String consentSubtitle =
      'We collect and process the following data to verify your identity in compliance with CBN regulations.';
  static const String consentAgree    = 'I Agree & Continue';
  static const String consentDecline  = 'Decline';

  // ── Personal Info ────────────────────────────────────────────
  static const String personalInfoTitle    = 'Personal Details';
  static const String personalInfoSubtitle = 'Enter your details exactly as they appear on your government ID.';
  static const String firstNameLabel       = 'First Name';
  static const String lastNameLabel        = 'Last Name';
  static const String dobLabel             = 'Date of Birth';
  static const String phoneLabel           = 'Phone Number';
  static const String emailLabel           = 'Email Address';
  static const String continueButton       = 'Continue';

  // ── BVN ──────────────────────────────────────────────────────
  static const String bvnTitle    = 'BVN Verification';
  static const String bvnSubtitle =
      'Enter your 11-digit Bank Verification Number. Your BVN is used solely for identity verification.';
  static const String bvnLabel     = 'Bank Verification Number';
  static const String bvnHint      = '00000000000';
  static const String bvnVerify    = 'Verify BVN';
  static const String bvnWhatsThis = 'What is a BVN?';

  // ── Document ─────────────────────────────────────────────────
  static const String documentTitle    = 'Upload Document';
  static const String documentSubtitle = 'Choose a valid government-issued photo ID.';
  static const String documentFront    = 'Front of Document';
  static const String documentBack     = 'Back of Document';
  static const String documentCapture  = 'Capture Document';
  static const String documentRetake   = 'Retake Photo';
  static const String documentConfirm  = 'Confirm & Continue';

  // ── Document types ───────────────────────────────────────────
  static const String docNIN       = 'National ID (NIN)';
  static const String docPassport  = 'International Passport';
  static const String docDrivers   = "Driver's Licence";
  static const String docVoters    = "Voter's Card";

  // ── Face capture ─────────────────────────────────────────────
  static const String faceTitle       = 'Face Verification';
  static const String faceSubtitle    = 'Position your face within the frame and ensure good lighting.';
  static const String faceTakePhoto   = 'Take Selfie';
  static const String faceRetake      = 'Retake';
  static const String faceConfirm     = 'Use This Photo';

  // ── Verification status ──────────────────────────────────────
  static const String statusPendingTitle   = 'Verification\nIn Progress';
  static const String statusPendingBody    = 'We\'re reviewing your documents. This usually takes 2–5 minutes.';
  static const String statusSuccessTitle   = 'Identity\nVerified';
  static const String statusSuccessBody    = 'Your identity has been successfully verified. You can now access all features.';
  static const String statusFailedTitle    = 'Verification\nFailed';
  static const String statusFailedBody     = 'We couldn\'t verify your identity. Please review the issues below and try again.';
  static const String statusRetry         = 'Try Again';
  static const String statusDone          = 'Go to Dashboard';

  // ── Errors ───────────────────────────────────────────────────
  static const String errorGeneric        = 'Something went wrong. Please try again.';
  static const String errorNetwork        = 'No internet connection. Check your network and retry.';
  static const String errorBvnInvalid     = 'Invalid BVN. Please check and try again.';
  static const String errorBvnNotFound    = 'BVN not found. Ensure you entered the correct number.';
  static const String errorUploadFailed   = 'Upload failed. Please try again.';
  static const String errorCameraPermission = 'Camera access is required to capture documents.';
  static const String errorTimeout        = 'Request timed out. Please try again.';

  // ── Progress steps ───────────────────────────────────────────
  static const List<String> onboardingSteps = [
    'Consent',
    'Details',
    'BVN',
    'Document',
    'Selfie',
  ];
}