import 'package:flutter/material.dart';

class TradingTheme {
  static const Color background = Color(0xFF0B0E11);
  static const Color surface = Color(0xFF1E2329);
  static const Color surfaceLight = Color(0xFF2B3139);
  static const Color primary = Color(0xFFF0B90B); // Fintech Gold / Amber
  static const Color secondary = Color(0xFF00C087); // Bullish Green
  static const Color bullish = Color(0xFF00C087);
  static const Color bearish = Color(0xFFF6465D);
  static const Color textPrimary = Color(0xFFEAECEF);
  static const Color textSecondary = Color(0xFF848E9C);
  static const Color border = Color(0xFF333A42);
  static const Color accentCyan = Color(0xFF00D2FF);
  static const Color accentPurple = Color(0xFF925FFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: primary,
        secondary: secondary,
        error: bearish,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
        labelSmall: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
