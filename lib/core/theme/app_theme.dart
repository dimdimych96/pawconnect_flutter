import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.obsidianCard,
        primary: AppColors.accentBlue,
        secondary: AppColors.accentGreen,
        error: AppColors.accentRed,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: '.SF Pro Text', // Native iOS font fallback
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.37,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.35,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.38,
        ),
        headlineSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.41,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          letterSpacing: -0.41,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          letterSpacing: -0.24,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.08,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
