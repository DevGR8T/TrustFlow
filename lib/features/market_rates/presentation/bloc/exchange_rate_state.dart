import '../../domain/entities/exchange_rate.dart';

abstract class ExchangeRateState {}

class ExchangeRateInitial extends ExchangeRateState {}
class ExchangeRateLoading extends ExchangeRateState {}

class ExchangeRateLoaded extends ExchangeRateState {
  final ExchangeRate rate;
  ExchangeRateLoaded(this.rate);
}

class ExchangeRateError extends ExchangeRateState {
  final String message;
  ExchangeRateError(this.message);
}