import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static String? _serverUrl;
  static bool _initialized = false;

  @visibleForTesting
  static void setTestServerUrl(String url) {
    _serverUrl = url;
  }

  static String? get serverUrl => _serverUrl;

  static bool get hasServer => _serverUrl != null && _serverUrl!.isNotEmpty;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _serverUrl = const String.fromEnvironment(
      'AWARE_SERVER_URL',
      defaultValue: '',
    );

    if (_serverUrl == null || _serverUrl!.isEmpty) {
      try {
        final file = File('config.json');
        if (await file.exists()) {
          final contents = await file.readAsString();
          final json = jsonDecode(contents);
          if (json['server_url'] is String) {
            final url = json['server_url'] as String;
            if (url.isNotEmpty) {
              _serverUrl = url;
            }
          }
        }
      } catch (e) {
        print('AppConfig.init: failed to read config.json: $e');
      }
    }
  }
}
