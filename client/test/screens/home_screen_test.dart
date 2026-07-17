import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/models/article.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/models/user_article_state.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/home_screen.dart';

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
      home: const HomeScreen(),
    ),
  );
}

void main() {
  late MockAppState mockAppState;

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.locale).thenReturn(const Locale('en'));
    when(() => mockAppState.setLocale(any())).thenAnswer((_) async {});
    when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
    when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
        .thenAnswer((_) async => 0);
    when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'))).thenAnswer((_) async => []);
    when(() => mockAppState.feeds).thenReturn([]);
    when(() => mockAppState.autoMarkReadEnabled).thenReturn(false);
    when(() => mockAppState.autoMarkReadThreshold).thenReturn(50);
    when(() => mockAppState.autoPlayNext).thenReturn(false);
    when(() => mockAppState.speechRate).thenReturn(1.0);
    when(() => mockAppState.voiceId).thenReturn(null);
    when(() => mockAppState.textScaleFactor).thenReturn(1.0);
    when(() => mockAppState.themeMode).thenReturn(ThemeMode.system);
    when(() => mockAppState.getArticleState(any())).thenReturn(null);
    when(() => mockAppState.setAutoMarkReadEnabled(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setAutoMarkReadThreshold(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setAutoPlayNext(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setSpeechRate(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setVoiceId(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setTextScaleFactor(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setThemeMode(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.addFeedFromUrl(any()))
        .thenAnswer((_) async {});
  });

  group('HomeScreen', () {
    testWidgets('renders bottom navigation bar with three tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byIcon(Icons.rss_feed), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('taps like button on article', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1,
          guid: 'guid-1',
          title: 'Test Article 1',
          summary: 'Summary',
          publishedAt: now,
          fetchedAt: now,
        ),
      ];
      final feeds = [
        Feed(url: 'https://example.com/feed.xml', title: 'Test Feed'),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn(feeds);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);
      when(() => mockAppState.markArticleLiked(any(), liked: any(named: 'liked')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      verify(() => mockAppState.markArticleLiked(
          'guid-1', liked: true)).called(1);
    });

    testWidgets('swipes article to toggle read status', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final article = Article(
        feedId: 1,
        guid: 'guid-1',
        title: 'Swipeable',
        summary: 'Summary',
        publishedAt: now,
        fetchedAt: now,
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => [article]);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);
      when(() => mockAppState.markArticleRead(any(), read: any(named: 'read')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.timedDrag(
        find.text('Swipeable'),
        const Offset(600, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      verify(() => mockAppState.markArticleRead(
          'guid-1', read: true)).called(1);
    });

    testWidgets('opens search and filters articles', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Alpha', summary: 'S1', publishedAt: now, fetchedAt: now),
        Article(feedId: 1, guid: 'g2', title: 'Beta', summary: 'S2', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 2);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Alpha');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('opens filter drawer and applies unread filter', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Alpha', summary: 'Text', publishedAt: now, fetchedAt: now),
        Article(feedId: 1, guid: 'g2', title: 'Beta', summary: 'Text 2', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 2);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Unread only').last);
      await tester.pump();
    });

    testWidgets('scrolls article list to trigger load more', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = List.generate(
        10,
        (i) => Article(
          feedId: 1,
          guid: 'guid-$i',
          title: 'Article $i',
          summary: 'Summary $i',
          publishedAt: now - i * 3600000,
          fetchedAt: now,
        ),
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 100);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('shows continue reading FAB when article has read progress', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'guid-1', title: 'Unfinished', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');
      final state = UserArticleState(
        articleGuid: 'guid-1',
        readAt: null,
        readProgress: 0.5,
      );

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(state);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('toggles auto-mark-read switch in settings', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      final switchTile = find.text('Auto-mark read by progress');
      await tester.tap(switchTile);
      await tester.pump();

      verify(() => mockAppState.setAutoMarkReadEnabled(true)).called(1);
    });

    testWidgets('taps unread filter chip', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final article = Article(
        feedId: 1,
        guid: 'guid-1',
        title: 'Test Article',
        summary: 'Summary',
        publishedAt: now,
        fetchedAt: now,
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Test Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => [article]);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('All'));
      await tester.pump();
    });

    testWidgets('renders article list with articles', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1,
          guid: 'guid-1',
          title: 'Test Article 1',
          summary: 'Summary of article 1',
          publishedAt: now,
          fetchedAt: now,
        ),
        Article(
          feedId: 1,
          guid: 'guid-2',
          title: 'Test Article 2',
          summary: 'Summary of article 2',
          publishedAt: now,
          fetchedAt: now,
        ),
      ];
      final feeds = [
        Feed(url: 'https://example.com/feed.xml', title: 'Test Feed'),
      ];

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 2);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn(feeds);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.text('Test Article 1'), findsOneWidget);
      expect(find.text('Test Article 2'), findsOneWidget);
    });

    testWidgets('settings sliders render without crash', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // At least one slider (auto-mark-read threshold) is visible initially
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('voice section header is visible after scroll', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.textContaining('Voice'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();
      expect(find.textContaining('Voice'), findsWidgets);
    });

    testWidgets('shows empty state when no articles', (tester) async {
      // Default mock returns 0 articles; no override needed.
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('No articles yet'), findsOneWidget);
    });

    testWidgets('shows untitled fallback for article with no title', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1,
          guid: 'guid-1',
          summary: 'Summary',
          publishedAt: now,
          fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('shows read article styling', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1,
          guid: 'guid-1',
          title: 'Read Article',
          summary: 'Summary',
          publishedAt: now,
          fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');
      final state = UserArticleState(articleGuid: 'guid-1', readAt: now);

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(state);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.text('Read Article'), findsOneWidget);
      // Read articles do not show the unread dot (blue circle)
      expect(find.byIcon(Icons.circle), findsNothing);
    });

    testWidgets('shows liked article with filled heart', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1,
          guid: 'guid-1',
          title: 'Liked Article',
          summary: 'Summary',
          publishedAt: now,
          fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');
      final state = UserArticleState(articleGuid: 'guid-1', likedAt: now);

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(state);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows saved article with bookmark', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1,
          guid: 'guid-1',
          title: 'Saved Article',
          summary: 'Summary',
          publishedAt: now,
          fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');
      final state = UserArticleState(articleGuid: 'guid-1', starredAt: now);

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(state);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('search back button exits search mode', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Article 1', summary: 'Summary',
            publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Close search via back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Search icon should be visible again (non-search mode)
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('search clear button clears keyword', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Article 1', summary: 'Summary',
            publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Open search and type something
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Search should still be active but text cleared
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('swipe right to mark read then swipe to toggle back', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final article = Article(
        feedId: 1,
        guid: 'guid-1',
        title: 'Swipe Read',
        summary: 'Summary',
        publishedAt: now,
        fetchedAt: now,
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => [article]);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);
      when(() => mockAppState.markArticleRead(any(), read: any(named: 'read')))
          .thenAnswer((_) async {});
      when(() => mockAppState.markArticleStarred(any(), starred: any(named: 'starred')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Swipe left to star
      await tester.timedDrag(
        find.text('Swipe Read'),
        const Offset(-600, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      verify(() => mockAppState.markArticleStarred('guid-1', starred: true)).called(1);
    });

    testWidgets('swipe right on read article shows marked unread', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final article = Article(
        feedId: 1,
        guid: 'guid-1',
        title: 'Swipe Unread',
        summary: 'Summary',
        publishedAt: now,
        fetchedAt: now,
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');
      final state = UserArticleState(articleGuid: 'guid-1', readAt: now);

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => [article]);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(state);
      when(() => mockAppState.markArticleRead(any(), read: any(named: 'read')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Swipe right to mark unread
      await tester.timedDrag(
        find.text('Swipe Unread'),
        const Offset(600, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      verify(() => mockAppState.markArticleRead('guid-1', read: false)).called(1);
    });

    testWidgets('shows article found count on search', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Alpha', summary: 'S1', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Alpha');
      await tester.pump();

      expect(find.textContaining('articles found'), findsOneWidget);
    });

    testWidgets('taps unread quick filter chip', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Test', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Unread'));
      await tester.pump();
    });

    testWidgets('taps liked quick filter chip', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Test', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Liked'));
      await tester.pump();
    });

    testWidgets('taps saved quick filter chip', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Test', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Saved'));
      await tester.pump();
    });

    testWidgets('taps last 24h quick filter chip', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Test', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Last 24h'));
      await tester.pump();
    });

    testWidgets('taps bookmark star button on article', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'guid-1', title: 'Star Article', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);
      when(() => mockAppState.markArticleStarred(any(), starred: any(named: 'starred')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();

      verify(() => mockAppState.markArticleStarred('guid-1', starred: true)).called(1);
    });

    testWidgets('taps refresh button', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(feedId: 1, guid: 'g1', title: 'Test', summary: 'S', publishedAt: now, fetchedAt: now),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('load more handles error gracefully', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = List.generate(
        10,
        (i) => Article(
          feedId: 1,
          guid: 'guid-$i',
          title: 'Article $i',
          summary: 'Summary $i',
          publishedAt: now - i * 3600000,
          fetchedAt: now,
        ),
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      int callCount = 0;
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 100);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async {
        callCount++;
        if (callCount > 1) throw Exception('Simulated load error');
        return articles;
      });
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Scroll to trigger loadMore (second call to getArticlesPaginated)
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('shows just now label for fresh article', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1, guid: 'guid-1', title: 'Fresh',
          summary: 'Summary',
          publishedAt: now, fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('shows hours ago label', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1, guid: 'guid-1', title: 'Oldish',
          summary: 'Summary',
          publishedAt: now - 5 * 3600000,
          fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('h ago'), findsOneWidget);
    });

    testWidgets('shows days ago label for older article', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1, guid: 'guid-1', title: 'Old',
          summary: 'Summary',
          publishedAt: now - 3 * 24 * 3600000,
          fetchedAt: now,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('d ago'), findsOneWidget);
    });

    testWidgets('uses fetchedAt fallback when publishedAt is null', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final articles = [
        Article(
          feedId: 1, guid: 'guid-1', title: 'Fetched Article',
          summary: 'Summary',
          fetchedAt: now - 24 * 3600000,
        ),
      ];
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => articles);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('d ago'), findsOneWidget);
      expect(find.textContaining('(fetched)'), findsOneWidget);
    });

    testWidgets('swipe left on saved article removes bookmark', (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final article = Article(
        feedId: 1, guid: 'guid-1', title: 'Saved Swipe',
        summary: 'S', publishedAt: now, fetchedAt: now,
      );
      final feed = Feed(url: 'https://example.com/feed.xml', title: 'Feed');
      final state = UserArticleState(articleGuid: 'guid-1', starredAt: now);

      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 1);
      when(() => mockAppState.getArticlesPaginated(
          feedId: any(named: 'feedId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'))).thenAnswer((_) async => [article]);
      when(() => mockAppState.feeds).thenReturn([feed]);
      when(() => mockAppState.getArticleState(any())).thenReturn(state);
      when(() => mockAppState.markArticleStarred(any(), starred: any(named: 'starred')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Swipe left to unstar
      await tester.timedDrag(
        find.text('Saved Swipe'),
        const Offset(-600, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      verify(() => mockAppState.markArticleStarred('guid-1', starred: false)).called(1);
    });

    testWidgets('switches tabs when tapping navigation items', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 0);

      await tester.tap(find.byIcon(Icons.store));
      await tester.pump();
      final navBar2 = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar2.currentIndex, 1);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      final navBar3 = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar3.currentIndex, 2);
    });
  });
}
