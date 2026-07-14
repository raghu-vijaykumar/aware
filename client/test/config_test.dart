import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aware/config.dart';

void main() {
  setUp(() {
    AppConfig.resetForTesting();
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
      await AppConfig.init();
    });

    test('init reads server_url from config.json', () async {
      const testUrl = 'https://test-server.example.com';
      final configFile = File('config.json');
      await configFile.writeAsString(jsonEncode({'server_url': testUrl}));
      AppConfig.setTestServerUrl('');

      await AppConfig.init();

      expect(AppConfig.serverUrl, testUrl);
      await configFile.delete();
    });

    test('init handles malformed config.json', () async {
      final configFile = File('config.json');
      await configFile.writeAsString('not json');
      AppConfig.setTestServerUrl('');

      await AppConfig.init();

      expect(AppConfig.serverUrl, isEmpty);
      await configFile.delete();
    });

    test('serverUrl getter returns current value', () {
      expect(AppConfig.serverUrl, isEmpty);
      AppConfig.setTestServerUrl('https://example.com');
      expect(AppConfig.serverUrl, 'https://example.com');
    });
  });
}
