import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  testWidgets('renders privacy policy title and body text', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('Information We Collect'), findsOneWidget);
    expect(find.text('Third-Party Services'), findsOneWidget);
    expect(find.text('Data Storage'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
  });
}
