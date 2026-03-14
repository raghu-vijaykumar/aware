import 'package:flutter/material.dart';

/// Brand tokens and shared palette values for the app.
class AppColors {
  AppColors._();

  static const int _primaryValue = 0xFF4F46E5;

  static const MaterialColor primarySwatch = MaterialColor(_primaryValue, {
    50: Color(0xFFEDEBFF),
    100: Color(0xFFCFC5FF),
    200: Color(0xFFB0A0FF),
    300: Color(0xFF9281FF),
    400: Color(0xFF785FF7),
    500: Color(_primaryValue),
    600: Color(0xFF3E3ADA),
    700: Color(0xFF3330BD),
    800: Color(0xFF2728A1),
    900: Color(0xFF1B1D77),
  });

  static const Color primary = Color(_primaryValue);
  static const Color primaryContainer = Color(0xFFF4F3FF);
  static const Color secondary = Color(0xFF22C55E);
  static const Color secondaryContainer = Color(0xFFD9F7DD);
  static const Color background = Color(0xFFF3F4F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF031B03);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
}
