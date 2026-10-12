import 'package:flutter/material.dart';

/// JuwishPro Binance-Grade High-Contrast Design System
class AppTheme {
  // Brand Obsidian & Dark Backgrounds
  static const Color nightObsidian = Color(0xFF0B0E11); // Main deep background
  static const Color surfaceCharcoal = Color(0xFF181A20); // Cards & Nav
  static const Color cardElevated = Color(0xFF1E2329); // Elevated containers
  static const Color borderSubtle = Color(0xFF2B313A); // Subtle line dividers
  static const Color borderHighlight = Color(0x3DF0B90B); // Gold-tinted border

  // Signature Binance Gold & Star of David Accents
  static const Color gold = Color(0xFFF0B90B); // Primary Yellow/Gold
  static const Color goldBright = Color(0xFFFCD535); // Accent light gold
  static const Color goldGlow = Color(0x33F0B90B); // Ambient gold glow

  // High-Contrast Market Colors
  static const Color greenBullish = Color(0xFF0ECB81); // Crisp bullish green
  static const Color redBearish = Color(0xFFF6465D); // Crisp bearish red
  static const Color greenGlow = Color(0x260ECB81);
  static const Color redGlow = Color(0x26F6465D);

  // Typography Colors
  static const Color textPrimary = Color(0xFFEAECEF); // Crisp white
  static const Color textSecondary = Color(0xFF848E9C); // Cool muted grey
  static const Color textTertiary = Color(0xFF5E6673); // Dark muted grey

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: nightObsidian,
      cardColor: surfaceCharcoal,
      primaryColor: gold,
      dividerColor: borderSubtle,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldBright,
        surface: surfaceCharcoal,
        error: redBearish,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceCharcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceCharcoal,
        selectedItemColor: gold,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
