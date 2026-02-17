import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/constants/theme.dart';
import 'features/onboarding/data/repositories/mock_verification_repository.dart';
import 'features/onboarding/domain/usecases/verify_bvn.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';
  
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc storage
  final storage = await HydratedStorage.build(
  storageDirectory: await getApplicationDocumentsDirectory(),
);
  HydratedBloc.storage = storage;

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