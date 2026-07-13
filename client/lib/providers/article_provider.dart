import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/user_article_state.dart';
import '../services/database_service.dart';

class ArticleProvider extends ChangeNotifier {
  final DatabaseService _db;

  ArticleProvider({DatabaseService? db}) : _db = db ?? DatabaseService();

  final Map<String, UserArticleState> _articleStateCache = {};

  UserArticleState? getArticleState(String guid) => _articleStateCache[guid];

  Future<void> loadArticleStateCache() async {
    final states = await _db.getAllUserState();
    _articleStateCache
      ..clear()
      ..addEntries(states.map((s) => MapEntry(s.articleGuid, s)));
  }

  Future<List<Article>> getArticlesForFeed(int feedId) async {
    return await _db.getArticlesForFeed(feedId);
  }

  Future<List<Article>> getAllArticles() async {
    return await _db.getAllArticles();
  }

  Future<List<Article>> getArticlesPaginated({
    int? feedId,
    int? limit,
    int offset = 0,
  }) async {
    return await _db.getArticlesPaginated(
      feedId: feedId,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> getArticlesCount({int? feedId}) async {
    return await _db.getArticlesCount(feedId: feedId);
  }

  Future<void> markArticleRead(String guid, {bool read = true}) async {
    final existing = _articleStateCache[guid];
    final state = UserArticleState(
      id: existing?.id,
      articleGuid: guid,
      readAt: read ? DateTime.now().millisecondsSinceEpoch : null,
      likedAt: existing?.likedAt,
      starredAt: existing?.starredAt,
      tags: existing?.tags,
      lastAccessedAt: existing?.lastAccessedAt,
      readProgress: existing?.readProgress,
      lastParagraphIndex: existing?.lastParagraphIndex,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<void> markArticleLiked(String guid, {bool liked = true}) async {
    final existing = _articleStateCache[guid];
    final state = UserArticleState(
      id: existing?.id,
      articleGuid: guid,
      readAt: existing?.readAt,
      likedAt: liked ? DateTime.now().millisecondsSinceEpoch : null,
      starredAt: existing?.starredAt,
      tags: existing?.tags,
      lastAccessedAt: existing?.lastAccessedAt,
      readProgress: existing?.readProgress,
      lastParagraphIndex: existing?.lastParagraphIndex,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<void> markArticleStarred(String guid, {bool starred = true}) async {
    final existing = _articleStateCache[guid];
    final state = UserArticleState(
      id: existing?.id,
      articleGuid: guid,
      readAt: existing?.readAt,
      likedAt: existing?.likedAt,
      starredAt: starred ? DateTime.now().millisecondsSinceEpoch : null,
      tags: existing?.tags,
      lastAccessedAt: existing?.lastAccessedAt,
      readProgress: existing?.readProgress,
      lastParagraphIndex: existing?.lastParagraphIndex,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<void> recordArticleProgress(String guid, double progress, int paragraphIndex) async {
    final existing = _articleStateCache[guid];
    final state = UserArticleState(
      id: existing?.id,
      articleGuid: guid,
      readAt: existing?.readAt,
      likedAt: existing?.likedAt,
      starredAt: existing?.starredAt,
      tags: existing?.tags,
      lastAccessedAt: DateTime.now().millisecondsSinceEpoch,
      readProgress: progress,
      lastParagraphIndex: paragraphIndex,
    );
    await _db.insertUserState(state);
    _articleStateCache[guid] = state;
    notifyListeners();
  }

  Future<List<Article>> getStarredArticles() async {
    return await _db.getStarredArticles();
  }
}
