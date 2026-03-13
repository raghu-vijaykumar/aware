import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  // Initialize FFI-based sqflite for desktop platforms (Windows/macOS/Linux).
  // This enables the same database API used on mobile to work on desktop.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
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
      child: MaterialApp(
        title: 'aware',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4DD0E1)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
