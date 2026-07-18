import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../models/article.dart';
import '../models/feed.dart';
import 'database_service.dart';
import 'feed_service.dart';
import 'notification_service.dart';

const String kFeedRefreshTask = 'feed_refresh_task';

@pragma('vm:entry-point')
void backgroundFeedDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final worker = BackgroundFeedWorker();
    await worker.run();
    return Future.value(true);
  });
}

class BackgroundFeedWorker {
  static Timer? _foregroundTimer;
  final DatabaseService _db;
  final FeedService _feedService;

  BackgroundFeedWorker({
    DatabaseService? db,
    FeedService? feedService,
  })  : _db = db ?? DatabaseService(),
        _feedService = feedService ?? FeedService();

  Future<void> run() async {
    final feeds = await _db.getFeeds();
    final activeFeeds =
        feeds.where((f) => !f.paused && (f.id != null)).toList();
    if (activeFeeds.isEmpty) return;

    final existingGuids = await _db.getAllArticleGuids();
    int newArticles = 0;

    for (final feed in activeFeeds) {
      final inserted = await _fetchAndStore(feed, existingGuids);
      newArticles += inserted.length;
    }

    if (newArticles > 0) {
      await NotificationService.showNewArticles(newArticles);
    }
  }

  Future<List<Article>> _fetchAndStore(
    Feed feed,
    Set<String> existingGuids,
  ) async {
    try {
      final articles = await _feedService.fetchArticles(feed.url);
      final inserted = <Article>[];
      for (final article in articles) {
        if (existingGuids.contains(article.guid)) continue;

        final stored = article.copyWith(feedId: feed.id!);
        await _db.insertArticle(stored);
        existingGuids.add(article.guid);
        inserted.add(stored);
      }
      return inserted;
    } catch (_) {
      // Ignore individual feed errors in background job.
      return const [];
    }
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    await NotificationService.ensureInitialized();
    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().initialize(
        backgroundFeedDispatcher,
        // Suppress Workmanager's debug foreground notification.
        isInDebugMode: false,
      );
    }
  }

  @visibleForTesting
  static Future<void> runForegroundRefresh() async {
    final worker = BackgroundFeedWorker();
    await worker.run();
  }

  static Future<void> schedulePeriodicRefresh() async {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(
      kDebugMode ? const Duration(minutes: 1) : const Duration(minutes: 15),
      (timer) async => runForegroundRefresh(),
    );

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    await Workmanager().registerPeriodicTask(
      kFeedRefreshTask,
      kFeedRefreshTask,
      inputData: const {'trigger': 'periodic_refresh'},
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
