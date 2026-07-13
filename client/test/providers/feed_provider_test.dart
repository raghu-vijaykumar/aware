import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/models/feed.dart';
import 'package:aware/models/article.dart';
import 'package:aware/providers/feed_provider.dart';
import 'package:aware/services/database_service.dart';
import 'package:aware/services/feed_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockFeedService extends Mock implements FeedService {}

void main() {
  late MockDatabaseService mockDb;
  late MockFeedService mockFeedService;
  late FeedProvider provider;

  setUpAll(() {
    registerFallbackValue(Feed(url: ''));
    registerFallbackValue(Article(feedId: 0, guid: ''));
  });

  setUp(() {
    mockDb = MockDatabaseService();
    mockFeedService = MockFeedService();
    provider = FeedProvider(db: mockDb, feedService: mockFeedService);
  });

  group('FeedProvider', () {
    test('loadFeeds fetches from DB and notifies listeners', () async {
      final feeds = [Feed(url: 'https://example.com/rss')];
      when(() => mockDb.getFeeds()).thenAnswer((_) async => feeds);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadFeeds();

      expect(provider.feeds, feeds);
      expect(notifyCount, 1);
    });

    test('addFeedFromUrl throws for invalid URL', () async {
      expect(
        () => provider.addFeedFromUrl('not-a-url'),
        throwsArgumentError,
      );
    });

    test('addFeedFromUrl throws for unsupported scheme', () async {
      expect(
        () => provider.addFeedFromUrl('ftp://example.com/feed'),
        throwsArgumentError,
      );
    });

    test('addFeedFromUrl fetches metadata, articles, and reloads', () async {
      when(() => mockFeedService.fetchFeedMetadata('https://example.com/rss'))
          .thenAnswer((_) async => Feed(url: 'https://example.com/rss', title: 'My Feed'));
      when(() => mockDb.insertFeed(any())).thenAnswer((_) async => 42);
      when(() => mockFeedService.fetchArticles('https://example.com/rss'))
          .thenAnswer((_) async => [
                Article(feedId: 0, guid: 'a1', title: 'Article 1'),
              ]);
      when(() => mockDb.insertArticle(any())).thenAnswer((_) async => 0);
      when(() => mockDb.getFeeds()).thenAnswer((_) async => []);

      await provider.addFeedFromUrl('https://example.com/rss');

      verify(() => mockDb.insertFeed(any())).called(1);
      verify(() => mockFeedService.fetchArticles('https://example.com/rss')).called(1);
      verify(() => mockDb.insertArticle(any())).called(1);
    });

    test('deleteFeed deletes and reloads', () async {
      when(() => mockDb.deleteFeed(1)).thenAnswer((_) async => {});
      when(() => mockDb.getFeeds()).thenAnswer((_) async => []);

      await provider.deleteFeed(1);

      verify(() => mockDb.deleteFeed(1)).called(1);
      verify(() => mockDb.getFeeds()).called(1);
    });

    test('setFeedPaused toggles pause and reloads', () async {
      when(() => mockDb.setFeedPaused(1, true)).thenAnswer((_) async => {});
      when(() => mockDb.getFeeds()).thenAnswer((_) async => []);

      await provider.setFeedPaused(1, true);

      verify(() => mockDb.setFeedPaused(1, true)).called(1);
      verify(() => mockDb.getFeeds()).called(1);
    });
  });
}
