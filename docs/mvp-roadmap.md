# MVP Roadmap

This roadmap outlines the development phases for the mobile feed reader MVP. Assumes 1-2 developers, 3-6 months timeline.

---

## Phase 1: Foundation (Weeks 1-4)
- Set up Flutter project with basic navigation (bottom nav: Feeds, Saved, Settings).
- Implement local persistence (SQLite) for feeds, articles, read/star state.
- Add local search across downloaded articles.
- Add OPML import/export support.
- Basic UI: Home (subscriptions), Article List, Reader view.
- Client-side feed fetching (RSS parsing with `http` + `xml` packages).

**Milestone:** App launches with local feed reading (no backend) and enables search + OPML import/export.

---

## Phase 2: Backend & Sync (Weeks 5-8)
- Set up Node.js/Express backend with PostgreSQL.
- Implement auth endpoints (register/login) + JWT.
- Build marketplace endpoints (categories, feeds).
- Add sync endpoints for read/star state.
- Wire client to backend for auth and sync.

**Milestone:** Users can register, sync state across devices.

---

## Phase 3: Marketplace & Custom Feeds (Weeks 9-12)
- Add Marketplace tab with category browsing and follow.
- Implement Add Feed screen for custom RSS/Atom URLs.
- Handle CORS with optional proxy endpoint.
- Offline mode: cache articles locally.

**Milestone:** Full feed discovery and management.

---

## Phase 4: Monetization & Polish (Weeks 13-16)
- Integrate Google AdMob (banners, interstitials).
- Add subscription logic (in-app purchases via `in_app_purchase`).
- Implement premium features: AI briefs (mock for now), voice read-aloud.
- Polish UI: animations, dark mode, accessibility.
- Testing: unit tests, beta release.

**Milestone:** Launch MVP with free + premium tiers.

---

## Post-MVP (Future)
- Real AI integration (OpenAI API for summaries).
- Push notifications.
- Advanced search.
- Web version.

---

## Risks
- Feed parsing complexity: Test with various RSS formats.
- Sync conflicts: Implement conflict resolution.
- Ad compliance: Ensure GDPR/CCPA for ads.