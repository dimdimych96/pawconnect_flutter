import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Obsidian Backgrounds
  static const Color obsidianBackground = Color(0xFF0A0A0C);
  static const Color obsidianCard = Color(0xFF1C1C1E);
  static const Color obsidianCardTranslucent = Color(0xDC121216);
  static const Color obsidianGlassSurface = Color(0x301C1C1E);

  // Glass Borders
  static const Color glassBorder = Color(0x1FFFFFFF); // ~12% White
  static const Color glassBorderSubtle = Color(0x14FFFFFF); // ~8% White
  static const Color glassHighlight = Color(0x28FFFFFF); // Specular sheen

  // Status & Category Accents
  static const Color accentGreen = Color(0xFF30D158); // Safety / Playgrounds / Success
  static const Color accentRed = Color(0xFFFF453A);   // Alert / Lost Pets / SOS
  static const Color accentBlue = Color(0xFF0A84FF);  // Information / Companions
  static const Color accentYellow = Color(0xFFFFD60A);// Warning / Offline

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99EBEBF5); // 60% white iOS style
  static const Color textTertiary = Color(0x4DEBEBF5);  // 30% white iOS style

  // Overlay Gradients
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x28FFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF141419),
      Color(0xFF0A0A0C),
    ],
  );
}
