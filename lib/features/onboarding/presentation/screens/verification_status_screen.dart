import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trust_flow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:trust_flow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trust_flow/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/subtle_grid_background.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/custom_button.dart';
import 'consent_screen.dart' show _SubtleGridBackground;

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({Key? key}) : super(key: key);

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _enterController;
  late AnimationController _pulseController;
  late AnimationController _checkController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _checkAnim;

  _VerificationStatus _status = _VerificationStatus.pending;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));

    _enterController.forward();

    // Trigger the upload once screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentState();
    });
  }

  void _checkCurrentState() {
    final state = context.read<OnboardingBloc>().state;
    if (state is FaceCaptureUploaded) {
      // Already uploaded, show success
      _onSuccess();
    }
    // Otherwise BlocListener will handle it
  }

  void _onSuccess() {
    if (!mounted) return;
    setState(() => _status = _VerificationStatus.success);
    _checkController.forward();
    _pulseController.stop();
  }

  void _onFailure() {
    if (!mounted) return;
    setState(() => _status = _VerificationStatus.failed);
    _pulseController.stop();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is FaceCaptureUploaded) {
          _onSuccess();
        } else if (state is OnboardingError) {
          _onFailure();
        }
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              SubtleGridBackground(),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildTopBar(),
                        const Spacer(flex: 2),
                        _buildStatusMark(),
                        const SizedBox(height: 40),
                        _buildStatusText(),
                        const Spacer(flex: 3),
                        _buildChecklist(),
                        const Spacer(flex: 2),
                        _buildActions(context),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMark() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _checkController]),
      builder: (context, _) {
        final (Color accent, Color dim, IconData icon) = switch (_status) {
          _VerificationStatus.pending => (
            AppColors.gold,
            AppColors.gold.withOpacity(0.12),
            Icons.access_time_rounded,
          ),
          _VerificationStatus.success => (
            AppColors.success,
            AppColors.successDim,
            Icons.verified_rounded,
          ),
          _VerificationStatus.failed => (
            AppColors.error,
            AppColors.errorDim,
            Icons.cancel_outlined,
          ),
        };

        return ScaleTransition(
          scale: _scaleAnim,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse
              if (_status == _VerificationStatus.pending)
                Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withOpacity(0.08),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

              // Mid ring
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.15), width: 1),
                ),
              ),

              // Core
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dim,
                  border: Border.all(color: accent.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.18),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _status == _VerificationStatus.pending
                    ? Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: accent,
                          ),
                        ),
                      )
                    : Icon(icon, color: accent, size: 44),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    final (String title, String body) = switch (_status) {
      _VerificationStatus.pending => (
        AppStrings.statusPendingTitle,
        AppStrings.statusPendingBody,
      ),
      _VerificationStatus.success => (
        AppStrings.statusSuccessTitle,
        AppStrings.statusSuccessBody,
      ),
      _VerificationStatus.failed => (
        AppStrings.statusFailedTitle,
        AppStrings.statusFailedBody,
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Column(
        key: ValueKey(_status),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.9,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    final checks = [
      _CheckItem('Consent & Terms', true),
      _CheckItem('Personal Information', true),
      _CheckItem('BVN Verification', true),
      _CheckItem('Document Upload', true),
      _CheckItem(
        'Biometric Selfie',
        _status != _VerificationStatus.pending,
        inProgress: _status == _VerificationStatus.pending,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder, width: 1),
      ),
      child: Column(
        children: checks.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == checks.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.done
                          ? AppColors.successDim
                          : item.inProgress
                          ? AppColors.gold.withOpacity(0.1)
                          : AppColors.primaryMid,
                      border: Border.all(
                        color: item.done
                            ? AppColors.success.withOpacity(0.5)
                            : item.inProgress
                            ? AppColors.gold.withOpacity(0.4)
                            : AppColors.primaryBorder,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: item.inProgress
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.gold,
                              ),
                            )
                          : Icon(
                              item.done ? Icons.check_rounded : Icons.remove,
                              size: 13,
                              color: item.done
                                  ? AppColors.success
                                  : AppColors.textDisabled,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: item.done
                          ? AppColors.textSecondary
                          : item.inProgress
                          ? AppColors.gold
                          : AppColors.textDisabled,
                    ),
                  ),
                  const Spacer(),
                  if (item.done)
                    const Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (item.inProgress)
                    const Text(
                      'Processing…',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    width: 2,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBorder,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (_status == _VerificationStatus.pending) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        PrimaryButton(
          label: _status == _VerificationStatus.success
              ? AppStrings.statusDone
              : AppStrings.statusRetry,
          onPressed: () {
            if (_status == _VerificationStatus.success) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            } else {
              Navigator.popUntil(context, (r) => r.isFirst);
            }
          },
        ),
        if (_status == _VerificationStatus.failed) ...[
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Contact Support',
            onPressed: () {},
            leadingIcon: Icons.headset_mic_outlined,
          ),
        ],
      ],
    );
  }
}

class _CheckItem {
  final String label;
  final bool done;
  final bool inProgress;

  const _CheckItem(this.label, this.done, {this.inProgress = false});
}

enum _VerificationStatus { pending, success, failed }
