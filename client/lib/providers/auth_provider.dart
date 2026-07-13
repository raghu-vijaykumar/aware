import 'package:flutter/foundation.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  StorageService? _storage;

  AuthProvider({ApiService? api, StorageService? storage})
      : _api = api ?? ApiService(),
        _storage = storage;

  String? _authToken;
  String? get authToken => _authToken;

  String? _userEmail;
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _authToken != null;

  bool get isAvailable => AppConfig.hasServer;

  Future<void> load() async {
    _storage ??= await StorageService.getInstance();
    _authToken = await _storage!.read('auth_token');
    _userEmail = await _storage!.read('auth_email');
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (!isAvailable) return;
    final resp = await _api.login(email, password);
    _authToken = resp['token'] as String?;
    _userEmail = resp['user']?['email'] as String?;
    if (_authToken != null) {
      _storage ??= await StorageService.getInstance();
      await _storage!.write('auth_token', _authToken!);
      if (_userEmail != null) {
        await _storage!.write('auth_email', _userEmail!);
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _authToken = null;
    _userEmail = null;
    _storage ??= await StorageService.getInstance();
    await _storage!.delete('auth_token');
    await _storage!.delete('auth_email');
    notifyListeners();
  }
}
