import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/background_feed_worker.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _ttsRateRatioKey = 'app_tts_rate_ratio';
  static const String _ttsRateLegacyKey = 'app_tts_rate';
  static const String _ttsVoiceIdKey = 'app_tts_voice_id';
  static const String _ttsAutoPlayKey = 'app_tts_autoplay_next';
  static const String _lowDataModeKey = 'app_low_data_mode';
  static const String _autoMarkReadKey = 'app_auto_mark_read_enabled';
  static const String _autoMarkReadThresholdKey = 'app_auto_mark_read_threshold';
  static const String _textScaleKey = 'app_text_scale';

  static const double speechRateBase = 0.5;
  static const double speechRateMinRatio = 0.5;
  static const double speechRateMaxRatio = 4.0;
  static const double textScaleMin = 0.9;
  static const double textScaleMax = 1.4;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  double _speechRateRatio = 1.0;
  double get speechRateRatio => _speechRateRatio;
  double get speechRateTts => (_speechRateRatio * speechRateBase).clamp(
        speechRateBase * speechRateMinRatio,
        speechRateBase * speechRateMaxRatio,
      );

  String? _voiceId;
  String? get voiceId => _voiceId;

  bool _autoPlayNext = false;
  bool get autoPlayNext => _autoPlayNext;

  bool _lowDataMode = false;
  bool get lowDataMode => _lowDataMode;

  bool _autoMarkReadEnabled = true;
  bool get autoMarkReadEnabled => _autoMarkReadEnabled;

  int _autoMarkReadThreshold = 70;
  int get autoMarkReadThreshold => _autoMarkReadThreshold;

  double _textScaleFactor = 1.0;
  double get textScaleFactor => _textScaleFactor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }

    final storedRatio = prefs.getDouble(_ttsRateRatioKey);
    final legacyRate = prefs.getDouble(_ttsRateLegacyKey);
    if (storedRatio != null) {
      _speechRateRatio = storedRatio.clamp(speechRateMinRatio, speechRateMaxRatio);
    } else if (legacyRate != null) {
      _speechRateRatio = (legacyRate / speechRateBase).clamp(
        speechRateMinRatio,
        speechRateMaxRatio,
      );
    }

    _voiceId = prefs.getString(_ttsVoiceIdKey);
    _autoPlayNext = prefs.getBool(_ttsAutoPlayKey) ?? false;
    _lowDataMode = prefs.getBool(_lowDataModeKey) ?? false;
    _autoMarkReadEnabled = prefs.getBool(_autoMarkReadKey) ?? true;
    _autoMarkReadThreshold = (prefs.getInt(_autoMarkReadThresholdKey) ?? 70).clamp(1, 100);
    _textScaleFactor = (prefs.getDouble(_textScaleKey) ?? 1.0).clamp(
      textScaleMin,
      textScaleMax,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_themeKey, value);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRateRatio = rate.clamp(speechRateMinRatio, speechRateMaxRatio);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ttsRateRatioKey, _speechRateRatio);
    await prefs.setDouble(_ttsRateLegacyKey, speechRateTts);
    notifyListeners();
  }

  Future<void> setVoiceId(String? voiceId) async {
    _voiceId = voiceId;
    final prefs = await SharedPreferences.getInstance();
    if (voiceId == null) {
      await prefs.remove(_ttsVoiceIdKey);
    } else {
      await prefs.setString(_ttsVoiceIdKey, voiceId);
    }
    notifyListeners();
  }

  Future<void> setAutoPlayNext(bool enabled) async {
    _autoPlayNext = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsAutoPlayKey, enabled);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double scale) async {
    _textScaleFactor = scale.clamp(textScaleMin, textScaleMax);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, _textScaleFactor);
    notifyListeners();
  }

  Future<void> setLowDataMode(bool enabled) async {
    _lowDataMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lowDataModeKey, enabled);
    notifyListeners();
    await BackgroundFeedWorker.schedulePeriodicRefresh();
  }

  Future<void> setAutoMarkReadEnabled(bool enabled) async {
    _autoMarkReadEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoMarkReadKey, enabled);
    notifyListeners();
  }

  Future<void> setAutoMarkReadThreshold(int thresholdPercent) async {
    _autoMarkReadThreshold = thresholdPercent.clamp(1, 100);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoMarkReadThresholdKey, _autoMarkReadThreshold);
    notifyListeners();
  }
}
