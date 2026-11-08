import 'package:flutter/material.dart';

abstract class AppColors {
  // Graphite Neutral Ramp (Unslop Dark System + Apple Obsidian)
  static const Color obsidianBackground = Color(0xFF0F0F10);
  static const Color obsidianCard = Color(0xFF19191B);
  static const Color obsidianCardTranslucent = Color(0xDF19191B);
  static const Color obsidianGlassSurface = Color(0xFF232325);
  static const Color obsidianRaised = Color(0xFF232325);

  // Quiet Hairline Borders (6-10% Primary Text)
  static const Color glassBorder = Color(0x14EDEDED); // 8% hairline
  static const Color glassBorderSubtle = Color(0x0FEDEDED); // 6% subtle hairline
  static const Color glassHighlight = Color(0x1F4CC38A);

  // Toned Semantic & Functional Accents
  static const Color accentGreen = Color(0xFF4CC38A); // Toned positive / live telemetry
  static const Color accentGreenDark = Color(0xFF16A34A);
  static const Color accentRed = Color(0xFFE5484D);   // Toned alert / SOS
  static const Color accentBlue = Color(0xFF3B82F6);  // Route / navigation
  static const Color accentYellow = Color(0xFFF59E0B);// Warning / hazard

  // Three Strict Text Roles (WCAG AA Verified on #0F0F10 / #19191B)
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFA1A1A6);
  static const Color textTertiary = Color(0xFF85858B);

  // Subtle Neutral Gradients (No multi-hue neon washes)
  static const LinearGradient activeEmeraldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF262629),
      Color(0xFF1F1F22),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x14FFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  static const LinearGradient glassSpecular = LinearGradient(
    colors: [
      Colors.transparent,
      Colors.transparent,
    ],
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF141415),
      Color(0xFF0F0F10),
    ],
  );
}
