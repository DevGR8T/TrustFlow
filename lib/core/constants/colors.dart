import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00C853); // Green (trust/fintech)
  static const Color primaryDark = Color(0xFF009624);
  static const Color primaryLight = Color(0xFF5EFC82);

  // Accent Colors
  static const Color accent = Color(0xFF2196F3); // Blue

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}