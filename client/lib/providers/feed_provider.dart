import 'package:flutter/foundation.dart';

import '../models/feed.dart';
import '../services/database_service.dart';
import '../services/feed_service.dart';

class FeedProvider extends ChangeNotifier {
  final DatabaseService _db;
  final FeedService _feedService;

  FeedProvider({
    DatabaseService? db,
    FeedService? feedService,
  })  : _db = db ?? DatabaseService(),
        _feedService = feedService ?? FeedService();

  List<Feed> _feeds = [];
  List<Feed> get feeds => _feeds;

  Future<void> loadFeeds() async {
    _feeds = await _db.getFeeds();
    notifyListeners();
  }

  Future<void> addFeedFromUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError('Invalid feed URL');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError('Only http and https URLs are supported');
    }
    final feed = await _feedService.fetchFeedMetadata(url);
    final id = await _db.insertFeed(feed);
    final articles = await _feedService.fetchArticles(url);
    for (final article in articles) {
      await _db.insertArticle(article.copyWith(feedId: id));
    }
    await loadFeeds();
  }

  Future<void> deleteFeed(int feedId) async {
    await _db.deleteFeed(feedId);
    await loadFeeds();
  }

  Future<void> setFeedPaused(int feedId, bool paused) async {
    await _db.setFeedPaused(feedId, paused);
    await loadFeeds();
  }

}
