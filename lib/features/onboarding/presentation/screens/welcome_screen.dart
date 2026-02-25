import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trust_flow/features/market_rates/presentation/widgets/exchange_rate_banner.dart';
import 'package:trust_flow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trust_flow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trust_flow/features/onboarding/presentation/screens/document_capture_screen.dart';
import 'package:trust_flow/features/onboarding/presentation/screens/face_capture_screen.dart';
import 'package:trust_flow/features/onboarding/presentation/screens/personal_info_screen.dart';
import 'package:trust_flow/features/onboarding/presentation/screens/verification_status_screen.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import 'consent_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();

      WidgetsBinding.instance.addPostFrameCallback((_) {
    _resumeFromSavedState();
  });
  }

  void _resumeFromSavedState() {
  final state = context.read<OnboardingBloc>().state;
  print('🔵 Restored state on launch: $state');

  if (state is ConsentSaved) {
    Navigator.push(context, fadeRoute(const PersonalInfoScreen()));
  } else if (state is PersonalInfoSaved) {
    Navigator.push(context, fadeRoute(const PersonalInfoScreen()));
  } else if (state is BvnVerified) {
    Navigator.push(context, fadeRoute(const DocumentCaptureScreen()));
  } else if (state is DocumentUploaded) {
    Navigator.push(context, fadeRoute(const FaceCaptureScreen()));
  } else if (state is FaceCaptureUploaded) {
    Navigator.push(context, fadeRoute(const VerificationStatusScreen()));
  }
}

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      print('🔵 Restored state on launch: ${context.read<OnboardingBloc>().state}'); 
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // ── Geometric background ──────────────────────────────
          Positioned.fill(child: _BackgroundCanvas()),

          // ── Main content ──────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Top bar
                    _buildTopBar(),

                    const Spacer(flex: 2),

                    // Hero mark
                    SlideTransition(
                      position: _logoSlide,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildHeroMark(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Headline
                    SlideTransition(
                      position: _contentSlide,
                      child: _buildHeadline(),
                    ),

                    const Spacer(flex: 3),

                    // Trust pillars
                    SlideTransition(
                      position: _contentSlide,
                      child: _buildTrustPillars(),
                    ),

                    const Spacer(flex: 2),

                    // CTA section
                    SlideTransition(
                      position: _contentSlide,
                      child: _buildCTASection(context),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────────────────────
Widget _buildTopBar() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // App name (left)
      Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF5E27A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.shield_rounded, color: Color(0xFF0A0E1A), size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD4AF37),
              letterSpacing: 3.5,
            ),
          ),
        ],
      ),

      // Right side: rate + secure session stacked vertically
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ExchangeRateBanner(),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1E2D4A), width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D68F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Secure Session',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7A8BAD)),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

  // ─────────────────────────────────────────────────────────────
  // HERO MARK
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroMark() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.18),
                  width: 1,
                ),
              ),
            ),
            // Core
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2540), Color(0xFF0E1628)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 32,
                color: Color(0xFFD4AF37),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADLINE
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.welcomeTitle,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Color(0xFFEFF3FC),
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        // Gold accent underline
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFF5E27A)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.welcomeSubtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF7A8BAD),
            height: 1.65,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TRUST PILLARS
  // ─────────────────────────────────────────────────────────────
  Widget _buildTrustPillars() {
    final pillars = [
      _PillarData(
        Icons.lock_outline_rounded,
        'Bank-Grade Encryption',
        'AES-256 at rest & in transit',
        const Color(0xFF3B82F6),
      ),
      _PillarData(
        Icons.timer_outlined,
        'Under 5 Minutes',
        'Streamlined KYC process',
        const Color(0xFF00D68F),
      ),
      _PillarData(
        Icons.gavel_rounded,
        'Fully Regulated',
        'FCA & PSD2 compliant',
        const Color(0xFFD4AF37),
      ),
    ];

    return Row(
      children: pillars
          .asMap()
          .entries
          .map((e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: e.key < pillars.length - 1 ? 10 : 0,
                  ),
                  child: _buildPillarCard(e.value),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPillarCard(_PillarData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF1E2D4A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFCDD8F0),
              letterSpacing: 0.2,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4A5A7A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CTA SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildCTASection(BuildContext context) {
    return Column(
      children: [
        // Primary button
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const ConsentScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 380),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFF0D060)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.getStartedButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0E1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF0A0E1A),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Legal footnote
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 12,
              color: const Color(0xFF4A5A7A),
            ),
            const SizedBox(width: 5),
            const Text(
              'By continuing, you agree to our ',
              style: TextStyle(fontSize: 11, color: Color(0xFF4A5A7A)),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Terms & Privacy Policy',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD4AF37),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFD4AF37),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BACKGROUND CANVAS
// ─────────────────────────────────────────────────────────────
class _BackgroundCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeometricBackgroundPainter(),
      child: Container(),
    );
  }
}

class _GeometricBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Subtle grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1A2540).withOpacity(0.6)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const cellSize = 52.0;
    for (double x = 0; x < size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Top-right accent arc
    final arcPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width, 0), width: 480, height: 480),
      0.5,
      1.2,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width, 0), width: 320, height: 320),
      0.5,
      1.2,
      false,
      arcPaint..color = const Color(0xFFD4AF37).withOpacity(0.05),
    );

    // Bottom glow blob
    final blobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A3A6A).withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * 0.15, size.height * 0.88),
        width: 320,
        height: 320,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.88), 160, blobPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────
class _PillarData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PillarData(this.icon, this.title, this.subtitle, this.color);
}