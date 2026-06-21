import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config.dart';
import 'providers/app_state.dart';
import 'providers/article_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/splash_screen.dart';
import 'services/ad_service.dart';
import 'services/background_feed_worker.dart';
import 'services/notification_service.dart';
import 'services/reader_audio_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize FFI-based sqflite for desktop platforms (Windows/macOS/Linux).
  // This enables the same database API used on mobile to work on desktop.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (!kIsWeb) {
    await NotificationService.ensureInitialized();
    await BackgroundFeedWorker.initialize();
    await BackgroundFeedWorker.schedulePeriodicRefresh();
  }

  try {
    await AdService.instance.initAdMob();
  } catch (e) {
    print('AdMob init failed in main: $e');
  }

  await _initializePostLaunchServices();

  runApp(const MyApp());
}

Future<void> _initializePostLaunchServices() async {
  try {
    await ReaderAudioService.ensureInitialized();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'reader_audio_service',
        context: ErrorDescription('while initializing background audio'),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedProvider>(create: (_) => FeedProvider()),
        ChangeNotifierProvider<ArticleProvider>(create: (_) => ArticleProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider<SyncProvider>(create: (_) => SyncProvider()),
        ChangeNotifierProvider<AppState>(create: (_) {
          final state = AppState(
            feed: _.read<FeedProvider>(),
            article: _.read<ArticleProvider>(),
            auth: _.read<AuthProvider>(),
            settings: _.read<SettingsProvider>(),
            sync: _.read<SyncProvider>(),
          );
          state.init();
          return state;
        }),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'aware',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: appState.themeMode,
            home: const SplashScreen(),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaleFactor: appState.textScaleFactor,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
