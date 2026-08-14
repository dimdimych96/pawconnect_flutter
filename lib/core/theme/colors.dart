import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Obsidian Backgrounds (Matching Option 5 Organic Glass)
  static const Color obsidianBackground = Color(0xFF0B0F12);
  static const Color obsidianCard = Color(0xFF141A16);
  static const Color obsidianCardTranslucent = Color(0xC8121814); // rgba(18, 24, 20, 0.78)
  static const Color obsidianGlassSurface = Color(0x60121814);

  // Glass Borders
  static const Color glassBorder = Color(0x1AFFFFFF); // ~10% White
  static const Color glassBorderSubtle = Color(0x12FFFFFF); // ~7% White
  static const Color glassHighlight = Color(0x3034D399); // Emerald highlight sheen

  // Status & Category Accents (Harmonized with Option 5 Emerald Theme)
  static const Color accentGreen = Color(0xFF34D399); // Emerald active accent (#34D399)
  static const Color accentGreenDark = Color(0xFF059669); // Deep emerald (#059669)
  static const Color accentRed = Color(0xFFF87171);   // Alert / Lost Pets / SOS
  static const Color accentBlue = Color(0xFF60A5FA);  // Information / Companions
  static const Color accentYellow = Color(0xFFFBBF24);// Warning / Reminders

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x9994A3B8); // Slate-400 iOS/Fluid style (#94A3B8)
  static const Color textTertiary = Color(0x4D94A3B8);  // Slate-400 30% style

  // Overlay Gradients
  static const LinearGradient activeEmeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4034D399), // rgba(16, 185, 129, 0.25)
      Color(0x26059669), // rgba(5, 150, 105, 0.15)
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x2034D399),
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
      Color(0xFF141A16),
      Color(0xFF0B0F12),
    ],
  );
}
