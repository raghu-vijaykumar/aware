import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aware/models/article.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/models/user_article_state.dart';
import 'package:aware/services/database_service.dart';

void main() {
  late DatabaseService db;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.resetForTesting();
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

    test('getArticlesCount without feedId returns total', () async {
      await db.insertArticle(Article(feedId: feedId, guid: 'total-count-a', title: 'A'));
      await db.insertArticle(Article(feedId: feedId, guid: 'total-count-b', title: 'B'));
      final count = await db.getArticlesCount();
      expect(count, greaterThanOrEqualTo(2));
    });

    test('getAllArticles returns articles across feeds', () async {
      final feed2Id = await db.insertFeed(Feed(url: 'https://example.com/feed2.xml'));
      await db.insertArticle(Article(feedId: feedId, guid: 'all-a', title: 'Feed1 Article'));
      await db.insertArticle(Article(feedId: feed2Id, guid: 'all-b', title: 'Feed2 Article'));

      final all = await db.getAllArticles();
      expect(all.any((a) => a.title == 'Feed1 Article'), isTrue);
      expect(all.any((a) => a.title == 'Feed2 Article'), isTrue);
    });

    test('getAllArticleGuids returns unique GUIDs', () async {
      await db.insertArticle(Article(feedId: feedId, guid: 'guid-x', title: 'X'));
      await db.insertArticle(Article(feedId: feedId, guid: 'guid-y', title: 'Y'));

      final guids = await db.getAllArticleGuids();
      expect(guids, contains('guid-x'));
      expect(guids, contains('guid-y'));
    });

    test('updateArticleContent updates content only', () async {
      await db.insertArticle(Article(feedId: feedId, guid: 'update-c', title: 'Update Me', content: 'old'));
      await db.updateArticleContent('update-c', content: 'new content');

      final articles = await db.getArticlesForFeed(feedId);
      final updated = articles.firstWhere((a) => a.guid == 'update-c');
      expect(updated.content, 'new content');
    });

    test('updateArticleContent updates rawData only', () async {
      await db.insertArticle(Article(feedId: feedId, guid: 'update-rd', title: 'Raw', content: 'c'));
      await db.updateArticleContent('update-rd', rawData: 'raw data');

      final articles = await db.getArticlesForFeed(feedId);
      final updated = articles.firstWhere((a) => a.guid == 'update-rd');
      expect(updated.rawData, 'raw data');
    });

    test('updateArticleContent no-ops when no values provided', () async {
      await db.insertArticle(Article(feedId: feedId, guid: 'update-noop', title: 'Noop', content: 'keep'));
      await db.updateArticleContent('update-noop');

      final articles = await db.getArticlesForFeed(feedId);
      final updated = articles.firstWhere((a) => a.guid == 'update-noop');
      expect(updated.content, 'keep');
    });
  });

  group('DatabaseService - User State', () {
    late int userStateFeedId;

    setUp(() async {
      userStateFeedId = await db.insertFeed(Feed(url: 'https://example.com/user-state-feed.xml'));
    });

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

    test('getAllUserState returns all states', () async {
      await db.insertUserState(UserArticleState(articleGuid: 'us-all-1', readAt: 1));
      await db.insertUserState(UserArticleState(articleGuid: 'us-all-2', readAt: 2));

      final all = await db.getAllUserState();
      expect(all.any((s) => s.articleGuid == 'us-all-1'), isTrue);
      expect(all.any((s) => s.articleGuid == 'us-all-2'), isTrue);
    });

    test('getStarredArticleGuids returns starred GUIDs only', () async {
      await db.insertUserState(UserArticleState(articleGuid: 'star-a', starredAt: 100));
      await db.insertUserState(UserArticleState(articleGuid: 'star-b', starredAt: null));
      await db.insertUserState(UserArticleState(articleGuid: 'star-c', starredAt: 200));

      final starred = await db.getStarredArticleGuids();
      expect(starred, contains('star-a'));
      expect(starred, contains('star-c'));
      expect(starred, isNot(contains('star-b')));
    });

    test('getReadArticleGuids returns read GUIDs only', () async {
      await db.insertUserState(UserArticleState(articleGuid: 'read-a', readAt: 100));
      await db.insertUserState(UserArticleState(articleGuid: 'read-b', readAt: null));
      await db.insertUserState(UserArticleState(articleGuid: 'read-c', readAt: 200));

      final read = await db.getReadArticleGuids();
      expect(read, contains('read-a'));
      expect(read, contains('read-c'));
      expect(read, isNot(contains('read-b')));
    });

    test('getStarredArticles returns starred articles with JOIN', () async {
      await db.insertArticle(Article(feedId: userStateFeedId, guid: 'star-join-a', title: 'Star Join A'));
      await db.insertArticle(Article(feedId: userStateFeedId, guid: 'star-join-b', title: 'Star Join B'));
      await db.insertUserState(UserArticleState(articleGuid: 'star-join-a', starredAt: 300));
      await db.insertUserState(UserArticleState(articleGuid: 'star-join-b', starredAt: null));

      final articles = await db.getStarredArticles();
      expect(articles.any((a) => a.guid == 'star-join-a'), isTrue);
      expect(articles.any((a) => a.guid == 'star-join-b'), isFalse);
    });
  });

  group('DatabaseService - Migration', () {
    /// Repeatedly close the singleton and delete the DB file until it is
    /// actually gone.  sqflite_ffi's isolate may cache the connection across
    /// test files, and Windows file-locks can delay release.
    Future<void> _ensureDbGone() async {
      await DatabaseService.resetForTesting();
      final path = join(await getDatabasesPath(), 'aware.db');
      for (int attempt = 0; attempt < 10; attempt++) {
        // Tell every layer to release the file.
        try {
          await databaseFactory.deleteDatabase(path);
        } catch (_) {}
        try {
          await deleteDatabase(path);
        } catch (_) {}
        // Also nuke journal files that may hold a reference on Windows.
        for (final ext in ['', '-wal', '-shm', '-journal']) {
          final f = File('$path$ext');
          try {
            if (await f.exists()) {
              await f.delete();
            }
          } catch (_) {}
        }
        if (!await File(path).exists()) return;
        // Give the OS / FFI isolate time to release the handle.
        await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
      }
      throw Exception(
        'Could not delete $path after 10 attempts. '
        'Another test may have left the DB open.',
      );
    }

    Future<void> _replaceDbFile(String path) async {
      // Close everything first
      await DatabaseService.resetForTesting();
      await _ensureDbGone();
    }

    test('onUpgrade from version 1 adds all columns', () async {
      await _ensureDbGone();

      // Create DB at version 1 with minimal schema (missing category, curator,
      // paused on feeds; missing liked_at, last_accessed_at on user_article_state)
      final path = join(await getDatabasesPath(), 'aware.db');
      var db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
            await db.execute(
                'CREATE TABLE feeds (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT UNIQUE NOT NULL, title TEXT, description TEXT, site_url TEXT, icon_url TEXT, last_fetched INTEGER, etag TEXT, last_modified TEXT)');
            await db.execute(
                'CREATE TABLE articles (id INTEGER PRIMARY KEY AUTOINCREMENT, feed_id INTEGER REFERENCES feeds(id), guid TEXT UNIQUE NOT NULL, url TEXT, title TEXT, summary TEXT, content TEXT, author TEXT, published_at INTEGER, fetched_at INTEGER, image_url TEXT, raw_data TEXT)');
            await db.execute(
                'CREATE TABLE user_article_state (id INTEGER PRIMARY KEY AUTOINCREMENT, article_guid TEXT UNIQUE NOT NULL, read_at INTEGER, starred_at INTEGER, tags TEXT)');
          },
      );
      await db.close();

      // DatabaseService opens the version-1 DB and triggers onUpgrade(1 → 5)
      final database = await DatabaseService().database;

      // Verify v2 columns were added to feeds
      var feedColumns =
          await database.rawQuery('PRAGMA table_info(feeds)');
      var feedNames = feedColumns.map((c) => c['name'] as String).toSet();
      expect(feedNames, contains('category'));
      expect(feedNames, contains('curator'));
      expect(feedNames, contains('paused'));

      // Verify v3 + v5 columns were added to user_article_state
      var stateColumns =
          await database.rawQuery('PRAGMA table_info(user_article_state)');
      var stateNames = stateColumns.map((c) => c['name'] as String).toSet();
      expect(stateNames, contains('liked_at'));
      expect(stateNames, contains('last_accessed_at'));
      expect(stateNames, contains('read_progress'));
      expect(stateNames, contains('last_paragraph_index'));

      await DatabaseService.resetForTesting();
    });

    test('onOpen adds missing columns defensively', () async {
      await _ensureDbGone();

      // Create DB at version 5 but with user_article_state missing liked_at,
      // last_accessed_at, read_progress, last_paragraph_index
      final path = join(await getDatabasesPath(), 'aware.db');
      var db = await openDatabase(
        path,
        version: 5,
        onCreate: (db, version) async {
            await db.execute(
                'CREATE TABLE feeds (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT UNIQUE NOT NULL, title TEXT, description TEXT, site_url TEXT, icon_url TEXT, category TEXT, curator TEXT, paused INTEGER DEFAULT 0, last_fetched INTEGER, etag TEXT, last_modified TEXT)');
            await db.execute(
                'CREATE TABLE articles (id INTEGER PRIMARY KEY AUTOINCREMENT, feed_id INTEGER REFERENCES feeds(id), guid TEXT UNIQUE NOT NULL, url TEXT, title TEXT, summary TEXT, content TEXT, author TEXT, published_at INTEGER, fetched_at INTEGER, image_url TEXT, raw_data TEXT)');
            // user_article_state is deliberately missing several columns
            await db.execute(
                'CREATE TABLE user_article_state (id INTEGER PRIMARY KEY AUTOINCREMENT, article_guid TEXT UNIQUE NOT NULL, read_at INTEGER, starred_at INTEGER, tags TEXT)');
          },
      );
      await db.close();

      // DatabaseService opens it; _onOpen should add the missing columns
      final database = await DatabaseService().database;

      var stateColumns =
          await database.rawQuery('PRAGMA table_info(user_article_state)');
      var stateNames = stateColumns.map((c) => c['name'] as String).toSet();
      expect(stateNames, contains('liked_at'));
      expect(stateNames, contains('last_accessed_at'));
      expect(stateNames, contains('read_progress'));
      expect(stateNames, contains('last_paragraph_index'));

      await DatabaseService.resetForTesting();
    });
  });
}
