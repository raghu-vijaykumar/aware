# Database Schema (Server - PostgreSQL)

This document defines the PostgreSQL schema for the feed reader backend. Focuses on minimal tables for auth, marketplace, and sync. Client uses separate local SQLite schema.

---

## Tables

### users
Stores user accounts.
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### marketplace_categories
Curated feed categories.
```sql
CREATE TABLE marketplace_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);
```

### marketplace_feeds
Curated feeds in categories.
```sql
CREATE TABLE marketplace_feeds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id INT REFERENCES marketplace_categories(id),
  title VARCHAR(255) NOT NULL,
  url VARCHAR(500) UNIQUE NOT NULL,
  description TEXT,
  icon_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### user_sync_state
Stores user read/star state for sync.
```sql
CREATE TABLE user_sync_state (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  article_guid VARCHAR(500) NOT NULL,  -- Unique article ID
  read_at TIMESTAMP,
  starred_at TIMESTAMP,
  UNIQUE(user_id, article_guid)
);
```

### subscriptions (optional, for future)
If needed for server-side subscriptions.
```sql
CREATE TABLE subscriptions (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  feed_url VARCHAR(500) NOT NULL,
  added_at TIMESTAMP DEFAULT NOW()
);
```

---

## Indexes
- `users(email)`
- `marketplace_feeds(category_id)`
- `user_sync_state(user_id, article_guid)`

---

## Notes
- Use UUID for user IDs to avoid enumeration.
- The server stores metadata (users, marketplace catalog) and can optionally store sync state for future multi-device support. The MVP client is offline-first and stores articles, read/star state, and subscriptions locally.
- Sync state uses article GUIDs (from RSS) for uniqueness.
- No full article storage is required on the server; the client handles local persistence.
