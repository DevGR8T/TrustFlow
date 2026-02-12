import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/theme.dart';
import 'features/onboarding/data/repositories/mock_verification_repository.dart';
import 'features/onboarding/domain/usecases/verify_bvn.dart';
import 'features/onboarding/domain/usecases/upload_document.dart';
import 'features/onboarding/domain/usecases/upload_face_capture.dart';
import 'features/onboarding/domain/usecases/save_progress.dart';
import 'features/onboarding/domain/usecases/get_saved_progress.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    systemNavigationBarColor:  Color(0xFF0A0E1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const TrustFlow());
}

class TrustFlow extends StatelessWidget {
  const TrustFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ── Dependency wiring (replace with get_it / injectable in production) ──
    final repo = MockVerificationRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (_) => OnboardingBloc(
            verifyBvn:         VerifyBvn(repo),
            uploadDocument:    UploadDocument(repo),
            uploadFaceCapture: UploadFaceCapture(repo),
            saveProgress:      SaveProgress(repo),
            getSavedProgress:  GetSavedProgress(repo),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'TrustFlow KYC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const WelcomeScreen(),
      ),
    );
  }
}