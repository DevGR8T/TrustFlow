import 'package:equatable/equatable.dart';

// ── Failures (domain-facing) ──────────────────────────────────
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

class BvnFailure extends Failure {
  const BvnFailure({required super.message, super.code});
}

class DocumentUploadFailure extends Failure {
  const DocumentUploadFailure({required super.message, super.code});
}

class FaceCaptureFailure extends Failure {
  const FaceCaptureFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to read saved data.',
    super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}