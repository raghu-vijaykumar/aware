import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../models/feed.dart';
import 'database_service.dart';
import 'feed_service.dart';
import 'notification_service.dart';

const String kFeedRefreshTask = 'feed_refresh_task';

@pragma('vm:entry-point')
void backgroundFeedDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final worker = BackgroundFeedWorker();
    await worker.run();
    return Future.value(true);
  });
}

class BackgroundFeedWorker {
  final DatabaseService _db = DatabaseService();
  final FeedService _feedService = FeedService();

  Future<void> run() async {
    final feeds = await _db.getFeeds();
    final activeFeeds = feeds.where((f) => !f.paused && (f.id != null)).toList();
    if (activeFeeds.isEmpty) return;

    final existingGuids = await _db.getAllArticleGuids();
    int newArticles = 0;

    for (final feed in activeFeeds) {
      newArticles += await _fetchAndStore(feed, existingGuids);
    }

    if (newArticles > 0) {
      await NotificationService.showNewArticles(newArticles);
    }
  }

  Future<int> _fetchAndStore(Feed feed, Set<String> existingGuids) async {
    try {
      final articles = await _feedService.fetchArticles(feed.url);
      int inserted = 0;
      for (final article in articles) {
        if (existingGuids.contains(article.guid)) continue;

        await _db.insertArticle(article.copyWith(feedId: feed.id!));
        existingGuids.add(article.guid);
        inserted++;
      }
      return inserted;
    } catch (_) {
      // Ignore individual feed errors in background job.
      return 0;
    }
  }

  static Future<void> initialize() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    await NotificationService.ensureInitialized();
    await Workmanager().initialize(
      backgroundFeedDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> schedulePeriodicRefresh() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    await Workmanager().registerPeriodicTask(
      kFeedRefreshTask,
      kFeedRefreshTask,
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
