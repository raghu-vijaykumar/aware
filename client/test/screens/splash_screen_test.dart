import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/screens/home_screen.dart';
import 'package:aware/screens/onboarding_screen.dart';
import 'package:aware/screens/splash_screen.dart';

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
      home: const SplashScreen(),
    ),
  );
}

void main() {
  group('SplashScreen', () {
    late MockAppState mockAppState;

    setUp(() {
      mockAppState = MockAppState();
      when(() => mockAppState.addListener(any())).thenReturn(null);
      when(() => mockAppState.removeListener(any())).thenReturn(null);
      when(() => mockAppState.locale).thenReturn(const Locale('en'));
      when(() => mockAppState.setLocale(any())).thenAnswer((_) async {});
      when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
    });

    testWidgets('renders splash UI', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to OnboardingScreen when onboarding not complete',
        (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_complete': ''});
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('navigates to HomeScreen when onboarding is complete',
        (tester) async {
      SharedPreferences.setMockInitialValues(
          {'onboarding_complete': 'true'});
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
