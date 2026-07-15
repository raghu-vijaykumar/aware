import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/screens/privacy_policy_screen.dart';

Widget createTestWidget() {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const PrivacyPolicyScreen(),
  );
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'launch') {
          return true;
        }
        return null;
      },
    );
  });

  testWidgets('renders privacy policy title and body text', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('Information We Collect'), findsOneWidget);
    expect(find.text('Third-Party Services'), findsOneWidget);
    expect(find.text('Data Storage'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
  });

  testWidgets('tapping Google Privacy link calls launchUrl', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    await tester.tap(find.text('https://policies.google.com/privacy'));
    await tester.pump();
  });
}
