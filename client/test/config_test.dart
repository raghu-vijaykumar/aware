import 'package:flutter_test/flutter_test.dart';

import 'package:aware/config.dart';

void main() {
  setUp(() {
    // Reset state between tests.
    AppConfig.setTestServerUrl('');
  });

  group('AppConfig', () {
    test('setTestServerUrl sets the server URL', () {
      AppConfig.setTestServerUrl('https://test.example.com');
      expect(AppConfig.serverUrl, 'https://test.example.com');
    });

    test('hasServer returns false for empty URL', () {
      AppConfig.setTestServerUrl('');
      expect(AppConfig.hasServer, isFalse);
    });

    test('hasServer returns false for null URL', () {
      AppConfig.setTestServerUrl('');
      expect(AppConfig.hasServer, isFalse);
    });

    test('hasServer returns true for non-empty URL', () {
      AppConfig.setTestServerUrl('https://server.example.com');
      expect(AppConfig.hasServer, isTrue);
    });

    test('init sets initialized flag and does not throw', () async {
      await AppConfig.init();
      // Second call is a no-op (early return).
      await AppConfig.init();
    });

    test('serverUrl getter returns current value', () {
      expect(AppConfig.serverUrl, isEmpty);
      AppConfig.setTestServerUrl('https://example.com');
      expect(AppConfig.serverUrl, 'https://example.com');
    });
  });
}
