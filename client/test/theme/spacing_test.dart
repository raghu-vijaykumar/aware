import 'package:flutter_test/flutter_test.dart';

import 'package:aware/theme/spacing.dart';

void main() {
  group('AppSpacing', () {
    test('values are correct', () {
      expect(AppSpacing.s4, 4.0);
      expect(AppSpacing.s8, 8.0);
      expect(AppSpacing.s12, 12.0);
      expect(AppSpacing.s16, 16.0);
      expect(AppSpacing.s24, 24.0);
      expect(AppSpacing.s32, 32.0);
      expect(AppSpacing.s48, 48.0);
      expect(AppSpacing.s64, 64.0);
    });

  });
}
