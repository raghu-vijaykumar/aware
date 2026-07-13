import 'package:flutter/foundation.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class SyncProvider extends ChangeNotifier {
  final ApiService _api;
  final DatabaseService _db;

  SyncProvider({ApiService? api, DatabaseService? db})
      : _api = api ?? ApiService(),
        _db = db ?? DatabaseService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool get isAvailable => AppConfig.hasServer;

  Future<void> syncState(AuthProvider auth) async {
    if (!isAvailable || !auth.isLoggedIn) return;
    _isSyncing = true;
    notifyListeners();

    final changes = await _db.getAllUserState();
    final read = changes
        .where((c) => c.readAt != null)
        .map((c) => c.articleGuid)
        .toList();
    final starred = changes
        .where((c) => c.starredAt != null)
        .map((c) => c.articleGuid)
        .toList();

    await _api.syncState(auth.authToken!, read: read, starred: starred);
    _isSyncing = false;
    notifyListeners();
  }
}
