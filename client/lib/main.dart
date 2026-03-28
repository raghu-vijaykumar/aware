import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/background_feed_worker.dart';
import 'services/notification_service.dart';
import 'services/reader_audio_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI-based sqflite for desktop platforms (Windows/macOS/Linux).
  // This enables the same database API used on mobile to work on desktop.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.ensureInitialized();
    await BackgroundFeedWorker.initialize();
    await BackgroundFeedWorker.schedulePeriodicRefresh();
  }

  runApp(const MyApp());

  unawaited(_initializePostLaunchServices());
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
        ChangeNotifierProvider(create: (_) {
          final state = AppState();
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
