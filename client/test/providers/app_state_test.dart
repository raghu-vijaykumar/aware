import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/models/article.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/models/user_article_state.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/providers/article_provider.dart';
import 'package:aware/providers/auth_provider.dart';
import 'package:aware/providers/feed_provider.dart';
import 'package:aware/providers/settings_provider.dart';
import 'package:aware/providers/sync_provider.dart';
import 'package:aware/services/database_service.dart';
import 'package:aware/services/feed_service.dart';

class MockFeedProvider extends Mock implements FeedProvider {}

class MockArticleProvider extends Mock implements ArticleProvider {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockSettingsProvider extends Mock implements SettingsProvider {}

class MockSyncProvider extends Mock implements SyncProvider {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockFeedService extends Mock implements FeedService {}

void main() {
  late MockFeedProvider mockFeed;
  late MockArticleProvider mockArticle;
  late MockAuthProvider mockAuth;
  late MockSettingsProvider mockSettings;
  late MockSyncProvider mockSync;
  late MockDatabaseService mockDb;
  late MockFeedService mockFeedService;
  late AppState appState;

  setUpAll(() {
    registerFallbackValue(Article(feedId: 0, guid: ''));
    registerFallbackValue(Feed(url: ''));
    registerFallbackValue(UserArticleState(articleGuid: ''));
  });

  setUp(() {
    mockFeed = MockFeedProvider();
    mockArticle = MockArticleProvider();
    mockAuth = MockAuthProvider();
    mockSettings = MockSettingsProvider();
    mockSync = MockSyncProvider();
    mockDb = MockDatabaseService();
    mockFeedService = MockFeedService();

    when(() => mockDb.getFeeds()).thenAnswer((_) async => [
          Feed(url: 'https://example.com/rss'),
        ]);

    appState = AppState(
      feed: mockFeed,
      article: mockArticle,
      auth: mockAuth,
      settings: mockSettings,
      sync: mockSync,
      db: mockDb,
      feedService: mockFeedService,
    );
  });

  group('AppState', () {
    test('init calls sub-provider initialization methods', () async {
      when(() => mockAuth.load()).thenAnswer((_) async {});
      when(() => mockSettings.load()).thenAnswer((_) async {});
      when(() => mockArticle.loadArticleStateCache()).thenAnswer((_) async {});
      when(() => mockFeed.loadFeeds()).thenAnswer((_) async {});

      await appState.init();

      verify(() => mockAuth.load()).called(1);
      verify(() => mockSettings.load()).called(1);
      verify(() => mockArticle.loadArticleStateCache()).called(1);
      verify(() => mockFeed.loadFeeds()).called(1);
      expect(appState.isInitialized, isTrue);
    });

    test('backward-compatible getters delegate to sub-providers', () {
      when(() => mockFeed.feeds).thenReturn([]);
      when(() => mockSync.isSyncing).thenReturn(false);
      when(() => mockAuth.authToken).thenReturn('token');
      when(() => mockAuth.isLoggedIn).thenReturn(true);
      when(() => mockSettings.themeMode).thenReturn(ThemeMode.dark);
      when(() => mockSettings.speechRateRatio).thenReturn(1.5);
      when(() => mockSettings.autoPlayNext).thenReturn(true);
      when(() => mockSettings.autoMarkReadEnabled).thenReturn(false);
      when(() => mockSettings.autoMarkReadThreshold).thenReturn(50);
      when(() => mockSettings.textScaleFactor).thenReturn(1.2);
      when(() => mockSettings.voiceId).thenReturn('v1');

      expect(appState.feeds, isEmpty);
      expect(appState.isSyncing, isFalse);
      expect(appState.authToken, 'token');
      expect(appState.isLoggedIn, isTrue);
      expect(appState.themeMode, ThemeMode.dark);
      expect(appState.speechRate, 1.5);
      expect(appState.autoPlayNext, isTrue);
      expect(appState.autoMarkReadEnabled, isFalse);
      expect(appState.autoMarkReadThreshold, 50);
      expect(appState.textScaleFactor, 1.2);
      expect(appState.voiceId, 'v1');
    });

    test('delegate methods call sub-provider methods', () async {
      when(() => mockFeed.loadFeeds()).thenAnswer((_) async {});
      when(() => mockFeed.addFeedFromUrl('url')).thenAnswer((_) async {});
      when(() => mockFeed.deleteFeed(1)).thenAnswer((_) async {});
      when(() => mockArticle.getArticlesForFeed(1)).thenAnswer((_) async => []);
      when(() => mockArticle.getAllArticles()).thenAnswer((_) async => []);
      when(() => mockArticle.getArticlesPaginated()).thenAnswer((_) async => []);
      when(() => mockArticle.getArticlesCount()).thenAnswer((_) async => 0);
      when(() => mockArticle.markArticleRead('g', read: true)).thenAnswer((_) async {});
      when(() => mockArticle.markArticleLiked('g', liked: true)).thenAnswer((_) async {});
      when(() => mockArticle.markArticleStarred('g', starred: true)).thenAnswer((_) async {});
      when(() => mockArticle.recordArticleProgress('g', 0.5, 1)).thenAnswer((_) async {});
      when(() => mockArticle.getStarredArticles()).thenAnswer((_) async => []);
      when(() => mockAuth.login('e', 'p')).thenAnswer((_) async {});
      when(() => mockAuth.logout()).thenAnswer((_) async {});
      when(() => mockSettings.setThemeMode(ThemeMode.light)).thenAnswer((_) async {});
      when(() => mockSettings.setLocale('fr')).thenAnswer((_) async {});
      when(() => mockSettings.setSpeechRate(2.0)).thenAnswer((_) async {});
      when(() => mockSettings.setVoiceId('v2')).thenAnswer((_) async {});
      when(() => mockSettings.setAutoPlayNext(false)).thenAnswer((_) async {});
      when(() => mockSettings.setTextScaleFactor(1.1)).thenAnswer((_) async {});
      when(() => mockSettings.setAutoMarkReadEnabled(true)).thenAnswer((_) async {});
      when(() => mockSettings.setAutoMarkReadThreshold(80)).thenAnswer((_) async {});
      when(() => mockSync.syncState(mockAuth)).thenAnswer((_) async {});

      await appState.loadFeeds();
      verify(() => mockFeed.loadFeeds()).called(1);

      await appState.addFeedFromUrl('url');
      verify(() => mockFeed.addFeedFromUrl('url')).called(1);

      await appState.deleteFeed(1);
      verify(() => mockFeed.deleteFeed(1)).called(1);

      await appState.getArticlesForFeed(1);
      verify(() => mockArticle.getArticlesForFeed(1)).called(1);

      await appState.getAllArticles();
      verify(() => mockArticle.getAllArticles()).called(1);

      await appState.getArticlesPaginated();
      verify(() => mockArticle.getArticlesPaginated()).called(1);

      await appState.getArticlesCount();
      verify(() => mockArticle.getArticlesCount()).called(1);

      await appState.markArticleRead('g');
      verify(() => mockArticle.markArticleRead('g', read: true)).called(1);

      await appState.markArticleLiked('g');
      verify(() => mockArticle.markArticleLiked('g', liked: true)).called(1);

      await appState.markArticleStarred('g');
      verify(() => mockArticle.markArticleStarred('g', starred: true)).called(1);

      await appState.recordArticleProgress('g', 0.5, 1);
      verify(() => mockArticle.recordArticleProgress('g', 0.5, 1)).called(1);

      await appState.getStarredArticles();
      verify(() => mockArticle.getStarredArticles()).called(1);

      await appState.login('e', 'p');
      verify(() => mockAuth.login('e', 'p')).called(1);

      await appState.logout();
      verify(() => mockAuth.logout()).called(1);

      await appState.setThemeMode(ThemeMode.light);
      verify(() => mockSettings.setThemeMode(ThemeMode.light)).called(1);

      await appState.setLocale('fr');
      verify(() => mockSettings.setLocale('fr')).called(1);

      await appState.setSpeechRate(2.0);
      verify(() => mockSettings.setSpeechRate(2.0)).called(1);

      await appState.setVoiceId('v2');
      verify(() => mockSettings.setVoiceId('v2')).called(1);

      await appState.setAutoPlayNext(false);
      verify(() => mockSettings.setAutoPlayNext(false)).called(1);

      await appState.setTextScaleFactor(1.1);
      verify(() => mockSettings.setTextScaleFactor(1.1)).called(1);

      await appState.setAutoMarkReadEnabled(true);
      verify(() => mockSettings.setAutoMarkReadEnabled(true)).called(1);

      await appState.setAutoMarkReadThreshold(80);
      verify(() => mockSettings.setAutoMarkReadThreshold(80)).called(1);

      await appState.syncState();
      verify(() => mockSync.syncState(mockAuth)).called(1);
    });

    test('getArticleState delegates to article provider', () {
      when(() => mockArticle.getArticleState('guid-1'))
          .thenReturn(UserArticleState(articleGuid: 'guid-1', readAt: 100));

      final result = appState.getArticleState('guid-1');

      expect(result, isNotNull);
      expect(result!.articleGuid, 'guid-1');
      expect(result.readAt, 100);
    });

    test('init sets isInitialized to true', () async {
      when(() => mockAuth.load()).thenAnswer((_) async {});
      when(() => mockSettings.load()).thenAnswer((_) async {});
      when(() => mockArticle.loadArticleStateCache()).thenAnswer((_) async {});
      when(() => mockFeed.loadFeeds()).thenAnswer((_) async {});

      expect(appState.isInitialized, isFalse);

      await appState.init();

      expect(appState.isInitialized, isTrue);
    });

    test('static constants are accessible', () {
      expect(AppState.speechRateBase, 0.5);
      expect(AppState.speechRateMinRatio, 0.5);
      expect(AppState.speechRateMaxRatio, 4.0);
      expect(AppState.textScaleMin, 0.9);
      expect(AppState.textScaleMax, 1.4);
    });

    test('dispose does not throw', () {
      expect(() => appState.dispose(), returnsNormally);
    });

    test('userEmail delegates to auth provider', () {
      when(() => mockAuth.userEmail).thenReturn('user@example.com');

      expect(appState.userEmail, 'user@example.com');
    });

    test('speechRateTts delegates to settings provider', () {
      when(() => mockSettings.speechRateTts).thenReturn(0.75);

      expect(appState.speechRateTts, 0.75);
    });

    test('_seedMockDataIfEmpty handles feed fetch errors gracefully', () async {
      when(() => mockAuth.load()).thenAnswer((_) async {});
      when(() => mockSettings.load()).thenAnswer((_) async {});
      when(() => mockArticle.loadArticleStateCache()).thenAnswer((_) async {});
      when(() => mockFeed.loadFeeds()).thenAnswer((_) async {});

      when(() => mockDb.getFeeds()).thenAnswer((_) async => []);

      when(() => mockFeedService.fetchFeedMetadata(any()))
          .thenThrow(Exception('Network error'));
      when(() => mockFeedService.fetchArticles(any()))
          .thenAnswer((_) async => []);

      // Should not throw despite fetchFeedMetadata failing.
      await appState.init();
    });

    test('_seedMockDataIfEmpty seeds debug feeds when DB is empty', () async {
      when(() => mockAuth.load()).thenAnswer((_) async {});
      when(() => mockSettings.load()).thenAnswer((_) async {});
      when(() => mockArticle.loadArticleStateCache()).thenAnswer((_) async {});
      when(() => mockFeed.loadFeeds()).thenAnswer((_) async {});

      when(() => mockDb.getFeeds()).thenAnswer((_) async => []);

      when(() => mockFeedService.fetchFeedMetadata(any())).thenAnswer(
        (_) async => Feed(url: 'https://debug.example.com', title: 'Debug Feed'),
      );
      when(() => mockFeedService.fetchArticles(any())).thenAnswer(
        (_) async => [Article(feedId: 0, guid: 'debug-article-1', title: 'Debug Article')],
      );
      when(() => mockDb.insertFeed(any())).thenAnswer((_) async => 42);
      when(() => mockDb.insertArticle(any())).thenAnswer((_) async => 1);

      await appState.init();

      verify(() => mockFeedService.fetchFeedMetadata(any())).called(greaterThan(0));
      verify(() => mockDb.insertFeed(any())).called(greaterThan(0));
      verify(() => mockDb.insertArticle(any())).called(greaterThan(0));
    });
  });
}
