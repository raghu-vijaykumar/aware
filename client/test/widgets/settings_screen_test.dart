import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aware/l10n/app_localizations.dart';
import 'package:aware/providers/app_state.dart';
import 'package:aware/models/feed.dart';
import 'package:aware/screens/subscriptions_screen.dart';
import 'package:aware/widgets/settings_screen.dart';

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
      home: const Scaffold(body: SettingsScreen()),
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
    mockAppState = MockAppState();

    when(() => mockAppState.addListener(any())).thenReturn(null);
    when(() => mockAppState.removeListener(any())).thenReturn(null);
    when(() => mockAppState.locale).thenReturn(const Locale('en'));
    when(() => mockAppState.setLocale(any())).thenAnswer((_) async {});
    when(() => mockAppState.loadFeeds()).thenAnswer((_) async {});
    when(() => mockAppState.isInitialized).thenReturn(true);
    when(() => mockAppState.getArticlesCount(feedId: any(named: 'feedId')))
        .thenAnswer((_) async => 0);
    when(() => mockAppState.getArticlesPaginated(
        feedId: any(named: 'feedId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'))).thenAnswer((_) async => []);
    when(() => mockAppState.feeds).thenReturn([]);
    when(() => mockAppState.autoMarkReadEnabled).thenReturn(false);
    when(() => mockAppState.autoMarkReadThreshold).thenReturn(50);
    when(() => mockAppState.autoPlayNext).thenReturn(false);
    when(() => mockAppState.speechRate).thenReturn(1.0);
    when(() => mockAppState.voiceId).thenReturn(null);
    when(() => mockAppState.textScaleFactor).thenReturn(1.0);
    when(() => mockAppState.themeMode).thenReturn(ThemeMode.system);
    when(() => mockAppState.getArticleState(any())).thenReturn(null);
    when(() => mockAppState.setAutoMarkReadEnabled(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setAutoMarkReadThreshold(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setAutoPlayNext(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setSpeechRate(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setVoiceId(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setTextScaleFactor(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.setThemeMode(any()))
        .thenAnswer((_) async {});
    when(() => mockAppState.addFeedFromUrl(any()))
        .thenAnswer((_) async {});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getVoices') {
          return jsonDecode('[{"name":"en-us-x-tpplocal","locale":"en-US"},{"name":"en-gb-x-tpplocal","locale":"en-GB"},{"name":"fr-fr-x-tpplocal","locale":"fr-FR"}]');
        }
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory') {
          return 'C:\\temp';
        }
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'share') {
          return '';
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      null,
    );
  });

  group('SettingsScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows auto-mark-read section', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.text('Auto-mark read by progress'), findsOneWidget);
    });

    testWidgets('voice section shows loaded voices', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.scrollUntilVisible(
        find.textContaining('Voice'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Voice'), findsWidgets);
    });

    testWidgets('premium card shows and dialog opens', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Go Ad-Free'), findsOneWidget);

      await tester.tap(find.textContaining('Go Ad-Free'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Remove all ads'), findsOneWidget);
    });

    testWidgets('section headers are rendered', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // 'Advanced' section is visible without scrolling
      expect(find.textContaining('Advanced'), findsOneWidget);
    });

    testWidgets('premium dialog not now button closes it', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.textContaining('Go Ad-Free'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Coming Soon'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.text('Not now'), findsNothing);
    });

    testWidgets('auto mark read threshold slider drags', (tester) async {
      when(() => mockAppState.autoMarkReadEnabled).thenReturn(true);
      when(() => mockAppState.setAutoMarkReadThreshold(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final slider = find.byType(Slider).first;
      expect(slider, findsWidgets);

      // Drag slider to the right
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      verify(() => mockAppState.setAutoMarkReadThreshold(any())).called(2);
    });

    testWidgets('auto play next switch in settings toggles', (tester) async {
      when(() => mockAppState.setAutoPlayNext(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.byType(Switch).last,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();
      await tester.tap(find.byType(Switch).last);
      await tester.pump();

      verify(() => mockAppState.setAutoPlayNext(true)).called(1);
    });

    testWidgets('speech rate slider calls setSpeechRate', (tester) async {
      when(() => mockAppState.setSpeechRate(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Default narration speed'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      final slider = find.descendant(
        of: find.ancestor(
          of: find.text('Default narration speed'),
          matching: find.byType(ListTile),
        ),
        matching: find.byType(Slider),
      );
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      verify(() => mockAppState.setSpeechRate(any()));
    });

    testWidgets('voice dropdown selects a voice', (tester) async {
      when(() => mockAppState.setVoiceId(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Default voice'),
        200,
        scrollable: scrollable,
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(DropdownButton<String?>).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byType(DropdownMenuItem<String?>).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockAppState.setVoiceId(any())).called(1);
    });

    testWidgets('voice dropdown shows current voice when voiceId matches', (tester) async {
      when(() => mockAppState.voiceId).thenReturn('en-us-x-tpplocal|en-US');

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Default voice'),
        200,
        scrollable: scrollable,
      );
      await tester.pump(const Duration(milliseconds: 100));

      final dropdown = find.byType(DropdownButton<String?>).last;
      expect(dropdown, findsOneWidget);
    });

    testWidgets('text scale slider calls setTextScaleFactor', (tester) async {
      when(() => mockAppState.setTextScaleFactor(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Text size'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      final slider = find.descendant(
        of: find.ancestor(
          of: find.text('Text size'),
          matching: find.byType(ListTile),
        ),
        matching: find.byType(Slider),
      );
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      verify(() => mockAppState.setTextScaleFactor(any()));
    });

    testWidgets('theme dialog selects dark mode', (tester) async {
      when(() => mockAppState.setThemeMode(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      // Scroll to bottom of list to reach themes section
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -800));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Themes').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Theme'), findsOneWidget);

      // "Dark" appears in section header and radio tile
      await tester.tap(find.text('Dark').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockAppState.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('language dialog opens', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Open Source Licenses'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.drag(scrollable, const Offset(0, 80));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Language').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Language'), findsOneWidget);
    });

    testWidgets('language dialog selects a language', (tester) async {
      when(() => mockAppState.setLocale(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Open Source Licenses'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.drag(scrollable, const Offset(0, 80));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Language').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap "English" directly in the dialog
      await tester.tap(find.text('English').first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => mockAppState.setLocale(any())).called(1);
    });

    testWidgets('theme dialog selects light mode', (tester) async {
      when(() => mockAppState.setThemeMode(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.drag(find.byType(Scrollable).last, const Offset(0, -800));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Themes').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Light').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockAppState.setThemeMode(ThemeMode.light)).called(1);
    });

    testWidgets('theme dialog selects system mode', (tester) async {
      when(() => mockAppState.setThemeMode(any()))
          .thenAnswer((_) async {});
      when(() => mockAppState.themeMode).thenReturn(ThemeMode.light);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.drag(find.byType(Scrollable).last, const Offset(0, -800));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Themes').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('System').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockAppState.setThemeMode(ThemeMode.system)).called(1);
    });

    testWidgets('manage subscriptions navigates to subscriptions screen', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Manage Subscriptions'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Manage Subscriptions').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SubscriptionsScreen), findsOneWidget);
    });

    testWidgets('privacy policy screen navigates', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Privacy Policy'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Privacy Policy').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Privacy Policy'), findsWidgets);
    });

    testWidgets('open source licenses page opens', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Open Source Licenses'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Open Source Licenses'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Aware'), findsWidgets);
    });

    testWidgets('crash button exists', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      await tester.drag(find.byType(Scrollable).last, const Offset(0, -1500));
      await tester.pump();
      await tester.pump();

      expect(find.text('Test Crash'), findsOneWidget);

      await tester.tap(find.text('Test Crash'));
      await tester.pump();
      tester.takeException();
    });

    testWidgets('export subscriptions shows snackbar when no feeds', (tester) async {
      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Export Subscriptions'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Export Subscriptions').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('export subscriptions with feeds succeeds', (tester) async {
      when(() => mockAppState.feeds).thenReturn([
        Feed(
          id: 1,
          url: 'https://example.com/feed.xml',
          title: 'Test Feed',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockAppState));
      await tester.pump();
      await tester.pump();

      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Export Subscriptions'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Export Subscriptions').last);
      await tester.pump();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 500)));
      await tester.pump();
    });
  });
}
