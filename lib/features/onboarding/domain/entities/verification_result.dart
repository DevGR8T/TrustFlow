import 'package:equatable/equatable.dart';

enum VerificationStatus { pending, approved, rejected, underReview }

class VerificationResult extends Equatable {
  final String referenceId;
  final VerificationStatus status;
  final String? message;
  final List<String> failureReasons;
  final DateTime timestamp;

  const VerificationResult({
    required this.referenceId,
    required this.status,
    this.message,
    this.failureReasons = const [],
    required this.timestamp,
  });

  bool get isApproved  => status == VerificationStatus.approved;
  bool get isRejected  => status == VerificationStatus.rejected;
  bool get isPending   => status == VerificationStatus.pending;

  @override
  List<Object?> get props =>
      [referenceId, status, message, failureReasons, timestamp];
}