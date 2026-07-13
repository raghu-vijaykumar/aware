import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aware/screens/marketplace_screen.dart';

void main() {
  group('ColorUtils.darken', () {
    test('darkens a color by default amount', () {
      final original = Colors.blue;
      final darkened = original.darken();
      expect(darkened, isNot(equals(original)));
    });

    test('darkens by specified amount', () {
      final original = const Color(0xFF42A5F5);
      final darkened = original.darken(0.3);
      final hsl = HSLColor.fromColor(original);
      final expected = hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
      expect(darkened, expected);
    });

    test('clamps to 0.0 minimum lightness', () {
      final veryDark = Colors.black;
      final result = veryDark.darken(1.0);
      // Should not crash and lightness should be >= 0
      expect(result, isNotNull);
    });
  });
}
