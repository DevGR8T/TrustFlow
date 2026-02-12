abstract class AppConstants {
  // ── API ───────────────────────────────────────────────────────
  static const String baseUrl           = 'https://api.veritas-kyc.ng/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // ── BVN ───────────────────────────────────────────────────────
  static const int bvnLength = 11;

  // ── Document upload ───────────────────────────────────────────
  static const int maxImageSizeBytes  = 5 * 1024 * 1024; // 5 MB
  static const int imageQuality       = 85;              // JPEG quality

  // ── Storage keys ─────────────────────────────────────────────
  static const String progressKey     = 'onboarding_progress';
  static const String sessionKey      = 'session_token';

  // ── Onboarding steps ─────────────────────────────────────────
  static const int totalSteps         = 5;
  static const int stepConsent        = 0;
  static const int stepPersonalInfo   = 1;
  static const int stepBvn            = 2;
  static const int stepDocument       = 3;
  static const int stepFace           = 4;
}