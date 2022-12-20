import 'package:flutter/material.dart';

class AppColors {
  // ─── Light Theme ───────────────────────────────────
  static const Color lightBackground          = Color(0xFFFFFFFF);
  static const Color lightSecondaryBackground = Color(0xFFF5F7FA);
  static const Color lightSurface             = Color(0xFFFFFFFF);

  static const Color lightPrimaryText   = Color(0xFF1A1A1A);
  static const Color lightSecondaryText = Color(0xFF555555);
  static const Color lightDisabledText  = Color(0xFF9CA3AF);

  static const Color lightPrimary         = Color(0xFF2563EB);
  static const Color lightPrimaryHover    = Color(0xFF1D4ED8);
  static const Color lightSecondaryAccent = Color(0xFF10B981);

  static const Color lightBorder  = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFD1D5DB);

  // ─── Dark Theme ────────────────────────────────────
  static const Color darkBackground          = Color(0xFF0F172A);
  static const Color darkSecondaryBackground = Color(0xFF1E293B);
  static const Color darkSurface             = Color(0xFF111827);

  static const Color darkPrimaryText   = Color(0xFFF9FAFB);
  static const Color darkSecondaryText = Color(0xFFD1D5DB);
  static const Color darkDisabledText  = Color(0xFF6B7280);

  static const Color darkPrimary         = Color(0xFF3B82F6);
  static const Color darkPrimaryHover    = Color(0xFF60A5FA);
  static const Color darkSecondaryAccent = Color(0xFF34D399);

  static const Color darkBorder  = Color(0xFF374151);
  static const Color darkDivider = Color(0xFF4B5563);

  // ─── Feedback (shared) ─────────────────────────────
  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightError   = Color(0xFFDC2626);
  static const Color lightInfo    = Color(0xFF0EA5E9);

  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkError   = Color(0xFFF87171);
  static const Color darkInfo    = Color(0xFF38BDF8);

  // ─── Gradient helpers ──────────────────────────────
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}