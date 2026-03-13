-- PostgreSQL schema for aware backend

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS marketplace_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS marketplace_feeds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id INT REFERENCES marketplace_categories(id),
  title VARCHAR(255) NOT NULL,
  url VARCHAR(500) UNIQUE NOT NULL,
  description TEXT,
  icon_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_sync_state (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  article_guid VARCHAR(500) NOT NULL,
  read_at TIMESTAMP,
  starred_at TIMESTAMP,
  UNIQUE(user_id, article_guid)
);
