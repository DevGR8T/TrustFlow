import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/face_match_repository.dart';

class MatchFacesParams {
  final String selfiePath;
  final String idImagePath;
  const MatchFacesParams({
    required this.selfiePath,
    required this.idImagePath,
  });
}

class MatchFaces {
  final FaceMatchRepository repository;
  MatchFaces(this.repository);

  Future<Either<Failure, double>> call(MatchFacesParams params) =>
      repository.matchFaces(
        selfiePath: params.selfiePath,
        idImagePath: params.idImagePath,
      );
}