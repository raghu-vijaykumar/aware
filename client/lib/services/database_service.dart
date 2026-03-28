import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/feed.dart';
import '../models/article.dart';
import '../models/user_article_state.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  bool _ensuredLikedColumn = false;
  bool _ensuredPrefetchCacheTable = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'aware.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feeds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT UNIQUE NOT NULL,
        title TEXT,
        description TEXT,
        site_url TEXT,
        icon_url TEXT,
        category TEXT,
        curator TEXT,
        paused INTEGER DEFAULT 0,
        last_fetched INTEGER,
        etag TEXT,
        last_modified TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        feed_id INTEGER REFERENCES feeds(id),
        guid TEXT UNIQUE NOT NULL,
        url TEXT,
        title TEXT,
        summary TEXT,
        content TEXT,
        author TEXT,
        published_at INTEGER,
        fetched_at INTEGER,
        image_url TEXT,
        raw_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_article_state (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_guid TEXT UNIQUE NOT NULL,
        read_at INTEGER,
        liked_at INTEGER,
        starred_at INTEGER,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        parent_id INTEGER REFERENCES folders(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE feed_folders (
        feed_id INTEGER REFERENCES feeds(id),
        folder_id INTEGER REFERENCES folders(id),
        PRIMARY KEY (feed_id, folder_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE article_prefetch_cache (
        article_guid TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE feeds ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE feeds ADD COLUMN curator TEXT');
      await db.execute('ALTER TABLE feeds ADD COLUMN paused INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      // Add liked_at only if it doesn't already exist (defensive for partial upgrades).
      final columns =
          await db.rawQuery('PRAGMA table_info(user_article_state)');
      final hasLiked = columns
          .any((c) => (c['name'] as String?)?.toLowerCase() == 'liked_at');
      if (!hasLiked) {
        await db.execute(
            'ALTER TABLE user_article_state ADD COLUMN liked_at INTEGER');
      }
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS article_prefetch_cache (
          article_guid TEXT PRIMARY KEY,
          content TEXT NOT NULL,
          cached_at INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> _onOpen(Database db) async {
    // Defensive: ensure liked_at exists even if a prior migration was skipped.
    final columns = await db.rawQuery('PRAGMA table_info(user_article_state)');
    final hasLiked = columns.any((c) => c['name'] == 'liked_at');
    if (!hasLiked) {
      await db.execute(
          'ALTER TABLE user_article_state ADD COLUMN liked_at INTEGER');
    }
    await _ensurePrefetchCacheTable(db);
  }

  // Feed operations
  Future<int> insertFeed(Feed feed) async {
    final db = await database;
    return await db.insert('feeds', feed.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFeed(int feedId) async {
    final db = await database;
    await db.delete('feeds', where: 'id = ?', whereArgs: [feedId]);
    await db.delete('articles', where: 'feed_id = ?', whereArgs: [feedId]);
  }

  Future<void> setFeedPaused(int feedId, bool paused) async {
    final db = await database;
    await db.update(
      'feeds',
      {'paused': paused ? 1 : 0},
      where: 'id = ?',
      whereArgs: [feedId],
    );
  }

  Future<List<Feed>> getFeeds() async {
    final db = await database;
    final maps = await db.query('feeds');
    return List.generate(maps.length, (i) => Feed.fromMap(maps[i]));
  }

  // Article operations
  Future<int> insertArticle(Article article) async {
    final db = await database;
    return await db.insert('articles', article.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Article>> getArticlesForFeed(int feedId) async {
    final db = await database;
    final maps =
        await db.query('articles', where: 'feed_id = ?', whereArgs: [feedId]);
    return List.generate(maps.length, (i) => Article.fromMap(maps[i]));
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT * FROM articles
      ORDER BY COALESCE(published_at, fetched_at) DESC
    ''');
    return List.generate(maps.length, (i) => Article.fromMap(maps[i]));
  }

  Future<Set<String>> getAllArticleGuids() async {
    final db = await database;
    final rows = await db.query('articles', columns: ['guid']);
    return rows.map((row) => row['guid'] as String).toSet();
  }

  // User state operations
  Future<int> insertUserState(UserArticleState state) async {
    final db = await database;
    await _ensureLikedColumn(db);
    return await db.insert('user_article_state', state.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserArticleState?> getUserState(String guid) async {
    final db = await database;
    final maps = await db.query('user_article_state',
        where: 'article_guid = ?', whereArgs: [guid]);
    if (maps.isNotEmpty) {
      return UserArticleState.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserArticleState>> getAllUserState() async {
    final db = await database;
    await _ensureLikedColumn(db);
    final maps = await db.query('user_article_state');
    return maps.map((m) => UserArticleState.fromMap(m)).toList();
  }

  Future<List<String>> getStarredArticleGuids() async {
    final db = await database;
    await _ensureLikedColumn(db);
    final maps = await db.query(
      'user_article_state',
      columns: ['article_guid'],
      where: 'starred_at IS NOT NULL',
    );

    return maps.map((m) => m['article_guid'] as String).toList();
  }

  Future<List<Article>> getStarredArticles() async {
    final db = await database;
    await _ensureLikedColumn(db);
    final maps = await db.rawQuery('''
      SELECT a.* FROM articles a
      INNER JOIN user_article_state u
        ON u.article_guid = a.guid
      WHERE u.starred_at IS NOT NULL
      ORDER BY u.starred_at DESC
    ''');

    return List.generate(maps.length, (i) => Article.fromMap(maps[i]));
  }

  Future<List<String>> getReadArticleGuids() async {
    final db = await database;
    await _ensureLikedColumn(db);
    final maps = await db.query(
      'user_article_state',
      columns: ['article_guid'],
      where: 'read_at IS NOT NULL',
    );

    return maps.map((m) => m['article_guid'] as String).toList();
  }

  Future<void> _ensureLikedColumn(Database db) async {
    if (_ensuredLikedColumn) return;
    final columns = await db.rawQuery('PRAGMA table_info(user_article_state)');
    final hasLiked =
        columns.any((c) => (c['name'] as String?)?.toLowerCase() == 'liked_at');
    if (!hasLiked) {
      await db.execute(
          'ALTER TABLE user_article_state ADD COLUMN liked_at INTEGER');
    }
    _ensuredLikedColumn = true;
  }

  Future<void> upsertPrefetchedArticleContent(
    String articleGuid,
    String content,
  ) async {
    final db = await database;
    await _ensurePrefetchCacheTable(db);
    await db.insert(
      'article_prefetch_cache',
      {
        'article_guid': articleGuid,
        'content': content,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPrefetchedArticleContent(String articleGuid) async {
    final db = await database;
    await _ensurePrefetchCacheTable(db);
    final rows = await db.query(
      'article_prefetch_cache',
      columns: ['content'],
      where: 'article_guid = ?',
      whereArgs: [articleGuid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['content'] as String?;
  }

  Future<void> _ensurePrefetchCacheTable(Database db) async {
    if (_ensuredPrefetchCacheTable) return;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS article_prefetch_cache (
        article_guid TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
    _ensuredPrefetchCacheTable = true;
  }
}
