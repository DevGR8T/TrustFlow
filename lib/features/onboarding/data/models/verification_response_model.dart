import '../../domain/entities/verification_result.dart';

class VerificationResponseModel extends VerificationResult {
  const VerificationResponseModel({
    required super.referenceId,
    required super.status,
    super.message,
    super.failureReasons,
    required super.timestamp,
  });

  factory VerificationResponseModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = switch (statusStr.toLowerCase()) {
      'approved'     => VerificationStatus.approved,
      'rejected'     => VerificationStatus.rejected,
      'under_review' => VerificationStatus.underReview,
      _              => VerificationStatus.pending,
    };

    return VerificationResponseModel(
      referenceId:    json['reference_id'] as String,
      status:         status,
      message:        json['message']      as String?,
      failureReasons: (json['failure_reasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      timestamp: DateTime.parse(
          json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'reference_id':    referenceId,
    'status':          status.name,
    'message':         message,
    'failure_reasons': failureReasons,
    'timestamp':       timestamp.toIso8601String(),
  };
}