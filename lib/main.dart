import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trust_flow/core/security/auth_guard.dart';
import 'package:trust_flow/features/dashboard/presentation/bloc/wallet_bloc.dart';
import 'package:trust_flow/features/market_rates/presentation/bloc/exchange_rate_bloc.dart';
import 'package:trust_flow/features/market_rates/presentation/bloc/exchange_rate_event.dart';
import 'core/constants/theme.dart';
import 'core/di/injection_container.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before any initialization
  await dotenv.load(fileName: '.env');

  // Initialize HydratedBloc storage
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;

  // Initialize all dependencies
  await initDependencies();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TrustFlow());
}

class TrustFlow extends StatelessWidget {
  const TrustFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(create: (_) => sl<OnboardingBloc>()),
        BlocProvider<ExchangeRateBloc>(
          create: (_) => sl<ExchangeRateBloc>()
            ..add(FetchExchangeRate())
            ..add(StartExchangeRatePolling()),
        ),
        BlocProvider<WalletBloc>(create: (_) => sl<WalletBloc>()),
      ],
      child: MaterialApp(
        title: 'TrustFlow KYC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const AuthGuard(child: WelcomeScreen()),
      ),
    );
  }
}
