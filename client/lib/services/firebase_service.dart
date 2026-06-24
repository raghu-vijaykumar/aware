import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService _instance = FirebaseService._();

  factory FirebaseService() => _instance;

  static FirebaseService get instance => _instance;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? information,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[FirebaseService] Record error (non-mobile): $error');
      return;
    }

    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
      information: information?.entries.map((e) => '${e.key}: ${e.value}' as Object) ?? <Object>[],
    );
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[FirebaseService] Record Flutter error (non-mobile): ${details.exception}');
      return;
    }

    await FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  Future<void> setUserId(String userId) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  Future<void> log(String message) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[FirebaseService] Log: $message');
      return;
    }
    await FirebaseCrashlytics.instance.log(message);
  }

  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
  }
}