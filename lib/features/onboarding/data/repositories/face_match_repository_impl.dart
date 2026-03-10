import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/ml/face_match_service.dart';
import '../../domain/repositories/face_match_repository.dart';

class FaceMatchRepositoryImpl implements FaceMatchRepository {
  final FaceMatchService faceMatchService;

  FaceMatchRepositoryImpl({required this.faceMatchService});

  @override
  Future<Either<Failure, double>> matchFaces({
    required String selfiePath,
    required String idImagePath,
  }) async {
    try {
      final selfieEmbedding = await faceMatchService.extractEmbedding(
        selfiePath,
        isSelfie: true,
      );
      if (selfieEmbedding == null) {
        return Left(
          VerificationFailure(message: 'No face detected in selfie.'),
        );
      }

      final idEmbedding = await faceMatchService.extractEmbedding(idImagePath);
      if (idEmbedding == null) {
        return Left(
          VerificationFailure(message: 'No face detected in ID document.'),
        );
      }

      final similarity = faceMatchService.cosineSimilarity(
        selfieEmbedding,
        idEmbedding,
      );

      return Right(similarity);
    } catch (e) {
      return Left(
        VerificationFailure(message: 'Face matching failed: ${e.toString()}'),
      );
    }
  }
}
