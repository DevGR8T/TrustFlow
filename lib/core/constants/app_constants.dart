/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'TrustFlow';
  static const String appVersion = '1.0.0';

  // Onboarding Steps
  static const int totalOnboardingSteps = 5;

  // Validation
  static const int bvnLength = 11;
  static const int ninLength = 11;
  static const int minNameLength = 3;
  static const int maxNameLength = 100;

  // File Upload
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // Retry
  static const int maxRetryAttempts = 3;

  // Storage Keys
  static const String progressKey = 'onboarding_progress';
  static const String userDataKey = 'user_data';
}