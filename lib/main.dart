import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/colors.dart';
import 'features/onboarding/data/repositories/mock_verification_repository.dart';
import 'features/onboarding/data/repositories/verification_repository_impl.dart';
import 'features/onboarding/domain/repositories/verification_repository.dart';
import 'features/onboarding/domain/usecases/verify_bvn.dart';
import 'features/onboarding/domain/usecases/upload_document.dart';
import 'features/onboarding/domain/usecases/upload_face_capture.dart';
import 'features/onboarding/domain/usecases/save_progress.dart';
import 'features/onboarding/domain/usecases/get_saved_progress.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const TrustFlowApp());
}

class TrustFlowApp extends StatelessWidget {
  const TrustFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dependency Injection
    final mockApi = MockVerificationRepository();
    final VerificationRepository repository = VerificationRepositoryImpl(mockApi);
    
    // Use Cases
    final verifyBvn = VerifyBvn(repository);
    final uploadDocument = UploadDocument(repository);
    final uploadFaceCapture = UploadFaceCapture(repository);
    final saveProgress = SaveProgress(repository);
    final getSavedProgress = GetSavedProgress(repository);

    return BlocProvider(
      create: (context) => OnboardingBloc(
        verifyBvnUseCase: verifyBvn,
        uploadDocumentUseCase: uploadDocument,
        uploadFaceCaptureUseCase: uploadFaceCapture,
        saveProgressUseCase: saveProgress,
        getSavedProgressUseCase: getSavedProgress,
        repository: repository,
      ),
      child: MaterialApp(
        title: 'TrustFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'SF Pro Text',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}