import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
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
        },
      ))
        ..interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => print('[DIO] $obj'),
        )));

  sl.registerLazySingleton<VerificationRepository>(
  () => MockVerificationRepository(),
);

  sl.registerLazySingleton(() => VerifyBvn(sl()));
  sl.registerLazySingleton(() => UploadDocument(sl()));
  sl.registerLazySingleton(() => UploadFaceCapture(sl()));
  sl.registerLazySingleton(() => GetSavedProgress(sl()));
  sl.registerLazySingleton(() => SaveProgress(sl()));

  sl.registerFactory(() => OnboardingBloc(
        verifyBvn: sl(),
        uploadDocument: sl(),
        uploadFaceCapture: sl(),
        getSavedProgress: sl(),
        saveProgress: sl(),
      ));
}