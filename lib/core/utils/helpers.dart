import 'package:flutter/material.dart';
import '../constants/colors.dart';

abstract class AppHelpers {
  /// Format BVN with spaces for display: 000 000 00000
  static String formatBvn(String bvn) {
    if (bvn.length != 11) return bvn;
    return '${bvn.substring(0, 3)} ${bvn.substring(3, 6)} ${bvn.substring(6)}';
  }

  /// Mask BVN for display: ***-***-12345
  static String maskBvn(String bvn) {
    if (bvn.length < 6) return bvn;
    return '***-***-${bvn.substring(6)}';
  }

  /// Format Nigerian phone for display
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }
    return phone;
  }

  /// Returns a human-readable file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Show a lightweight snack notification
  static void showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: duration,
        elevation: 4,
      ),
    );
  }
}