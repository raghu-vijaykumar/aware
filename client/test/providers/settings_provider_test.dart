import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/providers/settings_provider.dart';

void main() {
  late SettingsProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = SettingsProvider();
  });

  group('SettingsProvider', () {
    test('load sets default values when nothing stored', () async {
      await provider.load();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.speechRateRatio, 1.0);
      expect(provider.voiceId, isNull);
      expect(provider.autoPlayNext, isFalse);
      expect(provider.autoMarkReadEnabled, isTrue);
      expect(provider.autoMarkReadThreshold, 70);
      expect(provider.textScaleFactor, 1.0);
      expect(provider.locale, isNotNull);
    });

    test('load restores stored values', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'dark',
        'app_tts_rate_ratio': 1.5,
        'app_tts_voice_id': 'voice-en',
        'app_tts_autoplay_next': true,
        'app_auto_mark_read_enabled': false,
        'app_auto_mark_read_threshold': 50,
        'app_text_scale': 1.2,
        'app_locale': 'fr',
      });
      provider = SettingsProvider();
      await provider.load();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.speechRateRatio, 1.5);
      expect(provider.voiceId, 'voice-en');
      expect(provider.autoPlayNext, isTrue);
      expect(provider.autoMarkReadEnabled, isFalse);
      expect(provider.autoMarkReadThreshold, 50);
      expect(provider.textScaleFactor, 1.2);
      expect(provider.locale, const Locale('fr'));
    });

    test('load uses legacy tts rate when no ratio is stored', () async {
      SharedPreferences.setMockInitialValues({
        'app_tts_rate': 0.4,
      });
      provider = SettingsProvider();
      await provider.load();

      expect(provider.speechRateRatio, 0.8);
    });

    test('load clamps tts rate ratio to valid range', () async {
      SharedPreferences.setMockInitialValues({
        'app_tts_rate_ratio': 10.0,
      });
      provider = SettingsProvider();
      await provider.load();

      expect(provider.speechRateRatio, 4.0);
    });

    test('load uses system theme for invalid theme value', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'invalid',
      });
      provider = SettingsProvider();
      await provider.load();

      expect(provider.themeMode, ThemeMode.system);
    });

    test('setThemeMode updates value and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(notifyCount, 1);
    });

    test('setSpeechRate updates value and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setSpeechRate(2.0);

      expect(provider.speechRateRatio, 2.0);
      expect(notifyCount, 1);
    });

    test('setSpeechRate clamps to valid range', () async {
      await provider.load();

      await provider.setSpeechRate(10.0);

      expect(provider.speechRateRatio, 4.0);
    });

    test('setVoiceId with null removes stored voice', () async {
      SharedPreferences.setMockInitialValues({
        'app_tts_voice_id': 'old-voice',
      });
      provider = SettingsProvider();
      await provider.load();
      expect(provider.voiceId, 'old-voice');

      await provider.setVoiceId(null);

      expect(provider.voiceId, isNull);
    });

    test('setVoiceId with value stores and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setVoiceId('new-voice');

      expect(provider.voiceId, 'new-voice');
      expect(notifyCount, 1);
    });

    test('setAutoPlayNext updates value and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setAutoPlayNext(true);

      expect(provider.autoPlayNext, isTrue);
      expect(notifyCount, 1);
    });

    test('setTextScaleFactor updates value and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setTextScaleFactor(1.3);

      expect(provider.textScaleFactor, 1.3);
      expect(notifyCount, 1);
    });

    test('setTextScaleFactor clamps to valid range', () async {
      await provider.load();

      await provider.setTextScaleFactor(2.0);

      expect(provider.textScaleFactor, 1.4);
    });

    test('setAutoMarkReadEnabled updates value and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setAutoMarkReadEnabled(false);

      expect(provider.autoMarkReadEnabled, isFalse);
      expect(notifyCount, 1);
    });

    test('setAutoMarkReadThreshold updates value and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setAutoMarkReadThreshold(80);

      expect(provider.autoMarkReadThreshold, 80);
      expect(notifyCount, 1);
    });

    test('setAutoMarkReadThreshold clamps to 1-100', () async {
      await provider.load();

      await provider.setAutoMarkReadThreshold(200);

      expect(provider.autoMarkReadThreshold, 100);
    });

    test('speechRateTts is computed from ratio', () async {
      await provider.load();

      expect(provider.speechRateTts, closeTo(0.5, 0.001));

      await provider.setSpeechRate(2.0);

      expect(provider.speechRateTts, closeTo(1.0, 0.001));
    });

    test('setLocale updates locale and notifies', () async {
      await provider.load();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale('es');

      expect(provider.locale, const Locale('es'));
      expect(notifyCount, 1);
    });

    test('load restores light theme mode', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'light',
      });
      provider = SettingsProvider();
      await provider.load();

      expect(provider.themeMode, ThemeMode.light);
    });
  });
}
