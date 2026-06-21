import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aware/models/article.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/models/folder.dart';
import 'package:aware/models/user_article_state.dart';
import 'package:aware/services/database_service.dart';

void main() {
  late DatabaseService db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    db = DatabaseService();
  });

  group('DatabaseService - Feeds', () {
    test('insertFeed and getFeeds round-trip', () async {
      final feed = Feed(
        url: 'https://example.com/feed.xml',
        title: 'Test Feed',
        description: 'A test feed',
        category: 'tech',
      );
      final id = await db.insertFeed(feed);
      expect(id, greaterThan(0));

      final feeds = await db.getFeeds();
      expect(feeds.length, greaterThan(0));
      final saved = feeds.firstWhere((f) => f.id == id);
      expect(saved.title, 'Test Feed');
      expect(saved.url, 'https://example.com/feed.xml');
      expect(saved.category, 'tech');
    });

    test('setFeedPaused toggles paused state', () async {
      final id = await db.insertFeed(Feed(url: 'https://example.com/paused-test.xml'));
      await db.setFeedPaused(id, true);

      final feeds = await db.getFeeds();
      final feed = feeds.firstWhere((f) => f.id == id);
      expect(feed.paused, isTrue);

      await db.setFeedPaused(id, false);
      final reloaded = (await db.getFeeds()).firstWhere((f) => f.id == id);
      expect(reloaded.paused, isFalse);
    });

    test('deleteFeed removes feed and cascades', () async {
      final feedId = await db.insertFeed(Feed(url: 'https://example.com/delete-test.xml'));
      await db.insertArticle(Article(
        feedId: feedId,
        guid: 'delete-test-guid',
        title: 'To delete',
      ));

      await db.deleteFeed(feedId);

      final feeds = await db.getFeeds();
      expect(feeds.any((f) => f.id == feedId), isFalse);
    });
  });

  group('DatabaseService - Articles', () {
    late int feedId;

    setUp(() async {
      feedId = await db.insertFeed(Feed(url: 'https://example.com/article-test.xml'));
    });

    test('insertArticle and getArticlesForFeed round-trip', () async {
      await db.insertArticle(Article(
        feedId: feedId,
        guid: 'article-1',
        title: 'First Article',
        publishedAt: 1000,
      ));
      await db.insertArticle(Article(
        feedId: feedId,
        guid: 'article-2',
        title: 'Second Article',
        publishedAt: 2000,
      ));

      final articles = await db.getArticlesForFeed(feedId);
      expect(articles.length, 2);
    });

    test('getArticlesPaginated returns correct page', () async {
      for (int i = 0; i < 10; i++) {
        await db.insertArticle(Article(
          feedId: feedId,
          guid: 'page-guid-$i',
          title: 'Article $i',
          publishedAt: i * 1000,
        ));
      }

      final page1 = await db.getArticlesPaginated(limit: 3, offset: 0);
      expect(page1.length, 3);

      final page2 = await db.getArticlesPaginated(limit: 3, offset: 3);
      expect(page2.length, 3);
      expect(page2.first.guid, 'page-guid-6');
    });

    test('getArticlesCount returns correct count', () async {
      final count = await db.getArticlesCount(feedId: feedId);
      expect(count, 0);

      await db.insertArticle(Article(feedId: feedId, guid: 'count-test', title: 'Count'));
      final updated = await db.getArticlesCount(feedId: feedId);
      expect(updated, 1);
    });
  });

  group('DatabaseService - User State', () {
    test('insertUserState and getUserState round-trip', () async {
      final state = UserArticleState(
        articleGuid: 'state-guid-1',
        readAt: 1000,
        likedAt: 2000,
        starredAt: null,
        tags: 'test,example',
      );
      await db.insertUserState(state);

      final loaded = await db.getUserState('state-guid-1');
      expect(loaded, isNotNull);
      expect(loaded!.readAt, 1000);
      expect(loaded.likedAt, 2000);
      expect(loaded.starredAt, isNull);
      expect(loaded.tags, 'test,example');
    });

    test('insertUserState replaces existing', () async {
      await db.insertUserState(UserArticleState(
        articleGuid: 'replace-test',
        readAt: 100,
      ));
      await db.insertUserState(UserArticleState(
        articleGuid: 'replace-test',
        readAt: 200,
      ));

      final loaded = await db.getUserState('replace-test');
      expect(loaded!.readAt, 200);
    });
  });

  group('DatabaseService - Folders', () {
    test('insertFolder and getFolders round-trip', () async {
      final id = await db.insertFolder(Folder(name: 'Test Folder'));
      expect(id, greaterThan(0));

      final folders = await db.getFolders();
      expect(folders.any((f) => f.id == id), isTrue);
      expect(folders.firstWhere((f) => f.id == id).name, 'Test Folder');
    });

    test('renameFolder updates name', () async {
      final id = await db.insertFolder(Folder(name: 'Old Name'));
      await db.renameFolder(id, 'New Name');

      final folders = await db.getFolders();
      expect(folders.firstWhere((f) => f.id == id).name, 'New Name');
    });

    test('assignFeedToFolder and getFeedIdsInFolder', () async {
      final folderId = await db.insertFolder(Folder(name: 'Folder A'));
      final feed1 = await db.insertFeed(Feed(url: 'https://example.com/f1.xml'));
      final feed2 = await db.insertFeed(Feed(url: 'https://example.com/f2.xml'));

      await db.assignFeedToFolder(feed1, folderId);
      await db.assignFeedToFolder(feed2, folderId);

      final ids = await db.getFeedIdsInFolder(folderId);
      expect(ids, containsAll([feed1, feed2]));
    });

    test('deleteFolder removes folder and assignments', () async {
      final folderId = await db.insertFolder(Folder(name: 'To Delete'));
      final feedId = await db.insertFeed(Feed(url: 'https://example.com/delete-folder.xml'));
      await db.assignFeedToFolder(feedId, folderId);

      await db.deleteFolder(folderId);

      final folders = await db.getFolders();
      expect(folders.any((f) => f.id == folderId), isFalse);
    });
  });
}
