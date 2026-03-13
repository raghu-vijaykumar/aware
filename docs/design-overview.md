# Design Overview

This document captures the core vision and features for the **aware** feed reader app.

## Objective
Build a modern, extensible feed reader application that helps users stay up-to-date with the latest content from their favorite websites, blogs, podcasts, and social feeds. The app will aggregate feeds, normalize them to a common format, and present them in a clean, customizable UI with support for saved articles, tags, folders, and real-time updates.

## Key Features (MVP + Beyond)

### Feed Management
- Add/Remove feeds via URL (RSS/Atom) or discovery (website lookup)
- Provide a curated marketplace of recommended feeds by category (tech, news, developer, etc.)
- Allow users to follow marketplace feeds and manage their own curated lists
- Enable adding any RSS/Atom (or other feed formats) not available in the marketplace
- Organize feeds into folders/collections/tags
- Import/export subscriptions (OPML support)
- Batch subscribe to multiple feeds

### Content Aggregation
- Periodic polling of feeds with configurable interval
- Support for real-time notifications via WebSub (PubSubHubbub) where available
- Deduplication of items across feeds
- Content parsing, sanitization, and caching (text + images)

### Reading Experience
- Unified timeline of articles with sorting (newest, oldest, unread)
- Article view (inline with full content or "read later")
- Tinder-style swipe interface: swipe left (previous), right (next), up (full article mode)
- Mark read/unread, starring, saving, and tagging per article
- Touch gestures (swipe to mark read/unread, tap to open, long-press actions)
- Offline reading / local cache for mobile scenarios

### Personalization
- Smart filters to show only unread, starred, or matching tags
- Search across all items (full-text search)
- Saved searches / custom feeds
- Recommendations (optional) based on reading history

### Notifications & Alerts
- Local notifications (mobile) based on background feed fetching and new-article detection
- Push notifications (mobile) require additional server-side integration (push token registration + push service) and are optional for MVP
- Email digests (daily/weekly) require a server-side delivery service and can be added later
- In-app badge counts and sound alerts

### Mobile Focus & Sync
- Mobile app built with Flutter for iOS and Android
- Offline-first design with local persistence and background fetch
- Server stores metadata (user account, marketplace catalog) and can optionally sync user state (read/star) for multi-device support; sync is not required for MVP

---

## Docs Structure
- **Architecture & Components:** `design-architecture.md`
- **Data model & API:** `design-data-and-api.md`
- **UX / UI considerations:** `ux-design.md`
- **UI spec (modern + minimalist):** `ui-spec.md`
- **Technical ops & next steps:** `design-technical.md`
