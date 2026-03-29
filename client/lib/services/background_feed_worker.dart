import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:readability/readability.dart' as readability;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/article.dart';
import '../models/feed.dart';
import 'database_service.dart';
import 'feed_service.dart';
import 'notification_service.dart';

const String kFeedRefreshTask = 'feed_refresh_task';
const String _lowDataModePrefKey = 'app_low_data_mode';
const int _lowDataPrefetchLimit = 6;

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
  final DatabaseService _db = DatabaseService();
  final FeedService _feedService = FeedService();

  Future<void> run() async {
    final feeds = await _db.getFeeds();
    final activeFeeds =
        feeds.where((f) => !f.paused && (f.id != null)).toList();
    if (activeFeeds.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final lowDataMode = prefs.getBool(_lowDataModePrefKey) ?? false;

    final existingGuids = await _db.getAllArticleGuids();
    int newArticles = 0;
    final insertedArticles = <Article>[];

    for (final feed in activeFeeds) {
      final inserted = await _fetchAndStore(feed, existingGuids);
      insertedArticles.addAll(inserted);
      newArticles += inserted.length;
    }

    if (lowDataMode) {
      await _prefetchReaderContent(insertedArticles);
    }

    if (newArticles > 0) {
      await NotificationService.showNewArticles(newArticles);
    } else {
      await NotificationService.showNoNewArticles();
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

  Future<void> _prefetchReaderContent(List<Article> insertedArticles) async {
    if (insertedArticles.isEmpty) return;
    final sorted = [...insertedArticles];
    sorted.sort(
      (a, b) => (b.publishedAt ?? b.fetchedAt ?? 0)
          .compareTo(a.publishedAt ?? a.fetchedAt ?? 0),
    );

    final candidates = sorted
        .where((article) => article.url != null && article.url!.isNotEmpty)
        .take(_lowDataPrefetchLimit)
        .toList();

    for (final article in candidates) {
      try {
        final parsed = await readability.parseAsync(article.url!);
        final content = (parsed.content ?? parsed.textContent ?? '').trim();
        if (content.isEmpty) continue;
        await _db.upsertPrefetchedArticleContent(article.guid, content);
      } catch (_) {
        // Best-effort cache warmup; ignore per-article failures.
      }
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

  static Future<void> schedulePeriodicRefresh() async {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(
      kDebugMode ? const Duration(minutes: 1) : const Duration(minutes: 15),
      (timer) async {
        final worker = BackgroundFeedWorker();
        await worker.run();
      },
    );

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    final prefs = await SharedPreferences.getInstance();
    final lowDataMode = prefs.getBool(_lowDataModePrefKey) ?? false;
    await Workmanager().registerPeriodicTask(
      kFeedRefreshTask,
      kFeedRefreshTask,
      inputData: const {'trigger': 'periodic_refresh'},
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType:
            lowDataMode ? NetworkType.unmetered : NetworkType.connected,
      ),
    );
  }
}
