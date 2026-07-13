import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aware/models/article.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/services/background_feed_worker.dart';
import 'package:aware/services/database_service.dart';
import 'package:aware/services/feed_service.dart';

class MockFeedService extends Mock implements FeedService {}

void main() {
  late DatabaseService db;
  late MockFeedService mockFeedService;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.resetForTesting();
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    db = DatabaseService();
    mockFeedService = MockFeedService();
    when(() => mockFeedService.fetchArticles(any())).thenAnswer((_) async => []);
  });

  group('BackgroundFeedWorker', () {
    test('no-ops when no active feeds', () async {
      final worker = BackgroundFeedWorker(
        db: db,
        feedService: mockFeedService,
      );
      await worker.run();
    });

    test('no-ops when all feeds are paused', () async {
      await db.insertFeed(Feed(
        url: 'https://example.com/paused.xml',
        paused: true,
      ));

      final worker = BackgroundFeedWorker(
        db: db,
        feedService: mockFeedService,
      );
      await worker.run();

      verifyNever(() => mockFeedService.fetchArticles('https://example.com/paused.xml'));
    });

    test('fetches and stores articles for active feeds', () async {
      await db.insertFeed(Feed(
        url: 'https://example.com/active.xml',
        title: 'Active Feed',
      ));

      when(() => mockFeedService.fetchArticles('https://example.com/active.xml'))
          .thenAnswer((_) async => [
                Article(
                  feedId: 0,
                  guid: 'new-guid-1',
                  title: 'New Article',
                ),
              ]);

      final worker = BackgroundFeedWorker(
        db: db,
        feedService: mockFeedService,
      );
      await worker.run();

      final guids = await db.getAllArticleGuids();
      expect(guids, contains('new-guid-1'));
    });

    test('skips articles with existing GUIDs', () async {
      await db.insertFeed(Feed(
        url: 'https://example.com/dedup.xml',
        title: 'Dedup Feed',
      ));
      await db.insertArticle(Article(
        feedId: 0,
        guid: 'existing-guid',
        title: 'Existing',
      ));

      when(() => mockFeedService.fetchArticles('https://example.com/dedup.xml'))
          .thenAnswer((_) async => [
                Article(
                  feedId: 0,
                  guid: 'existing-guid',
                  title: 'Existing',
                ),
                Article(
                  feedId: 0,
                  guid: 'new-guid',
                  title: 'New',
                ),
              ]);

      final worker = BackgroundFeedWorker(
        db: db,
        feedService: mockFeedService,
      );
      await worker.run();

      final guids = await db.getAllArticleGuids();
      expect(guids, contains('existing-guid'));
      expect(guids, contains('new-guid'));
    });

    test('isolates per-feed errors', () async {
      await db.insertFeed(Feed(
        url: 'https://example.com/good.xml',
        title: 'Good Feed',
      ));
      await db.insertFeed(Feed(
        url: 'https://example.com/bad.xml',
        title: 'Bad Feed',
      ));

      when(() => mockFeedService.fetchArticles('https://example.com/good.xml'))
          .thenAnswer((_) async => [
                Article(feedId: 0, guid: 'good-guid', title: 'Good'),
              ]);
      when(() => mockFeedService.fetchArticles('https://example.com/bad.xml'))
          .thenThrow(Exception('Network error'));

      final worker = BackgroundFeedWorker(
        db: db,
        feedService: mockFeedService,
      );
      await worker.run();

      final guids = await db.getAllArticleGuids();
      expect(guids, contains('good-guid'));
    });

    test('schedulePeriodicRefresh does not throw', () async {
      // On non-Android/iOS platforms, this only creates a foreground timer.
      await BackgroundFeedWorker.schedulePeriodicRefresh();
    });

    test('schedulePeriodicRefresh can be called multiple times', () async {
      await BackgroundFeedWorker.schedulePeriodicRefresh();
      // Second call cancels the previous timer and creates a new one.
      await BackgroundFeedWorker.schedulePeriodicRefresh();
    });

    test('kFeedRefreshTask constant is accessible', () {
      expect(kFeedRefreshTask, 'feed_refresh_task');
    });
  });
}
