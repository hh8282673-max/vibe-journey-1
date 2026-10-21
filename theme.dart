import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VC {
  static const bg = Color(0xFF0D0E12);
  static const surface = Color(0xFF121317);
  static const card = Color(0xFF1A1B20);
  static const high = Color(0xFF24262E);
  static const primary = Color(0xFF6366F1);
  static const glow = Color(0xFF818CF8);
  static const pink = Color(0xFFEC4899);
  static const text = Color(0xFFF3F4F6);
  static const muted = Color(0xFF9CA3AF);
}

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: VC.bg,
    colorScheme: const ColorScheme.dark(
      primary: VC.primary,
      secondary: VC.pink,
      surface: VC.surface,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: VC.text, displayColor: VC.text),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: VC.surface,
      indicatorColor: VC.primary.withAlpha(70),
    ),
  );
}
