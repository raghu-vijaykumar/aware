import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/models/article.dart';
import 'package:aware/models/user_article_state.dart';
import 'package:aware/providers/article_provider.dart';
import 'package:aware/services/database_service.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockDatabaseService mockDb;
  late ArticleProvider provider;

  setUpAll(() {
    registerFallbackValue(UserArticleState(articleGuid: ''));
    registerFallbackValue(const <Article>[]);
    registerFallbackValue(0);
  });

  setUp(() {
    mockDb = MockDatabaseService();
    provider = ArticleProvider(db: mockDb);
  });

  group('ArticleProvider', () {
    test('loadArticleStateCache loads states from DB', () async {
      final states = [
        UserArticleState(articleGuid: 'guid-1', readAt: 1000),
        UserArticleState(articleGuid: 'guid-2', starredAt: 2000),
      ];
      when(() => mockDb.getAllUserState()).thenAnswer((_) async => states);

      await provider.loadArticleStateCache();

      expect(provider.getArticleState('guid-1')?.readAt, 1000);
      expect(provider.getArticleState('guid-2')?.starredAt, 2000);
      expect(provider.getArticleState('missing'), isNull);
    });

    test('markArticleRead updates cache and notifies', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.markArticleRead('guid-1', read: true);

      final state = provider.getArticleState('guid-1');
      expect(state?.readAt, isNotNull);
      expect(state?.articleGuid, 'guid-1');
      expect(notifyCount, 1);
    });

    test('markArticleRead preserves existing likedAt and starredAt', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      // First mark as liked
      await provider.markArticleLiked('guid-1', liked: true);
      // Then mark as read — should preserve likedAt
      await provider.markArticleRead('guid-1', read: true);

      final state = provider.getArticleState('guid-1');
      expect(state?.likedAt, isNotNull);
      expect(state?.readAt, isNotNull);
    });

    test('markArticleRead with read=false clears readAt', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      await provider.markArticleRead('guid-1', read: true);
      await provider.markArticleRead('guid-1', read: false);

      final state = provider.getArticleState('guid-1');
      expect(state?.readAt, isNull);
    });

    test('markArticleLiked updates cache and notifies', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.markArticleLiked('guid-1', liked: true);

      final state = provider.getArticleState('guid-1');
      expect(state?.likedAt, isNotNull);
      expect(notifyCount, 1);
    });

    test('markArticleStarred updates cache and notifies', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.markArticleStarred('guid-1', starred: true);

      final state = provider.getArticleState('guid-1');
      expect(state?.starredAt, isNotNull);
      expect(notifyCount, 1);
    });

    test('recordArticleProgress updates lastAccessedAt and progress', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);

      await provider.recordArticleProgress('guid-1', 0.5, 3);

      final state = provider.getArticleState('guid-1');
      expect(state?.readProgress, 0.5);
      expect(state?.lastParagraphIndex, 3);
      expect(state?.lastAccessedAt, isNotNull);
    });

    test('getArticlesForFeed delegates to DB', () async {
      when(() => mockDb.getArticlesForFeed(1)).thenAnswer((_) async => []);
      when(() => mockDb.getArticlesForFeed(2)).thenAnswer((_) async => [
            Article(feedId: 0, guid: 'test-guid', title: 'Test'),
          ]);

      final result1 = await provider.getArticlesForFeed(1);
      expect(result1, isEmpty);

      final result2 = await provider.getArticlesForFeed(2);
      expect(result2.length, 1);
      verify(() => mockDb.getArticlesForFeed(1)).called(1);
      verify(() => mockDb.getArticlesForFeed(2)).called(1);
    });

    test('getArticlesPaginated delegates to DB', () async {
      when(() => mockDb.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => <Article>[Article(feedId: 0, guid: 'pag-guid', title: 'P')]);

      final result = await provider.getArticlesPaginated();
      expect(result.length, 1);
      verify(() => mockDb.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).called(1);
    });

    test('getArticlesCount delegates to DB', () async {
      when(() => mockDb.getArticlesCount(
        feedId: any(named: 'feedId'),
      )).thenAnswer((_) async => 42);

      final result = await provider.getArticlesCount();
      expect(result, 42);
      verify(() => mockDb.getArticlesCount(
        feedId: any(named: 'feedId'),
      )).called(1);
    });

    test('getAllArticles delegates to DB', () async {
      when(() => mockDb.getAllArticles()).thenAnswer((_) async => [
            Article(feedId: 0, guid: 'all-guid', title: 'All'),
          ]);

      final result = await provider.getAllArticles();
      expect(result.length, 1);
      verify(() => mockDb.getAllArticles()).called(1);
    });

    test('markArticleLiked preserves existing readAt from cache', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      await provider.markArticleRead('guid-1', read: true);

      await provider.markArticleLiked('guid-1', liked: true);

      final state = provider.getArticleState('guid-1');
      expect(state?.likedAt, isNotNull);
      expect(state?.readAt, isNotNull);
    });

    test('markArticleStarred preserves existing readAt and likedAt from cache', () async {
      when(() => mockDb.insertUserState(any())).thenAnswer((_) async => 1);
      await provider.markArticleRead('guid-1', read: true);
      await provider.markArticleLiked('guid-1', liked: true);

      await provider.markArticleStarred('guid-1', starred: true);

      final state = provider.getArticleState('guid-1');
      expect(state?.readAt, isNotNull);
      expect(state?.likedAt, isNotNull);
      expect(state?.starredAt, isNotNull);
    });

    test('getStarredArticles delegates to DB', () async {
      when(() => mockDb.getStarredArticles()).thenAnswer((_) async => []);

      final result = await provider.getStarredArticles();

      expect(result, isEmpty);
      verify(() => mockDb.getStarredArticles()).called(1);
    });
  });
}
