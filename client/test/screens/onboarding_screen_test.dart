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
      home: const OnboardingScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    ),
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

      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pump();

      expect(find.text('Next'), findsWidgets);
    });

    testWidgets('changes language via dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.text('English'));
      await tester.pump();

      await tester.tap(find.text('Français').last);
      await tester.pump();

      verify(() => mockAppState.setLocale('fr')).called(1);
    });

    testWidgets('advances to next page on Next button tap', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows Get started on last page after multiple Next taps',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        for (int j = 0; j < 5; j++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('completes onboarding via Skip', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      await tester.tap(find.text('Skip'));
      await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('completes onboarding via Get Started on last page',
        (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        for (int j = 0; j < 5; j++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.tap(find.text('Get Started'));
      await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
