# Developer Checklist (MVP)

This checklist tracks the work needed to ship the MVP for the aware feed reader.

## 1) Project Setup
- [ ] Create `client/` Flutter project
- [ ] Create `backend/` Node+TypeScript project
- [ ] Add workspace-level tooling (prettier, eslint, dartfmt)

## 2) Client (Flutter)
- [ ] Scaffold app with bottom nav (Feeds, Saved, Settings)
- [ ] Implement local SQLite persistence (feeds, articles, read/star state)
- [ ] Build feed fetching + RSS/Atom parsing pipeline
- [ ] Add OPML import/export
- [ ] Implement article reader (swipe deck + full content view)
- [ ] Add search + filters (unread, starred)
- [ ] Add settings (theme, sync toggle, notifications)
- [ ] Integrate ads (banner/interstitial) and premium upgrade flow

## 3) Backend (Node + TypeScript)
- [ ] Create auth endpoints (register/login/refresh)
- [ ] Create marketplace endpoints (categories + feeds)
- [ ] Create optional sync endpoints (read/star state)
- [ ] Add DB migrations (PostgreSQL schema from `database-schema.md`)
- [ ] Add basic logging + error handling

## 4) Integration
- [ ] Connect client auth + marketplace to backend
- [ ] Implement sync (optional) and conflict resolution
- [ ] Add proxy endpoint for CORS-blocked feeds (optional)

## 5) Testing + CI
- [ ] Add unit tests (Flutter + backend)
- [ ] Add integration tests for API endpoints
- [ ] Setup GitHub Actions (lint, test, build)

## 6) Release Prep
- [ ] Prepare app store builds (iOS/Android)
- [ ] Verify privacy & data export workflows
- [ ] Document deployment & run steps
