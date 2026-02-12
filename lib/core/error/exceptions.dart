// ── Exceptions (data-layer facing) ────────────────────────────
class ServerException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $code, status: $statusCode)';
}

class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}

class BvnException implements Exception {
  final String message;
  final String? code;

  const BvnException({required this.message, this.code});

  @override
  String toString() => 'BvnException: $message';
}

class DocumentException implements Exception {
  final String message;
  const DocumentException({required this.message});

  @override
  String toString() => 'DocumentException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache read/write failed'});

  @override
  String toString() => 'CacheException: $message';
}