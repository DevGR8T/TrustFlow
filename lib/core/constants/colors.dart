import 'package:flutter/material.dart';

/// TrustFlow KYC — Design Token Palette
/// Dark institutional fintech: deep navy base, gold accent, semantic signals
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  static const Color primary       = Color(0xFF0A0E1A); // canvas
  static const Color primaryLight  = Color(0xFF0E1628); // surface
  static const Color primaryMid    = Color(0xFF131D33); // card
  static const Color primaryBorder = Color(0xFF1E2D4A); // divider

  // ── Gold accent ─────────────────────────────────────────────
  static const Color gold          = Color(0xFFD4AF37);
  static const Color goldLight     = Color(0xFFF5E27A);
  static const Color goldDim       = Color(0xFF8A6E1A);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFEFF3FC);
  static const Color textSecondary = Color(0xFFCDD8F0);
  static const Color textMuted     = Color(0xFF7A8BAD);
  static const Color textDisabled  = Color(0xFF4A5A7A);

  // ── Semantic ────────────────────────────────────────────────
  static const Color success       = Color(0xFF00D68F);
  static const Color successDim    = Color(0xFF003D26);
  static const Color error         = Color(0xFFFF4D6A);
  static const Color errorDim      = Color(0xFF3D0012);
  static const Color warning       = Color(0xFFFFB020);
  static const Color warningDim    = Color(0xFF3D2800);
  static const Color info          = Color(0xFF3B82F6);
  static const Color infoDim       = Color(0xFF0B1E3D);

  // ── Step colors (for progress) ──────────────────────────────
  static const Color stepActive    = gold;
  static const Color stepDone      = success;
  static const Color stepInactive  = primaryBorder;
}