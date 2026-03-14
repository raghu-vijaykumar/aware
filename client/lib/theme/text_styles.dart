import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale anchored around three headline/body tiers.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme base() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 14,
        height: 1.4,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
