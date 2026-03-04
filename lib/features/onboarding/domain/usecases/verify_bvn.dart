import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/verification_repository.dart';

// ── Base use case contract ────────────────────────────────────
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}

// ── Verify BVN ───────────────────────────────────────────────
class VerifyBvn implements UseCase<void, VerifyBvnParams> {
  final VerificationRepository repository;
  const VerifyBvn(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyBvnParams params) {
    return repository.verifyBvn(params.bvn);
  }
}

class VerifyBvnParams extends Equatable {
  final String bvn;
  const VerifyBvnParams({required this.bvn});

  @override
  List<Object?> get props => [bvn];
}

// ── Upload Document ──────────────────────────────────────────
class UploadDocument implements UseCase<void, UploadDocumentParams> {
  final VerificationRepository repository;
  const UploadDocument(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadDocumentParams params) {
    return repository.uploadDocument(
      documentType:   params.documentType,
      frontImagePath: params.frontImagePath,
      backImagePath:  params.backImagePath,
    );
  }
}

class UploadDocumentParams extends Equatable {
  final String documentType;
  final String frontImagePath;
  final String? backImagePath;

  const UploadDocumentParams({
    required this.documentType,
    required this.frontImagePath,
    this.backImagePath,
  });

  @override
  List<Object?> get props => [documentType, frontImagePath, backImagePath];
}

// ── Upload Face Capture ──────────────────────────────────────
class UploadFaceCapture implements UseCase<void, UploadFaceCaptureParams> {
  final VerificationRepository repository;
  const UploadFaceCapture(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadFaceCaptureParams params) {
   
    
    return repository.uploadFaceCapture(
      params.imagePath,
      livenessVerified: params.livenessVerified,
      livenessData: params.livenessData,
    );
  }
}

class UploadFaceCaptureParams extends Equatable {
  final String imagePath;
  final bool livenessVerified;
  final Map<String, dynamic>? livenessData;

  const UploadFaceCaptureParams({
    required this.imagePath,
    this.livenessVerified = false,
    this.livenessData,
  });

  @override
  List<Object?> get props => [imagePath, livenessVerified, livenessData];
}

// ── Save Progress ────────────────────────────────────────────
class SaveProgress implements UseCase<void, SaveProgressParams> {
  final VerificationRepository repository;
  const SaveProgress(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveProgressParams params) {
    return repository.saveProgress(params.data);
  }
}

class SaveProgressParams extends Equatable {
  final Map<String, dynamic> data;
  const SaveProgressParams({required this.data});

  @override
  List<Object?> get props => [data];
}

// ── Get Saved Progress ───────────────────────────────────────
class GetSavedProgress implements UseCase<Map<String, dynamic>, NoParams> {
  final VerificationRepository repository;
  const GetSavedProgress(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return repository.getSavedProgress();
  }
}