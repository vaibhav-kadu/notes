import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─── shared ────────────────────────────────────────
  static const _fontFamily = 'Nunito';

  // ─── LIGHT ─────────────────────────────────────────
  static ThemeData get light {
    const primary = AppColors.lightPrimary;
    const bg      = AppColors.lightBackground;
    const surface = AppColors.lightSurface;
    const border  = AppColors.lightBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.light(
        primary:   primary,
        secondary: AppColors.lightSecondaryAccent,
        surface:   surface,
        error:     AppColors.lightError,
        onPrimary: Colors.white,
        onSurface: AppColors.lightPrimaryText,
      ),
      scaffoldBackgroundColor: AppColors.lightSecondaryBackground,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: AppColors.lightPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.lightPrimaryText,
        ),
        iconTheme: IconThemeData(color: AppColors.lightPrimaryText),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: AppColors.lightBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightError),
        ),
        labelStyle: const TextStyle(
          color: AppColors.lightSecondaryText,
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: AppColors.lightDisabledText,
          fontFamily: _fontFamily,
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.lightSecondaryText,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(color: AppColors.lightSecondaryText),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.lightPrimaryText, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: AppColors.lightPrimaryText, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: AppColors.lightPrimaryText, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.lightPrimaryText, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(color: AppColors.lightPrimaryText, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.lightPrimaryText, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.lightSecondaryText, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.lightSecondaryText, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.lightPrimary, fontWeight: FontWeight.w700),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSecondaryBackground,
        selectedColor: primary.withValues(alpha: 0.15),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.lightPrimaryText,
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }

  // ─── DARK ──────────────────────────────────────────
  static ThemeData get dark {
    const primary = AppColors.darkPrimary;
    const bg      = AppColors.darkBackground;
    const surface = AppColors.darkSurface;
    const border  = AppColors.darkBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.dark(
        primary:   primary,
        secondary: AppColors.darkSecondaryAccent,
        surface:   surface,
        error:     AppColors.darkError,
        onPrimary: Colors.white,
        onSurface: AppColors.darkPrimaryText,
      ),
      scaffoldBackgroundColor: bg,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSecondaryBackground,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkPrimaryText,
        ),
        iconTheme: IconThemeData(color: AppColors.darkPrimaryText),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSecondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSecondaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        labelStyle: const TextStyle(color: AppColors.darkSecondaryText, fontFamily: _fontFamily),
        hintStyle: const TextStyle(color: AppColors.darkDisabledText, fontFamily: _fontFamily),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSecondaryBackground,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.darkSecondaryText,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: AppColors.darkSecondaryText),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkPrimaryText, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: AppColors.darkPrimaryText, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: AppColors.darkPrimaryText, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.darkPrimaryText, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(color: AppColors.darkPrimaryText, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.darkPrimaryText, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.darkSecondaryText, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.darkSecondaryText, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.w700),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSecondaryBackground,
        selectedColor: primary.withValues(alpha: 0.2),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.darkPrimaryText,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}