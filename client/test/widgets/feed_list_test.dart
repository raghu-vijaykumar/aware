import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/models/article.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/widgets/feed_list.dart';

class MockAppState extends Mock implements AppState {}

Widget createTestWidget(AppState appState) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const Scaffold(body: FeedList()),
    ),
  );
}

void main() {
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('FeedList', () {
    testWidgets('renders without crashing', (tester) async {
      when(() => mockAppState.feeds).thenReturn([]);
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 0);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byType(FeedList), findsOneWidget);
    });

    testWidgets('add feed dialog opens and accepts URL', (tester) async {
      when(() => mockAppState.feeds).thenReturn([]);
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 0);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);
      when(() => mockAppState.addFeedFromUrl(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      // Find and tap the add feed button
      await tester.tap(find.byIcon(Icons.add_link));
      await tester.pump();

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Enter a URL
      await tester.enterText(find.byType(TextField), 'https://example.com/feed.xml');
      await tester.pump();

      // Tap the add button
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Verify addFeedFromUrl was called with the URL
      verify(() => mockAppState.addFeedFromUrl('https://example.com/feed.xml')).called(1);
    });

    testWidgets('add feed dialog shows error on failure', (tester) async {
      when(() => mockAppState.feeds).thenReturn([]);
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 0);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);
      when(() => mockAppState.addFeedFromUrl(any()))
          .thenThrow(Exception('Invalid URL'));

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add_link));
      await tester.pump();

      // Enter a URL
      await tester.enterText(find.byType(TextField), 'bad-url');
      await tester.pump();

      // Tap add
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Error snackbar should appear
      expect(find.textContaining('Invalid URL'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog without adding', (tester) async {
      when(() => mockAppState.feeds).thenReturn([]);
      when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
          .thenAnswer((_) async => 0);
      when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add_link));
      await tester.pump();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Dialog closed
      expect(find.byType(AlertDialog), findsNothing);
      // addFeedFromUrl was never called
      verifyNever(() => mockAppState.addFeedFromUrl(any()));
    });
  });
}
