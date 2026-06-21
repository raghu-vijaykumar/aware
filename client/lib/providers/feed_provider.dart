import 'package:flutter/foundation.dart';

import '../models/feed.dart';
import '../models/folder.dart';
import '../services/database_service.dart';
import '../services/feed_service.dart';

class FeedProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FeedService _feedService = FeedService();

  List<Feed> _feeds = [];
  List<Feed> get feeds => _feeds;

  List<Folder> _folders = [];
  List<Folder> get folders => _folders;

  Map<int, List<int>> _feedFolderAssignments = {};
  Map<int, List<int>> get feedFolderAssignments => _feedFolderAssignments;

  Future<void> loadFeeds() async {
    _feeds = await _db.getFeeds();
    _folders = await _db.getFolders();
    _feedFolderAssignments = await _db.getFeedFolderAssignments();
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

  Future<void> createFolder(String name) async {
    await _db.insertFolder(Folder(name: name));
    await loadFeeds();
  }

  Future<void> renameFolder(int id, String newName) async {
    await _db.renameFolder(id, newName);
    await loadFeeds();
  }

  Future<void> deleteFolder(int id) async {
    await _db.deleteFolder(id);
    await loadFeeds();
  }

  Future<void> assignFeedToFolder(int feedId, int folderId) async {
    await _db.assignFeedToFolder(feedId, folderId);
    await loadFeeds();
  }

  Future<void> removeFeedFromFolder(int feedId, int folderId) async {
    await _db.removeFeedFromFolder(feedId, folderId);
    await loadFeeds();
  }

  List<Feed> getFeedsInFolder(int folderId) {
    final feedIds = _feedFolderAssignments[folderId] ?? [];
    return _feeds.where((f) => f.id != null && feedIds.contains(f.id)).toList();
  }

  List<Feed> getUncategorisedFeeds() {
    final assignedIds = _feedFolderAssignments.values
        .expand((ids) => ids)
        .toSet();
    return _feeds.where((f) => !assignedIds.contains(f.id)).toList();
  }
}
