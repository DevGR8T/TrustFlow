/// Verification Result Entity
/// Represents the result of any verification step (BVN, Document, Face)
class VerificationResult {
  final bool isSuccessful;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const VerificationResult({
    required this.isSuccessful,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory VerificationResult.success({
    required String message,
    Map<String, dynamic>? data,
  }) {
    return VerificationResult(
      isSuccessful: true,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  factory VerificationResult.failure({
    required String message,
    Map<String, dynamic>? data,
  }) {
    return VerificationResult(
      isSuccessful: false,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'VerificationResult(success: $isSuccessful, message: $message)';
  }
}