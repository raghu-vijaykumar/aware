import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/models/article.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/models/user_article_state.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/article_list_screen.dart';

class MockAppState extends Mock implements AppState {}

Widget createTestWidget(AppState appState) {
  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: ArticleListScreen(allFeeds: true, feedTitle: 'All Feeds'),
      ),
    ),
  );
}

void main() {
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.getArticleState(any())).thenReturn(null);
    when(() => mockAppState.feeds).thenReturn([]);
    when(() => mockAppState.autoMarkReadEnabled).thenReturn(false);
    when(() => mockAppState.autoMarkReadThreshold).thenReturn(50);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'share') {
          return '';
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      null,
    );
  });

  group('ArticleListScreen', () {
    testWidgets('shows empty state when no articles', (tester) async {
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 0);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('No articles yet'), findsOneWidget);
    });

    testWidgets('renders articles grouped by date', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Today Article',
          summary: 'A short summary',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Yesterday Article',
          summary: 'Another summary',
          publishedAt: now
              .subtract(const Duration(hours: 30))
              .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Today Article'), findsOneWidget);
      expect(find.text('Yesterday Article'), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
    });

    testWidgets('shows time labels', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Recent Article',
          summary: 'Recent',
          publishedAt: now
              .subtract(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Old Article',
          summary: 'Old',
          publishedAt: now
              .subtract(const Duration(days: 65))
              .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('m ago'), findsWidgets);
      expect(find.textContaining('mo ago'), findsWidgets);
    });

    testWidgets('shows years and no-date labels', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Ancient Article',
          summary: 'Ancient',
          publishedAt: now
              .subtract(const Duration(days: 730))
              .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'No Date Article',
          summary: 'No date',
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('y ago'), findsWidgets);
      expect(find.textContaining('Publish date unknown'), findsWidgets);
    });

    testWidgets('shows fetched label', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Today Article',
          summary: 'A short summary',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Fetched Article',
          summary: 'Fetched',
          fetchedAt: now
              .subtract(const Duration(minutes: 30))
              .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('fetched'), findsWidgets);
    });

    testWidgets('uses content field for word count', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Main Article',
          summary: '',
          content: 'This article has content in the content field with multiple words for word count testing',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Second Article',
          summary: 'Regular short summary',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Main Article'), findsOneWidget);
      expect(find.text('Second Article'), findsOneWidget);
    });

    testWidgets('shows feed title from matched feed', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Feed Article',
          summary: 'From a named feed',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Host Article',
          summary: 'From feed with empty title',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 2,
          url: 'https://example.com/2',
        ),
        Article(
          guid: '3',
          title: 'Url Fallback Article',
          summary: 'From feed with empty title and no host',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 3,
          url: 'https://example.com/3',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([
        Feed(id: 1, title: 'Explicit Title', url: 'https://example.com/feed.xml'),
        Feed(id: 2, title: '', url: 'https://host.example.com/feed.xml'),
        Feed(id: 3, title: '', url: 'http://'),
      ]);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Explicit Title'), findsOneWidget);
      expect(find.text('host.example.com'), findsOneWidget);
      expect(find.text('http://'), findsOneWidget);
    });

    testWidgets('source filter hides non-matching articles', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Feed One Article',
          summary: 'From feed one',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Feed Two Article',
          summary: 'From feed two',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 2,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([
        Feed(id: 1, title: 'Alpha', url: 'https://example.com/alpha.xml'),
        Feed(id: 2, title: 'Beta', url: 'https://example.com/beta.xml'),
      ]);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Feed One Article'), findsOneWidget);
      expect(find.text('Feed Two Article'), findsOneWidget);

      // Open drawer and tap the "Alpha" source chip
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.text('Alpha'),
      ));
      await tester.pumpAndSettle();

      // Close drawer — filter applies showing only Alpha articles
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Feed One Article'), findsOneWidget);
      expect(find.text('Feed Two Article'), findsNothing);
    });

    testWidgets('filter drawer unread-only filter works', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Read Article',
          summary: 'Read one',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Unread Article',
          summary: 'Unread one',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);
      when(() => mockAppState.getArticleState('1'))
          .thenReturn(UserArticleState(articleGuid: '1', readAt: 1000));
      when(() => mockAppState.getArticleState('2'))
          .thenReturn(UserArticleState(articleGuid: '2'));

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Both articles visible initially
      expect(find.text('Read Article'), findsOneWidget);
      expect(find.text('Unread Article'), findsOneWidget);

      // Open drawer
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Tap "Unread only" chip
      await tester.tap(find.text('Unread only'));
      await tester.pumpAndSettle();

      // Close drawer
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Only unread article should remain visible
      expect(find.text('Read Article'), findsNothing);
      expect(find.text('Unread Article'), findsOneWidget);
    });

    testWidgets('filter drawer chip interactions', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Article One',
          summary: 'A short summary',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Open drawer
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap drawer-only chips
      await tester.tap(find.text('Any'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Short <100w'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Medium 100-300'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Long >300'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2+ paragraphs'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Last 7d'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Last 30d'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All sources'));
      await tester.pumpAndSettle();

      // Tap drawer-specific chips using ancestor finder
      await tester.tap(find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.text('Liked'),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.text('Saved'),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.text('Last 24h'),
      ));
      await tester.pumpAndSettle();

      // Tap "All" chips inside drawer (engagement then time)
      final allChipsInDrawer = find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.text('All'),
      );
      await tester.tap(allChipsInDrawer.at(0));
      await tester.pumpAndSettle();

      await tester.tap(allChipsInDrawer.at(1));
      await tester.pumpAndSettle();

      // Tap individual source chip (covers line 1116-1117)
      await tester.tap(find.descendant(
        of: find.byType(StatefulBuilder),
        matching: find.text('Unknown'),
      ));
      await tester.pumpAndSettle();

      // Reset clears all filters
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Close with X button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsNothing);
    });

    testWidgets('shows weeks-ago label', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Recent Article',
          summary: 'Recent',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Week Old Article',
          summary: 'A week or two old',
          publishedAt: now
              .subtract(const Duration(days: 14))
              .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('w ago'), findsWidgets);
    });

    testWidgets('filter drawer keyword input', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Test Article',
          summary: 'Test summary',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Enter keyword and verify filtering
      await tester.enterText(find.byType(TextField).last, 'test');
      await tester.pumpAndSettle();

      // Verify article count text reflects filter
      expect(find.text('1 articles found'), findsOneWidget);

      // Close
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('shows continue reading FAB for partial progress', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Partial Article',
          summary: 'In progress',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
        Article(
          guid: '2',
          title: 'Unread Article',
          summary: 'Not started',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/2',
        ),
      ];

      // Article 1 has readProgress > 0 (partial reading), no readAt (unread)
      when(() => mockAppState.getArticleState(any())).thenReturn(null);
      when(() => mockAppState.getArticleState('1')).thenReturn(
        UserArticleState(articleGuid: '1', readProgress: 0.5, lastAccessedAt: 100),
      );
      when(() => mockAppState.getArticleState('2')).thenReturn(
        UserArticleState(articleGuid: '2', lastAccessedAt: 200),
      );
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Continue Reading'), findsOneWidget);

      // Tap the FAB to trigger _launchCatchUpQueue
      await tester.tap(find.text('Continue Reading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('like button un-likes article when already liked', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Liked Article',
          summary: 'Already liked',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);
      when(() => mockAppState.getArticleState('1')).thenReturn(
        UserArticleState(articleGuid: '1', likedAt: 1000),
      );
      when(() => mockAppState.markArticleLiked(any(), liked: any(named: 'liked')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      verify(() => mockAppState.markArticleLiked('1', liked: false)).called(1);
    });

    testWidgets('star button un-saves article when already saved', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Saved Article',
          summary: 'Already saved',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);
      when(() => mockAppState.getArticleState('1')).thenReturn(
        UserArticleState(articleGuid: '1', starredAt: 1000),
      );
      when(() => mockAppState.markArticleStarred(any(), starred: any(named: 'starred')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pump();

      verify(() => mockAppState.markArticleStarred('1', starred: false)).called(1);
    });

    testWidgets('sticky date header shows unknown for no-timestamp article', (tester) async {
      final articles = [
        Article(
          guid: '1',
          title: 'No Date Article',
          summary: 'No date',
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Sticky header renders at top with "Publish date unknown"
      expect(find.textContaining('Publish date unknown'), findsAtLeast(1));
    });

    testWidgets('scroll tracking updates active date key', (tester) async {
      final now = DateTime.now();
      // Small articles in two date groups to test scroll tracking
      final articles = List.generate(
        20,
        (i) => Article(
          guid: '$i',
          title: i < 5 ? 'Today Article $i' : 'Older Article $i',
          publishedAt: i < 5
              ? now.millisecondsSinceEpoch
              : now
                  .subtract(const Duration(days: 2))
                  .millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/$i',
        ),
      );

      when(() => mockAppState.getArticlesCount(
              feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll past the first date group in two drags with pumps in between
      // so items are re-laid-out before the next scroll listener fires
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      await tester.pump();
      // Second drag triggers _onScroll again, now with updated layout
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      await tester.pump();
      // Third drag pushes further into the second group
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      await tester.pump();

      expect(find.text('Today Article 0'), findsNothing);
    });

    testWidgets('tapping article card navigates to ReaderScreen', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Tappable Article',
          summary: 'Tap me',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Tappable Article'));
      await tester.pump();
      await tester.pump();

      // ReaderScreen shows article readback title — verify navigation happened
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('tapping share button calls SharePlus', (tester) async {
      final now = DateTime.now();
      final articles = [
        Article(
          guid: '1',
          title: 'Shareable Article',
          summary: 'Share me',
          publishedAt: now.millisecondsSinceEpoch,
          feedId: 1,
          url: 'https://example.com/1',
        ),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => articles.length);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => articles);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll to bottom of card to reveal share button
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();
    });
  });
}
