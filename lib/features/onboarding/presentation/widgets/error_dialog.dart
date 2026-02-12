import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'custom_button.dart';

/// Fintech-styled error dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final ErrorDialogType type;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.type = ErrorDialogType.error,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    ErrorDialogType type = ErrorDialogType.error,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => ErrorDialog(
        title: title,
        message: message,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (Color accent, Color dimColor, IconData icon) = switch (type) {
      ErrorDialogType.error   => (AppColors.error,   AppColors.errorDim,   Icons.error_outline_rounded),
      ErrorDialogType.warning => (AppColors.warning, AppColors.warningDim, Icons.warning_amber_rounded),
      ErrorDialogType.info    => (AppColors.info,    AppColors.infoDim,    Icons.info_outline_rounded),
      ErrorDialogType.success => (AppColors.success, AppColors.successDim, Icons.check_circle_outline_rounded),
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.primaryMid,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBorder, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: dimColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 28),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Actions
            if (primaryActionLabel != null)
              PrimaryButton(
                label: primaryActionLabel!,
                onPressed: onPrimaryAction ?? () => Navigator.pop(context),
                trailingIcon: null,
              ),

            if (secondaryActionLabel != null) ...[
              const SizedBox(height: 12),
              SecondaryButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction ?? () => Navigator.pop(context),
              ),
            ],

            if (primaryActionLabel == null && secondaryActionLabel == null) ...[
              SecondaryButton(
                label: 'Dismiss',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum ErrorDialogType { error, warning, info, success }