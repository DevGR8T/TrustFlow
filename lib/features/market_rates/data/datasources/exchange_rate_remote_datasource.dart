import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/error/exceptions.dart';
import '../models/exchange_rate_model.dart';

abstract class ExchangeRateRemoteDataSource {
  Future<ExchangeRateModel> getUsdNgnRate();
}

class ExchangeRateRemoteDataSourceImpl implements ExchangeRateRemoteDataSource {
  final Dio _dio;

    ExchangeRateRemoteDataSourceImpl()
      : _dio = Dio(BaseOptions(
          headers: {'Cache-Control': 'no-cache'},
        ));

 @override
Future<ExchangeRateModel> getUsdNgnRate() async {
  try {
    final apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw const ServerException(message: 'API key not configured.');
    }

    final response = await _dio.get(
      'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD',
    );

    if (response.statusCode == 200 && response.data != null) {
      return ExchangeRateModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw ServerException(
      message: 'Failed to fetch exchange rate.',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      throw const NetworkException();
    }
    throw ServerException(
      message: e.message ?? 'Something went wrong.',
      statusCode: e.response?.statusCode,
    );
  }
}
}