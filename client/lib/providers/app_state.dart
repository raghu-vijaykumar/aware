import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';
import '../models/feed.dart';
import '../models/user_article_state.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/feed_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FeedService _feedService = FeedService();
  final ApiService _apiService = ApiService();

  // A lightweight cross-platform storage implementation.
  StorageService? _storage;

  List<Feed> _feeds = [];
  List<Feed> get feeds => _feeds;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _authToken;
  String? get authToken => _authToken;

  String? _userEmail;
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _authToken != null;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  final Map<String, UserArticleState> _articleStateCache = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  UserArticleState? getArticleState(String guid) => _articleStateCache[guid];

  Future<void> _loadArticleStateCache() async {
    final states = await _db.getAllUserState();
    _articleStateCache
      ..clear()
      ..addEntries(states.map((s) => MapEntry(s.articleGuid, s)));
  }

  Future<void> _loadAuthToken() async {
    _storage ??= await StorageService.getInstance();

    final token = await _storage!.read('auth_token');
    final email = await _storage!.read('auth_email');
    _authToken = token;
    _userEmail = email;

    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme_mode');
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
    notifyListeners();
  }

  Future<void> loadFeeds() async {
    _feeds = await _db.getFeeds();
    await _loadArticleStateCache();
    notifyListeners();
  }

  Future<void> _seedMockDataIfEmpty() async {
    // Mock data seeding disabled to reduce memory pressure and avoid OOM when
    // adding real feeds. Existing user data is preserved.
    return;
  }

  Future<void> init() async {
    await _loadAuthToken();
    await _seedMockDataIfEmpty();
    await loadFeeds();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addFeedFromUrl(String url) async {
    final feed = await _feedService.fetchFeedMetadata(url);
    final id = await _db.insertFeed(feed);
    final articles = await _feedService.fetchArticles(url);

    for (final article in articles) {
      await _db.insertArticle(article.copyWith(feedId: id));
    }

    await loadFeeds();
  }

  Future<List<Article>> getArticlesForFeed(int feedId) async {
    return await _db.getArticlesForFeed(feedId);
  }

  Future<void> markArticleRead(String guid, {bool read = true}) async {
    final state = UserArticleState(
      articleGuid: guid,
      readAt: read ? DateTime.now().millisecondsSinceEpoch : null,
      starredAt: _articleStateCache[guid]?.starredAt,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<void> markArticleStarred(String guid, {bool starred = true}) async {
    final state = UserArticleState(
      articleGuid: guid,
      readAt: _articleStateCache[guid]?.readAt,
      starredAt: starred ? DateTime.now().millisecondsSinceEpoch : null,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final resp = await _apiService.login(email, password);
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

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString('app_theme_mode', value);
    notifyListeners();
  }

  Future<List<Article>> getStarredArticles() async {
    return await _db.getStarredArticles();
  }

  Future<void> syncState() async {
    if (_authToken == null) return;
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

    await _apiService.syncState(_authToken!, read: read, starred: starred);
    _isSyncing = false;
    notifyListeners();
  }
}
