# Tech Stack (MVP) for Mobile Feed Reader

This document outlines the recommended technology stack for building the MVP of the mobile-first feed reader app (Flutter client + minimal backend).

---

## 1. Mobile Client (Flutter)

### 1.1 Framework
- **Flutter** (stable channel)
  - Single codebase for iOS and Android
  - Strong ecosystem for UI, offline storage, background tasks
  - Good support for plugins (network, notifications, persistence)

### 1.2 Core Packages
- `provider` or `riverpod` for state management
- `http` / `dio` for network requests
- `sqflite` (or `moor`/`drift`) for local persistence
- `xml` for RSS/Atom parsing and OPML import/export
- Optional search helpers (e.g., SQLite FTS) for local full-text search
- `flutter_local_notifications` for push/local alerts
- `workmanager` or `flutter_background_fetch` for periodic background sync
- `flutter_secure_storage` for tokens and sensitive data
- `google_mobile_ads` for ad integration (banner/interstitial)

### 1.3 Architecture
- MVVM / Clean architecture (presentation, domain, data layers)
- Repository pattern for data sources (local + remote)
- Offline-first model with local cache as source-of-truth
- Local SQLite schema (see `client-schema.md`) for persistence
- Server PostgreSQL schema (see `database-schema.md`) for shared data

---

## 2. Backend (Minimal API + Sync)

### 2.1 Recommended Stack
- **Node.js + TypeScript** (Express / Fastify)
- **PostgreSQL** (primary data store)
- **Redis** (caching + optional job queue)

### 2.2 API Design
- REST endpoints (JSON) for sync, authentication, and marketplace
- JWT-based authentication
- Minimal server-side feed fetching (proxy mode) for blocked feeds

### 2.3 Optional Infrastructure
- Docker for local development
- CI/CD: GitHub Actions (lint, test, build)
- Hosted PostgreSQL (e.g., Cloud SQL, RDS) and Redis (e.g., managed Redis)

---

## 3. Marketplace Content
- Store curated feed catalog in the backend (PostgreSQL + optional JSON store)
- Admin tool (CLI or simple admin UI) to manage categories and featured feeds

---

## 4. Developer Tooling
- **Flutter DevTools** + **Dart analysis**
- **ESLint + Prettier** for backend TypeScript
- **Postman / curl** for API testing
- **SQLite browser** for inspecting local client DB during development

---

## 5. Next Steps
1. Scaffold Flutter app with core navigation and local persistence.
2. Scaffold backend service with auth + sync endpoints.
3. Wire client-server sync flow using a small set of API calls.
4. Validate offline read and sync reconciliation.
5. Integrate ad SDK and test ad placements.
