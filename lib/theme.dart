import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const leaf = Color(0xFF2E7D4F);
const leafDark = Color(0xFF7CC79A);
const harvest = Color(0xFFE8B84A);
const cream = Color(0xFFF7F2E7);
const soil = Color(0xFF3A2A1F);

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
