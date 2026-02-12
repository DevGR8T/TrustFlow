import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Centralized theme — import this in main.dart via AppTheme.dark()
abstract class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary:   AppColors.gold,
        secondary: AppColors.info,
        surface:   AppColors.primaryLight,
        error:     AppColors.error,
      ),
      textTheme: _textTheme,
      inputDecorationTheme: _inputTheme,
      elevatedButtonTheme: _buttonTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: GoogleFonts.tiroDevanagariSanskrit(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      dividerColor: AppColors.primaryBorder,
      dividerTheme: const DividerThemeData(
        color: AppColors.primaryBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ── Text theme ───────────────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 40, fontWeight: FontWeight.w800,
      color: AppColors.textPrimary, letterSpacing: -1.2, height: 1.1,
    ),
    displayMedium: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 32, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.15,
    ),
    headlineLarge: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 26, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 22, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, letterSpacing: -0.3,
    ),
    titleLarge: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, letterSpacing: -0.2,
    ),
    titleMedium: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 15, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, letterSpacing: 0,
    ),
    bodyLarge: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 16, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, height: 1.6,
    ),
    bodyMedium: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.textMuted, height: 1.55,
    ),
    bodySmall: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textDisabled, height: 1.5,
    ),
    labelLarge: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 16, fontWeight: FontWeight.w700,
      color: AppColors.primary, letterSpacing: 0.3,
    ),
    labelMedium: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: AppColors.textMuted, letterSpacing: 0.5,
    ),
  );

  // ── Input theme ──────────────────────────────────────────────
  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.primaryLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 15, color: AppColors.textDisabled, fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600,
    ),
    errorStyle: GoogleFonts.tiroDevanagariSanskrit(
      fontSize: 11, color: AppColors.error, height: 1.3,
    ),
    prefixIconColor: AppColors.textDisabled,
    suffixIconColor: AppColors.textDisabled,
  );

  // ── Button theme ─────────────────────────────────────────────
  static ElevatedButtonThemeData get _buttonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      textStyle: GoogleFonts.tiroDevanagariSanskrit(
        fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3,
      ),
    ),
  );
}

/// Spacing scale (4pt grid)
abstract class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
  static const double h   = 56; // touch target / button height
}

/// Border radius tokens
abstract class AppRadius {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double pill = 100;
}