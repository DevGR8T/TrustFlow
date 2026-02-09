import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator_widget.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: state is! VerificationPending,
            leading: state is VerificationPending
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: const Text(
              'Verification Status',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress Indicator (only show when not in final state)
                if (state is VerificationPending)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const OnboardingProgressIndicator(
                      currentStep: 5,
                      totalSteps: 5,
                    ),
                  ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // Status Icon
                          _buildStatusIcon(state),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            _getTitle(state),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Message
                          Text(
                            _getMessage(state),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const Spacer(),

                          // Action Buttons
                          if (state is VerificationApproved)
                            CustomButton(
                              text: 'Get Started',
                              icon: Icons.arrow_forward,
                              onPressed: () {
                                // Navigate to main app
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                            ),

                          if (state is VerificationFailed && state.canRetry)
                            Column(
                              children: [
                                CustomButton(
                                  text: AppStrings.retryButton,
                                  icon: Icons.refresh,
                                  onPressed: () {
                                    Navigator.popUntil(
                                      context,
                                      (route) => route.isFirst,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    // Contact support
                                  },
                                  child: const Text('Contact Support'),
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(OnboardingState state) {
    if (state is VerificationPending) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (state is VerificationApproved) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 100,
          color: AppColors.success,
        ),
      );
    }

    if (state is VerificationFailed) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_rounded,
          size: 100,
          color: AppColors.error,
        ),
      );
    }

    return Container();
  }

  String _getTitle(OnboardingState state) {
    if (state is VerificationPending) {
      return AppStrings.verificationPending;
    }
    if (state is VerificationApproved) {
      return AppStrings.verificationApproved;
    }
    if (state is VerificationFailed) {
      return AppStrings.verificationFailed;
    }
    return '';
  }

  String _getMessage(OnboardingState state) {
    if (state is VerificationPending) {
      return AppStrings.verificationPendingMessage;
    }
    if (state is VerificationApproved) {
      return AppStrings.verificationApprovedMessage;
    }
    if (state is VerificationFailed) {
      return state.message;
    }
    return '';
  }
}