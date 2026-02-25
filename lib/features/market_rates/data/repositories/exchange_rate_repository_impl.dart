import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/exchange_rate_remote_datasource.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateRemoteDataSource remoteDataSource;

  ExchangeRateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExchangeRate>> getUsdNgnRate() async {
    try {
      final result = await remoteDataSource.getUsdNgnRate();
      return Right(result);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ExchangeRateFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}