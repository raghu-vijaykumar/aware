import 'package:flutter/foundation.dart';
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

  // Seeds a curated list of engineering RSS feeds when running in debug mode
  // and the local database is empty. This avoids manual entry during dev/test.
  static const List<Map<String, String>> _debugFeedSources = [
    {
      'name': 'google',
      'url': 'https://developers.googleblog.com/feeds/posts/default'
    },
    {'name': 'google_research', 'url': 'https://research.google/blog/rss/'},
    {'name': 'meta', 'url': 'https://engineering.fb.com/feed/'},
    {'name': 'airbnb', 'url': 'https://medium.com/feed/airbnb-engineering'},
    {
      'name': 'linkedin',
      'url': 'https://engineering.linkedin.com/blog.rss.html'
    },
    {'name': 'spotify', 'url': 'https://engineering.atspotify.com/feed/'},
    {'name': 'dropbox', 'url': 'https://dropbox.tech/feed'},
    {'name': 'slack', 'url': 'https://slack.engineering/feed'},
    {
      'name': 'pinterest_rss',
      'url': 'https://medium.com/feed/pinterest-engineering'
    },
    {'name': 'microsoft', 'url': 'https://devblogs.microsoft.com/feed/'},
    {'name': 'aws', 'url': 'https://aws.amazon.com/blogs/aws/feed/'},
    {'name': 'github', 'url': 'https://github.blog/category/engineering/feed/'},
    {'name': 'cloudflare', 'url': 'https://blog.cloudflare.com/rss/'},
    {'name': 'databricks', 'url': 'https://www.databricks.com/feed'},
    {
      'name': 'atlassian',
      'url': 'https://www.atlassian.com/blog/artificial-intelligence/feed'
    },
    {'name': 'discord', 'url': 'https://discord.com/blog/rss.xml'},
    {'name': 'canva', 'url': 'https://www.canva.dev/blog/engineering/feed'},
    {'name': 'doordash', 'url': 'https://doordash.engineering/feed/'},
    {'name': 'grab', 'url': 'https://engineering.grab.com/feed'},
    {'name': 'gitlab', 'url': 'https://about.gitlab.com/atom.xml'},
    {'name': 'heroku', 'url': 'https://www.heroku.com/blog/feed/'},
    {'name': 'adobe', 'url': 'https://medium.com/feed/adobetech'},
    {'name': 'salesforce', 'url': 'https://engineering.salesforce.com/feed/'},
    {'name': 'dropbox_security', 'url': 'https://dropbox.tech/security/feed'},
    {'name': 'square', 'url': 'https://developer.squareup.com/blog/rss.xml'},
  ];

  static const double speechRateBase = 0.5;
  static const double speechRateMinRatio = 0.5;
  static const double speechRateMaxRatio = 4.0;
  static const double textScaleMin = 0.9;
  static const double textScaleMax = 1.4;

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

  double _speechRateRatio = 1.0; // 1.0 ratio equals the 0.5x TTS base speed.
  double get speechRate => _speechRateRatio;
  double get speechRateTts => (_speechRateRatio * speechRateBase).clamp(
        speechRateBase * speechRateMinRatio,
        speechRateBase * speechRateMaxRatio,
      );

  String? _voiceId;
  String? get voiceId => _voiceId;

  bool _autoPlayNext = false;
  bool get autoPlayNext => _autoPlayNext;

  double _textScaleFactor = 1.0;
  double get textScaleFactor => _textScaleFactor;

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
    final storedRatio =
        prefs.getDouble('app_tts_rate_ratio'); // New key (ratioed speeds).
    final legacyRate =
        prefs.getDouble('app_tts_rate'); // Legacy key (raw TTS rate).
    final savedTextScale = prefs.getDouble('app_text_scale');

    if (storedRatio != null) {
      _speechRateRatio = storedRatio.clamp(
        speechRateMinRatio,
        speechRateMaxRatio,
      );
    } else if (legacyRate != null) {
      // Convert legacy raw rate (e.g., 0.5–1.5) to the new ratio baseline.
      _speechRateRatio = (legacyRate / speechRateBase).clamp(
        speechRateMinRatio,
        speechRateMaxRatio,
      );
    } else {
      _speechRateRatio = 1.0; // Defaults to the calm 0.5x engine speed.
    }
    _voiceId = prefs.getString('app_tts_voice_id');
    _autoPlayNext = prefs.getBool('app_tts_autoplay_next') ?? false;
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
    _textScaleFactor = (savedTextScale ?? 1.0).clamp(
      textScaleMin,
      textScaleMax,
    );
    notifyListeners();
  }

  Future<void> loadFeeds() async {
    _feeds = await _db.getFeeds();
    await _loadArticleStateCache();
    notifyListeners();
  }

  Future<void> _seedMockDataIfEmpty() async {
    if (!kDebugMode) return;

    final existingFeeds = await _db.getFeeds();
    if (existingFeeds.isNotEmpty) return;

    for (final source in _debugFeedSources) {
      final url = source['url'];
      if (url == null) continue;

      try {
        final feed = await _feedService.fetchFeedMetadata(url);
        final feedWithFallback = Feed(
          url: feed.url,
          title: feed.title ?? source['name'],
          description: feed.description,
          siteUrl: feed.siteUrl,
          iconUrl: feed.iconUrl,
          category: feed.category,
          curator: feed.curator,
          paused: feed.paused,
          lastFetched: feed.lastFetched,
          etag: feed.etag,
          lastModified: feed.lastModified,
        );

        final id = await _db.insertFeed(feedWithFallback);
        final articles = await _feedService.fetchArticles(url);
        for (final article in articles) {
          await _db.insertArticle(article.copyWith(feedId: id));
        }
      } catch (err) {
        debugPrint('Debug feed seed failed for $url: $err');
      }
    }
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

  Future<List<Article>> getAllArticles() async {
    return await _db.getAllArticles();
  }

  Future<void> markArticleRead(String guid, {bool read = true}) async {
    final state = UserArticleState(
      articleGuid: guid,
      readAt: read ? DateTime.now().millisecondsSinceEpoch : null,
      likedAt: _articleStateCache[guid]?.likedAt,
      starredAt: _articleStateCache[guid]?.starredAt,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<void> markArticleLiked(String guid, {bool liked = true}) async {
    final state = UserArticleState(
      articleGuid: guid,
      readAt: _articleStateCache[guid]?.readAt,
      likedAt: liked ? DateTime.now().millisecondsSinceEpoch : null,
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
      likedAt: _articleStateCache[guid]?.likedAt,
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

  Future<void> setSpeechRate(double rate) async {
    _speechRateRatio = rate.clamp(speechRateMinRatio, speechRateMaxRatio);
    final prefs = await SharedPreferences.getInstance();
    // Persist both the new ratioed value and the legacy raw rate for backward compatibility.
    await prefs.setDouble('app_tts_rate_ratio', _speechRateRatio);
    await prefs.setDouble('app_tts_rate', speechRateTts);
    notifyListeners();
  }

  Future<void> setVoiceId(String? voiceId) async {
    _voiceId = voiceId;
    final prefs = await SharedPreferences.getInstance();
    if (voiceId == null) {
      await prefs.remove('app_tts_voice_id');
    } else {
      await prefs.setString('app_tts_voice_id', voiceId);
    }
    notifyListeners();
  }

  Future<void> setAutoPlayNext(bool enabled) async {
    _autoPlayNext = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_tts_autoplay_next', enabled);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double scale) async {
    _textScaleFactor = scale.clamp(textScaleMin, textScaleMax);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('app_text_scale', _textScaleFactor);
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
