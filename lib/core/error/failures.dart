import 'package:equatable/equatable.dart';

/// Base Failure class
/// Represents failures in the domain layer
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Cache Failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Verification Failure (BVN/NIN/Document/Face)
class VerificationFailure extends Failure {
  const VerificationFailure(String message) : super(message);
}

/// Authentication Failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

/// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}