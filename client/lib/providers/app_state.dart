import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/feed.dart';
import '../models/user_article_state.dart';
import '../services/database_service.dart';
import '../services/feed_service.dart';
import 'article_provider.dart';
import 'auth_provider.dart';
import 'feed_provider.dart';
import 'settings_provider.dart';
import 'sync_provider.dart';

class AppState extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FeedService _feedService = FeedService();

  final FeedProvider feed;
  final ArticleProvider article;
  final AuthProvider auth;
  final SettingsProvider settings;
  final SyncProvider sync;

  AppState({
    required this.feed,
    required this.article,
    required this.auth,
    required this.settings,
    required this.sync,
  }) {
    feed.addListener(notifyListeners);
    article.addListener(notifyListeners);
    auth.addListener(notifyListeners);
    settings.addListener(notifyListeners);
    sync.addListener(notifyListeners);
  }

  static const List<Map<String, String>> _debugFeedSources = [
    {'name': 'google', 'url': 'https://developers.googleblog.com/feeds/posts/default'},
    {'name': 'google_research', 'url': 'https://research.google/blog/rss/'},
    {'name': 'meta', 'url': 'https://engineering.fb.com/feed/'},
    {'name': 'airbnb', 'url': 'https://medium.com/feed/airbnb-engineering'},
    {'name': 'linkedin', 'url': 'https://engineering.linkedin.com/blog.rss.html'},
    {'name': 'spotify', 'url': 'https://engineering.atspotify.com/feed/'},
    {'name': 'dropbox', 'url': 'https://dropbox.tech/feed'},
    {'name': 'slack', 'url': 'https://slack.engineering/feed'},
    {'name': 'pinterest_rss', 'url': 'https://medium.com/feed/pinterest-engineering'},
    {'name': 'microsoft', 'url': 'https://devblogs.microsoft.com/feed/'},
    {'name': 'aws', 'url': 'https://aws.amazon.com/blogs/aws/feed/'},
    {'name': 'github', 'url': 'https://github.blog/category/engineering/feed/'},
    {'name': 'cloudflare', 'url': 'https://blog.cloudflare.com/rss/'},
    {'name': 'databricks', 'url': 'https://www.databricks.com/feed'},
    {'name': 'atlassian', 'url': 'https://www.atlassian.com/blog/artificial-intelligence/feed'},
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

  static double get speechRateBase => SettingsProvider.speechRateBase;
  static double get speechRateMinRatio => SettingsProvider.speechRateMinRatio;
  static double get speechRateMaxRatio => SettingsProvider.speechRateMaxRatio;
  static double get textScaleMin => SettingsProvider.textScaleMin;
  static double get textScaleMax => SettingsProvider.textScaleMax;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Backward-compatible getters — delegate to sub-providers
  List<Feed> get feeds => feed.feeds;
  bool get isSyncing => sync.isSyncing;
  String? get authToken => auth.authToken;
  String? get userEmail => auth.userEmail;
  bool get isLoggedIn => auth.isLoggedIn;
  ThemeMode get themeMode => settings.themeMode;
  Locale? get locale => settings.locale;
  double get speechRate => settings.speechRateRatio;
  double get speechRateTts => settings.speechRateTts;
  String? get voiceId => settings.voiceId;
  bool get autoPlayNext => settings.autoPlayNext;
  bool get lowDataMode => settings.lowDataMode;
  bool get autoMarkReadEnabled => settings.autoMarkReadEnabled;
  int get autoMarkReadThreshold => settings.autoMarkReadThreshold;
  double get textScaleFactor => settings.textScaleFactor;

  UserArticleState? getArticleState(String guid) => article.getArticleState(guid);

  Future<void> _seedMockDataIfEmpty() async {
    if (!kDebugMode) return;
    final existingFeeds = await _db.getFeeds();
    if (existingFeeds.isNotEmpty) return;
    for (final source in _debugFeedSources) {
      final url = source['url'];
      if (url == null) continue;
      try {
        final feedMeta = await _feedService.fetchFeedMetadata(url);
        final feedWithFallback = Feed(
          url: feedMeta.url,
          title: feedMeta.title ?? source['name'],
          description: feedMeta.description,
          siteUrl: feedMeta.siteUrl,
          iconUrl: feedMeta.iconUrl,
          category: feedMeta.category,
          curator: feedMeta.curator,
          paused: feedMeta.paused,
          lastFetched: feedMeta.lastFetched,
          etag: feedMeta.etag,
          lastModified: feedMeta.lastModified,
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
    await auth.load();
    await settings.load();
    await _seedMockDataIfEmpty();
    await article.loadArticleStateCache();
    await feed.loadFeeds();
    _isInitialized = true;
    notifyListeners();
  }

  // Feeds
  Future<void> loadFeeds() => feed.loadFeeds();
  Future<void> addFeedFromUrl(String url) => feed.addFeedFromUrl(url);
  Future<void> deleteFeed(int feedId) => feed.deleteFeed(feedId);

  // Articles
  Future<List<Article>> getArticlesForFeed(int feedId) => article.getArticlesForFeed(feedId);
  Future<List<Article>> getAllArticles() => article.getAllArticles();
  Future<List<Article>> getArticlesPaginated({int? feedId, int? limit, int offset = 0}) =>
      article.getArticlesPaginated(feedId: feedId, limit: limit, offset: offset);
  Future<int> getArticlesCount({int? feedId}) =>
      article.getArticlesCount(feedId: feedId);
  Future<void> markArticleRead(String guid, {bool read = true}) =>
      article.markArticleRead(guid, read: read);
  Future<void> markArticleLiked(String guid, {bool liked = true}) =>
      article.markArticleLiked(guid, liked: liked);
  Future<void> markArticleStarred(String guid, {bool starred = true}) =>
      article.markArticleStarred(guid, starred: starred);
  Future<void> recordArticleProgress(String guid, double progress, int paragraphIndex) =>
      article.recordArticleProgress(guid, progress, paragraphIndex);
  Future<List<Article>> getStarredArticles() => article.getStarredArticles();

  // Auth
  Future<void> login(String email, String password) => auth.login(email, password);
  Future<void> logout() => auth.logout();

  // Settings
  Future<void> setThemeMode(ThemeMode mode) => settings.setThemeMode(mode);
  Future<void> setLocale(String languageCode) => settings.setLocale(languageCode);
  Future<void> setSpeechRate(double rate) => settings.setSpeechRate(rate);
  Future<void> setVoiceId(String? voiceId) => settings.setVoiceId(voiceId);
  Future<void> setAutoPlayNext(bool enabled) => settings.setAutoPlayNext(enabled);
  Future<void> setTextScaleFactor(double scale) => settings.setTextScaleFactor(scale);
  Future<void> setLowDataMode(bool enabled) => settings.setLowDataMode(enabled);
  Future<void> setAutoMarkReadEnabled(bool enabled) => settings.setAutoMarkReadEnabled(enabled);
  Future<void> setAutoMarkReadThreshold(int thresholdPercent) =>
      settings.setAutoMarkReadThreshold(thresholdPercent);

  // Sync
  Future<void> syncState() => sync.syncState(auth);

  @override
  void dispose() {
    feed.removeListener(notifyListeners);
    article.removeListener(notifyListeners);
    auth.removeListener(notifyListeners);
    settings.removeListener(notifyListeners);
    sync.removeListener(notifyListeners);
    super.dispose();
  }
}
