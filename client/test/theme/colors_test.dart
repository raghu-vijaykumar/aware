import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aware/theme/colors.dart';

void main() {
  group('AppColors', () {
    test('primary swatch has correct values', () {
      expect(AppColors.primarySwatch, isA<MaterialColor>());
      expect(AppColors.primarySwatch[50], const Color(0xFFEDEBFF));
      expect(AppColors.primarySwatch[100], const Color(0xFFCFC5FF));
      expect(AppColors.primarySwatch[200], const Color(0xFFB0A0FF));
      expect(AppColors.primarySwatch[300], const Color(0xFF9281FF));
      expect(AppColors.primarySwatch[400], const Color(0xFF785FF7));
      expect(AppColors.primarySwatch[500], const Color(0xFF4F46E5));
      expect(AppColors.primarySwatch[600], const Color(0xFF3E3ADA));
      expect(AppColors.primarySwatch[700], const Color(0xFF3330BD));
      expect(AppColors.primarySwatch[800], const Color(0xFF2728A1));
      expect(AppColors.primarySwatch[900], const Color(0xFF1B1D77));
    });

    test('named colors have correct values', () {
      expect(AppColors.primary, const Color(0xFF4F46E5));
      expect(AppColors.primaryContainer, const Color(0xFFF4F3FF));
      expect(AppColors.secondary, const Color(0xFF22C55E));
      expect(AppColors.secondaryContainer, const Color(0xFFD9F7DD));
      expect(AppColors.background, const Color(0xFFF3F4F6));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.error, const Color(0xFFEF4444));
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.onSecondary, const Color(0xFF031B03));
      expect(AppColors.textPrimary, const Color(0xFF111827));
      expect(AppColors.textSecondary, const Color(0xFF6B7280));
    });

    test('dark theme colors have correct values', () {
      expect(AppColors.darkBackground, const Color(0xFF121212));
      expect(AppColors.darkSurface, const Color(0xFF1E1E1E));
      expect(AppColors.darkOnSurface, const Color(0xFFF1F5F9));
    });

  });
}
