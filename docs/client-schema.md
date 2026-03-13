# Client Database Schema (Local SQLite)

This document defines the SQLite schema for the Flutter client. Handles local persistence for feeds, articles, and user state. Syncs with server for shared data.

---

## Tables

### feeds
Stores subscribed feeds (local copy).
```sql
CREATE TABLE feeds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  url TEXT UNIQUE NOT NULL,
  title TEXT,
  description TEXT,
  site_url TEXT,
  icon_url TEXT,
  last_fetched INTEGER,  -- Timestamp
  etag TEXT,
  last_modified TEXT
);
```

### articles
Stores fetched articles locally.
```sql
CREATE TABLE articles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  feed_id INTEGER REFERENCES feeds(id),
  guid TEXT UNIQUE NOT NULL,  -- Article GUID
  url TEXT,
  title TEXT,
  summary TEXT,
  content TEXT,
  author TEXT,
  published_at INTEGER,  -- Timestamp
  fetched_at INTEGER,
  image_url TEXT,
  raw_data TEXT  -- Optional JSON
);
```

### user_article_state
Local read/star state.
```sql
CREATE TABLE user_article_state (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  article_guid TEXT UNIQUE NOT NULL,
  read_at INTEGER,
  starred_at INTEGER,
  tags TEXT  -- Comma-separated
);
```

### folders
User-created folders for organizing feeds.
```sql
CREATE TABLE folders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  parent_id INTEGER REFERENCES folders(id)
);
```

### feed_folders
Many-to-many for feeds in folders.
```sql
CREATE TABLE feed_folders (
  feed_id INTEGER REFERENCES feeds(id),
  folder_id INTEGER REFERENCES folders(id),
  PRIMARY KEY (feed_id, folder_id)
);
```

### marketplace_cache
Cached marketplace data (optional).
```sql
CREATE TABLE marketplace_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT,
  feed_data TEXT,  -- JSON blob
  cached_at INTEGER
);
```

---

## Indexes
- `feeds(url)`
- `articles(feed_id, published_at)`
- `user_article_state(article_guid)`

---

## Notes
- Uses INTEGER for timestamps (Unix epoch).
- Syncs read/star state with server via API.
- Articles are cached locally; no server storage for content.