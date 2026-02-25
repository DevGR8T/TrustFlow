import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_usd_ngn_rate.dart';
import 'exchange_rate_event.dart';
import 'exchange_rate_state.dart';

class ExchangeRateBloc extends Bloc<ExchangeRateEvent, ExchangeRateState> {
  final GetUsdNgnRate getUsdNgnRate;
  Timer? _timer;

  ExchangeRateBloc({required this.getUsdNgnRate}) : super(ExchangeRateInitial()) {
    on<FetchExchangeRate>((event, emit) async {
      // Only show loading on first fetch
      if (state is ExchangeRateInitial) emit(ExchangeRateLoading());

      final result = await getUsdNgnRate();
      result.fold(
        (failure) => emit(ExchangeRateError(failure.message)),
        (rate) => emit(ExchangeRateLoaded(rate)),
      );
    });

    on<StartExchangeRatePolling>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        add(FetchExchangeRate());
      });
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}