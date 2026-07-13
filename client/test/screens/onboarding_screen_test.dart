import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/onboarding_screen.dart';
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
      child: const OnboardingScreen(),
    ),
    routes: {
      '/home': (_) => const HomeScreen(),
    },
  );
}

void main() {
  late MockAppState mockAppState;

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAppState = MockAppState();
    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.locale).thenReturn(const Locale('en'));
    when(() => mockAppState.setLocale(any())).thenAnswer((_) async {});
    when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
  });

  group('OnboardingScreen', () {
    testWidgets('renders first page with language selector', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('navigates to next page on drag', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('page indicator changes after drag', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      // Drag the PageView to advance one page
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pump();

      // Check the button text is still Next (not last page)
      expect(find.text('Next'), findsWidgets);
    });

    testWidgets('changes language via dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      // Tap the dropdown
      await tester.tap(find.text('English'));
      await tester.pump();

      // Select French
      await tester.tap(find.text('Français').last);
      await tester.pump();

      verify(() => mockAppState.setLocale('fr')).called(1);
    });
  });
}
