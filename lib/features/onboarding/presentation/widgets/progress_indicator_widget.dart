import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';

/// Horizontal step-progress bar for KYC onboarding
/// Shows 5 steps: Consent → Details → BVN → Document → Selfie
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep; // 0-based index
  final int totalSteps;

  const OnboardingProgressBar({
    Key? key,
    required this.currentStep,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step label row
        Row(
          children: List.generate(totalSteps, (i) {
            final done    = i < currentStep;
            final active  = i == currentStep;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                child: Column(
                  children: [
                    // Segment bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      height: 3,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.success
                            : active
                                ? AppColors.gold
                                : AppColors.primaryBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Step label
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: active || done
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: done
                            ? AppColors.success
                            : active
                                ? AppColors.gold
                                : AppColors.textDisabled,
                        letterSpacing: 0.3,
                      ),
                      child: Text(
                        AppStrings.onboardingSteps[i].toUpperCase(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Compact numeric step counter badge  e.g. "Step 3 of 5"
class StepCounterBadge extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepCounterBadge({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 1),
      ),
      child: Text(
        'Step ${currentStep + 1} of $totalSteps',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}