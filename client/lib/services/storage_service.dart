import 'package:shared_preferences/shared_preferences.dart';

/// A minimal cross-platform key/value storage wrapper.
///
/// This is used for storing non-sensitive app state like auth tokens.
/// It is intentionally minimal to keep the dependency surface small.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Future<String?> read(String key) async {
    return _prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }
}
