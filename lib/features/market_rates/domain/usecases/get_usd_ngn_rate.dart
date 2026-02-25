import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exchange_rate.dart';
import '../repositories/exchange_rate_repository.dart';

class GetUsdNgnRate {
  final ExchangeRateRepository repository;

  GetUsdNgnRate(this.repository);

  Future<Either<Failure, ExchangeRate>> call() => repository.getUsdNgnRate();
}