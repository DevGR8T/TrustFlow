import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exchange_rate.dart';

abstract class ExchangeRateRepository {
  Future<Either<Failure, ExchangeRate>> getUsdNgnRate();
}