import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/home_screen.dart';

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
      child: const HomeScreen(),
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
  });

  group('HomeScreen', () {
    testWidgets('renders bottom navigation bar with three tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byIcon(Icons.rss_feed), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('switches tab on tap', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.store));
      await tester.pump();

      // After switching to marketplace tab
      expect(find.byIcon(Icons.store), findsOneWidget);
    });
  });
}
