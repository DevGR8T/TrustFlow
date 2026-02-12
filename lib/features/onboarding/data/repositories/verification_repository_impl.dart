import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../models/verification_response_model.dart';

/// Production implementation of [VerificationRepository]
/// 
/// Handles all HTTP communication with the backend KYC service.
/// Uses Dio for HTTP requests with proper error handling and timeout configuration.
class VerificationRepositoryImpl implements VerificationRepository {
  final Dio _dio;

  VerificationRepositoryImpl({Dio? dio})
      : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.timeoutDuration,
      receiveTimeout: AppConstants.timeoutDuration,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));

    return dio;
  }

  @override
  Future<Either<Failure, void>> verifyBvn(String bvn) async {
    try {
      final response = await _dio.post(
        '/kyc/verify-bvn',
        data: {'bvn': bvn},
      );

      // Check for successful status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }

      return Left(ServerFailure(
        message: 'Unexpected response from server.',
        code: 'UNEXPECTED_RESPONSE',
      ));
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> uploadDocument({
    required String documentType,
    required String frontImagePath,
    String? backImagePath,
  }) async {
    try {
      // Validate file paths before upload
      final frontFile = await _validateAndCreateMultipartFile(frontImagePath);
      if (frontFile == null) {
        return const Left(DocumentUploadFailure(
          message: 'Front image file not found or invalid.',
          code: 'INVALID_FILE',
        ));
      }

      MultipartFile? backFile;
      if (backImagePath != null) {
        backFile = await _validateAndCreateMultipartFile(backImagePath);
        if (backFile == null) {
          return const Left(DocumentUploadFailure(
            message: 'Back image file not found or invalid.',
            code: 'INVALID_FILE',
          ));
        }
      }

      final formData = FormData.fromMap({
        'document_type': documentType,
        'front': frontFile,
        if (backFile != null) 'back': backFile,
      });

      final response = await _dio.post(
        '/kyc/upload-document',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }

      return Left(DocumentUploadFailure(
        message: 'Document upload failed.',
        code: 'UPLOAD_FAILED',
      ));
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(DocumentUploadFailure(
        message: 'Failed to upload document: ${e.toString()}',
        code: 'UPLOAD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> uploadFaceCapture(
  String imagePath, {
  bool livenessVerified = false,
  Map<String, dynamic>? livenessData,
}) async {
    try {
      final file = await _validateAndCreateMultipartFile(imagePath);
      if (file == null) {
        return const Left(FaceCaptureFailure(
          message: 'Selfie image file not found or invalid.',
          code: 'INVALID_FILE',
        ));
      }

      final formData = FormData.fromMap({
        'selfie': file,
      });

      final response = await _dio.post(
        '/kyc/upload-selfie',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }

      return Left(FaceCaptureFailure(
        message: 'Face capture upload failed.',
        code: 'UPLOAD_FAILED',
      ));
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(FaceCaptureFailure(
        message: 'Failed to upload selfie: ${e.toString()}',
        code: 'UPLOAD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, VerificationResult>> getVerificationStatus() async {
    try {
      final response = await _dio.get('/kyc/status');

      if (response.statusCode == 200 && response.data != null) {
        final result = VerificationResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(result);
      }

      return Left(ServerFailure(
        message: 'Failed to fetch verification status.',
        code: 'STATUS_FETCH_FAILED',
      ));
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to get verification status: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgress(
    Map<String, dynamic> progress,
  ) async {
    try {
      // TODO: Implement local persistence using SharedPreferences or Hive
      // For now, this is a placeholder
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to save progress: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSavedProgress() async {
    try {
      // TODO: Implement local persistence retrieval
      // For now, return empty map
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right({});
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to retrieve saved progress: ${e.toString()}',
      ));
    }
  }

  /// Validates file existence and creates MultipartFile
  Future<MultipartFile?> _validateAndCreateMultipartFile(
    String filePath,
  ) async {
    try {
      return await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      );
    } catch (e) {
      return null;
    }
  }

  /// Maps Dio exceptions to domain-specific failures
  Failure _mapDioException(DioException exception) {
    // Network errors
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure(
        message: 'Connection timeout. Please check your internet connection.',
      );
    }

    if (exception.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        message: 'No internet connection. Please try again.',
      );
    }

    // Server response errors
    final response = exception.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;
      final message = data is Map<String, dynamic>
          ? (data['message'] as String?)
          : null;
      final code = data is Map<String, dynamic>
          ? (data['code'] as String?)
          : null;

      // Handle specific error codes
      switch (statusCode) {
        case 400:
          return ServerFailure(
            message: message ?? 'Invalid request.',
            code: code ?? 'BAD_REQUEST',
          );
        case 401:
          return ServerFailure(
            message: message ?? 'Unauthorized access.',
            code: code ?? 'UNAUTHORIZED',
          );
        case 404:
          return ServerFailure(
            message: message ?? 'Resource not found.',
            code: code ?? 'NOT_FOUND',
          );
        case 422:
          // Handle specific BVN errors
          if (code == 'BVN_NOT_FOUND' || code == 'BVN_MISMATCH') {
            return BvnFailure(
              message: message ?? 'BVN verification failed.',
              code: code,
            );
          }
          return ServerFailure(
            message: message ?? 'Validation error.',
            code: code ?? 'VALIDATION_ERROR',
          );
        case 500:
        case 502:
        case 503:
          return ServerFailure(
            message: message ?? 'Server error. Please try again later.',
            code: code ?? 'SERVER_ERROR',
          );
        default:
          return ServerFailure(
            message: message ?? 'An error occurred. Please try again.',
            code: code ?? 'UNKNOWN_ERROR',
          );
      }
    }

    // Unknown error
    return UnknownFailure(
      message: 'An unexpected error occurred: ${exception.message}',
    );
  }
}