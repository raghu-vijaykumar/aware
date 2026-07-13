import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/subscriptions_screen.dart';

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
      child: const SubscriptionsScreen(),
    ),
  );
}

void main() {
  late MockAppState mockAppState;

  setUpAll(() {
    registerFallbackValue(Feed(url: ''));
  });

  setUp(() {
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
  });

  group('SubscriptionsScreen', () {
    testWidgets('shows loading indicator when not initialized', (tester) async {
      when(() => mockAppState.isInitialized).thenReturn(false);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no feeds', (tester) async {
      when(() => mockAppState.isInitialized).thenReturn(true);
      when(() => mockAppState.feeds).thenReturn([]);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.text('No subscriptions yet. Add feeds from the Marketplace!'), findsOneWidget);
    });

    testWidgets('renders feed list', (tester) async {
      when(() => mockAppState.isInitialized).thenReturn(true);
      when(() => mockAppState.feeds).thenReturn([
        Feed(url: 'https://example.com/rss', title: 'Test Feed', iconUrl: null),
      ]);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.text('Test Feed'), findsOneWidget);
    });
  });
}
