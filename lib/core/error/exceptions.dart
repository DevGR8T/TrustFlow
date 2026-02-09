/// Base exception for all API errors
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}

/// Network-related errors (timeouts, no connection, etc.)
class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

/// Validation errors (wrong format, missing fields, etc.)
class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

/// BVN/NIN verification failures
class VerificationException extends ApiException {
  VerificationException(String message) : super(message);
}

/// Document upload/quality failures
class DocumentException extends ApiException {
  DocumentException(String message) : super(message);
}

/// Face capture/liveness failures
class FaceException extends ApiException {
  FaceException(String message) : super(message);
}

/// Server errors (500, etc.)
class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

/// Authentication errors (token expired, unauthorized, etc.)
class AuthenticationException extends ApiException {
  AuthenticationException(String message) : super(message);
}

/// Data parsing errors (malformed JSON, etc.)
class DataParsingException extends ApiException {
  DataParsingException(String message) : super(message);
}