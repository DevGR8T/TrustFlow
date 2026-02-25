import '../../domain/entities/exchange_rate.dart';

class ExchangeRateModel extends ExchangeRate {
  const ExchangeRateModel({
    required super.usdToNgn,
    required super.lastUpdated,
  });

 factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
  return ExchangeRateModel(
    usdToNgn: (json['conversion_rates']['NGN'] as num).toDouble(),
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(
      (json['time_last_update_unix'] as int) * 1000,
    ),
  );
}
}