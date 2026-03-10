import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class FaceMatchRepository {
  /// Returns similarity score between 0.0 and 1.0
  Future<Either<Failure, double>> matchFaces({
    required String selfiePath,
    required String idImagePath,
  });
}