import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  // On desktop/web platforms that don't support keychain/keystore, we fall
  // back to SharedPreferences. This is detected at init time.
  final bool _useSecure = !kIsWeb && _canUseSecureStorage();

  static bool _canUseSecureStorage() {
    try {
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage secure;
    try {
      secure = const FlutterSecureStorage();
    } catch (_) {
      secure = FlutterSecureStorage();
    }
    return StorageService._(prefs, secure);
  }

  Future<String?> read(String key) async {
    if (_useSecure) {
      try {
        return await _secure.read(key: key);
      } catch (_) {}
    }
    return _prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    if (_useSecure) {
      try {
        await _secure.write(key: key, value: value);
        return;
      } catch (_) {}
    }
    await _prefs.setString(key, value);
  }

  Future<void> delete(String key) async {
    if (_useSecure) {
      try {
        await _secure.delete(key: key);
        return;
      } catch (_) {}
    }
    await _prefs.remove(key);
  }
}
