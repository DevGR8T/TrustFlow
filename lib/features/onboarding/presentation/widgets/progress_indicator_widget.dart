import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    Key? key,
    required this.currentStep,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : AppColors.divider,
              ),
            );
          }),
        ),
      ],
    );
  }
}