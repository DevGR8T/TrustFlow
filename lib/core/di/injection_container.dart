import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:trust_flow/core/security/biometric_service.dart';
import 'package:trust_flow/core/security/pin_service.dart';
import 'package:trust_flow/features/dashboard/data/repositories/wallet_repository_impl.dart';
import 'package:trust_flow/features/dashboard/domain/repositories/wallet_repository.dart';
import 'package:trust_flow/features/dashboard/domain/usecases/deposit_funds.dart';
import 'package:trust_flow/features/dashboard/domain/usecases/get_transactions.dart';
import 'package:trust_flow/features/dashboard/domain/usecases/get_wallet.dart';
import 'package:trust_flow/features/dashboard/presentation/bloc/wallet_bloc.dart';
import 'package:trust_flow/features/market_rates/data/datasources/exchange_rate_remote_datasource.dart';
import 'package:trust_flow/features/market_rates/data/repositories/exchange_rate_repository_impl.dart';
import 'package:trust_flow/features/market_rates/domain/repositories/exchange_rate_repository.dart';
import 'package:trust_flow/features/market_rates/domain/usecases/get_usd_ngn_rate.dart';
import 'package:trust_flow/features/market_rates/presentation/bloc/exchange_rate_bloc.dart';
import 'package:trust_flow/features/onboarding/data/repositories/mock_verification_repository.dart';
import '../constants/app_constants.dart';
import '../../features/onboarding/domain/repositories/verification_repository.dart';
import '../../features/onboarding/domain/usecases/verify_bvn.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.timeoutDuration,
        receiveTimeout: AppConstants.timeoutDuration,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache', 
        },
      ))
        ..interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => print('[DIO] $obj'),
        )));


/// ONBOARDING FEATURE

 // Repository
  sl.registerLazySingleton<VerificationRepository>(
  () => MockVerificationRepository(),
);

 // Usecases
  sl.registerLazySingleton(() => VerifyBvn(sl()));
  sl.registerLazySingleton(() => UploadDocument(sl()));
  sl.registerLazySingleton(() => UploadFaceCapture(sl()));
  sl.registerLazySingleton(() => GetSavedProgress(sl()));
  sl.registerLazySingleton(() => SaveProgress(sl()));

 // Bloc
  sl.registerFactory(() => OnboardingBloc(
        verifyBvn: sl(),
        uploadDocument: sl(),
        uploadFaceCapture: sl(),
        getSavedProgress: sl(),
        saveProgress: sl(),
      ));




 ///EXCHANGE RATE FEATURE
     
    // Datasource
  sl.registerLazySingleton<ExchangeRateRemoteDataSource>(
   () => ExchangeRateRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<ExchangeRateRepository>(
    () => ExchangeRateRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecase
  sl.registerLazySingleton(() => GetUsdNgnRate(sl()));

  // Bloc
 sl.registerFactory(() => ExchangeRateBloc(getUsdNgnRate: sl()));





 /// DASHBOARD FEATURE

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(),
  );

  // Usecases
  sl.registerLazySingleton(() => GetWallet(sl()));
  sl.registerLazySingleton(() => DepositFunds(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));

  // Bloc
  sl.registerFactory(() => WalletBloc(
        getWallet: sl(),
        depositFunds: sl(),
        getTransactions: sl(),
      ));
      


 /// SECURITY
sl.registerLazySingleton(() => const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
));
sl.registerLazySingleton(() => PinService());
sl.registerLazySingleton(() => BiometricService());
}