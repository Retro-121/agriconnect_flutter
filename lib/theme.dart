import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const leaf = Color(0xFF2E7D4F);
const leafDark = Color(0xFF7CC79A);
const harvest = Color(0xFFE8B84A);
const cream = Color(0xFFF7F2E7);
const soil = Color(0xFF3A2A1F);

class AppColors {
  static const forest = Color(0xFF2F6B3E);
  static const forestDeep = Color(0xFF1E4A2B);
  static const olive = Color(0xFF6B7A3A);
  static const lime = Color(0xFFA8D85C);
  static const earth = Color(0xFF8B5E34);
  static const amber = Color(0xFFE0A93C);
  static const emergency = Color(0xFFE2453C);
  static const info = Color(0xFF3E8DDC);
  static const bg = Color(0xFFF7F8F4);
  static const card = Colors.white;
  static const muted = Color(0xFF6B7280);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.forest,
    primary: AppColors.forest,
    secondary: AppColors.lime,
    error: AppColors.emergency,
    surface: AppColors.card,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: leaf,
      secondary: harvest,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: cream,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 32, color: soil),
      headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 24, color: soil),
      titleLarge: GoogleFonts.dmSerifDisplay(fontSize: 20, color: soil),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: leafDark,
      secondary: harvest,
      surface: const Color(0xFF1A1F1B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1410),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 32, color: Colors.white),
      headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 24, color: Colors.white),
      titleLarge: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
    ),
  );
}
