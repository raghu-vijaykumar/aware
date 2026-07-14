import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/marketplace_screen.dart';

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
      home: const Scaffold(body: MarketplaceScreen()),
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
    rootBundle.clear();
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.locale).thenReturn(const Locale('en'));
    when(() => mockAppState.setLocale(any())).thenAnswer((_) async {});
    when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
    when(() => mockAppState.feeds).thenReturn([]);
    when(() => mockAppState.addFeedFromUrl(any())).thenAnswer((_) async {});
  });

  group('MarketplaceScreen', () {
    testWidgets('renders loading then empty state', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.text('Marketplace'), findsOneWidget);
    });

    testWidgets('renders feeds when JSON loads', (tester) async {
      final curatedJson = jsonEncode({
        'categories': [
          {'id': 'news', 'label': 'News', 'color': '#FF5722'},
        ],
        'feeds': [
          {
            'url': 'https://example.com/feed.xml',
            'title': 'Example Feed',
            'description': 'An example feed',
            'category': 'news',
          },
        ],
      });

      _mockCuratedFeeds(tester, curatedJson);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Tap the ExpansionTile (by finding it via type) to expose feed tiles
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('Example Feed'), findsOneWidget);
    });

    testWidgets('follow button calls addFeedFromUrl', (tester) async {
      final curatedJson = jsonEncode({
        'categories': [
          {'id': 'news', 'label': 'News', 'color': '#FF5722'},
        ],
        'feeds': [
          {
            'url': 'https://example.com/feed.xml',
            'title': 'Example Feed',
            'description': 'An example feed',
            'category': 'news',
          },
        ],
      });

      _mockCuratedFeeds(tester, curatedJson);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Follow'));
      await tester.pumpAndSettle();

      verify(() => mockAppState.addFeedFromUrl('https://example.com/feed.xml')).called(1);
    });

    testWidgets('search filters visible feeds', (tester) async {
      final curatedJson = jsonEncode({
        'categories': [
          {'id': 'news', 'label': 'News', 'color': '#FF5722'},
          {'id': 'tech', 'label': 'Tech', 'color': '#42A5F5'},
        ],
        'feeds': [
          {
            'url': 'https://example.com/news.xml',
            'title': 'Breaking News',
            'description': 'Latest news',
            'category': 'news',
          },
          {
            'url': 'https://example.com/tech.xml',
            'title': 'Tech Trends',
            'description': 'Tech articles',
            'category': 'tech',
          },
        ],
      });

      _mockCuratedFeeds(tester, curatedJson);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(ExpansionTile).at(0));
      await tester.pump();
      await tester.tap(find.byType(ExpansionTile).at(1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Tech');
      await tester.pumpAndSettle();

      expect(find.text('1 feeds found'), findsOneWidget);
      expect(find.text('Tech Trends'), findsOneWidget);
      expect(find.text('Breaking News'), findsNothing);
    });

    testWidgets('search clear button resets results', (tester) async {
      final curatedJson = jsonEncode({
        'categories': [
          {'id': 'news', 'label': 'News', 'color': '#FF5722'},
        ],
        'feeds': [
          {
            'url': 'https://example.com/news.xml',
            'title': 'Breaking News',
            'description': 'Latest news',
            'category': 'news',
          },
        ],
      });

      _mockCuratedFeeds(tester, curatedJson);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('0 feeds found'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('0 feeds found'), findsNothing);
    });

    testWidgets('shows subscribed state when feed is already followed', (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(url: 'https://example.com/feed.xml', title: 'My Feed'),
      ]);

      final curatedJson = jsonEncode({
        'categories': [
          {'id': 'news', 'label': 'News', 'color': '#FF5722'},
        ],
        'feeds': [
          {
            'url': 'https://example.com/feed.xml',
            'title': 'Example Feed',
            'description': 'An example feed',
            'category': 'news',
          },
        ],
      });

      _mockCuratedFeeds(tester, curatedJson);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('Subscribed'), findsOneWidget);
    });

    testWidgets('follow error shows error snackbar', (tester) async {
      when(() => mockAppState.addFeedFromUrl(any()))
          .thenThrow(ArgumentError('Invalid URL'));

      final curatedJson = jsonEncode({
        'categories': [
          {'id': 'news', 'label': 'News', 'color': '#FF5722'},
        ],
        'feeds': [
          {
            'url': 'https://example.com/bad-feed.xml',
            'title': 'Bad Feed',
            'description': 'Will fail to follow',
            'category': 'news',
          },
        ],
      });

      _mockCuratedFeeds(tester, curatedJson);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Follow'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Invalid feed URL'), findsWidgets);
    });
  });
}

void _mockCuratedFeeds(WidgetTester tester, String curatedJson) {
  tester.binding.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) async {
      if (message == null) return null;
      final bytes = message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes);
      final key = utf8.decode(bytes);
      if (key == 'assets/curated_feeds.json') {
        return ByteData.sublistView(
          Uint8List.fromList(utf8.encode(curatedJson)),
        );
      }
      return null;
    },
  );
}
