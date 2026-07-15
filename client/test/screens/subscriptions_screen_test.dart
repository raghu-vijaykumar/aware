import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/subscriptions_screen.dart';
import 'package:aware/services/database_service.dart';

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
      home: const SubscriptionsScreen(),
    ),
  );
}

void main() {
  late MockAppState mockAppState;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.resetForTesting();
  });

  setUp(() {
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
    when(() => mockAppState.isInitialized).thenReturn(true);
  });

  group('SubscriptionsScreen', () {
    testWidgets('renders feed list when initialized with feeds',
        (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
          paused: true,
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byType(SubscriptionsScreen), findsOneWidget);
      expect(find.text('Test Feed'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('shows empty state when no feeds', (tester) async {
      when(() => mockAppState.feeds).thenReturn([]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.text('No subscriptions yet. Add feeds from the Marketplace!'), findsOneWidget);
    });

    testWidgets('shows loading indicator when not initialized',
        (tester) async {
      when(() => mockAppState.isInitialized).thenReturn(false);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows rss feed icon when no iconUrl', (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'No Icon Feed',
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byIcon(Icons.rss_feed), findsOneWidget);
    });



    testWidgets('shows popup menu items', (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
          paused: true,
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pump();
      await tester.pump();

      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Unsubscribe'), findsOneWidget);
    });

    testWidgets('tap pause menu item calls setFeedPaused and reloads',
        (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
          paused: true,
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resume'));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 500)));
      await tester.pump();

      verify(() => mockAppState.loadFeeds()).called(1);
    });

    testWidgets('tap Unsubscribe shows confirmation dialog',
        (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
          paused: true,
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unsubscribe').last);
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('confirm unsubscribe deletes feed and reloads',
        (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unsubscribe').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Unsubscribe'));
      await tester.pump();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 500)));
      await tester.pump();

      verify(() => mockAppState.loadFeeds()).called(1);
    });

    testWidgets('cancel unsubscribe does not reload', (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unsubscribe').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAppState.loadFeeds());
    });

    testWidgets('tap on list tile does not crash', (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
        ),
      ]);
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.text('Test Feed'));
      await tester.pump();
    });
  });
}
