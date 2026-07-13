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
      when(() => mockAppState.getArticlesForFeed(any())).thenAnswer((_) async => []);
      when(() => mockAppState.getArticlesPaginated()).thenAnswer((_) async => []);
      when(() => mockAppState.getArticlesCount()).thenAnswer((_) async => 0);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      // Should show empty state or feed list.
      expect(find.byType(FeedList), findsOneWidget);
    });
  });
}
