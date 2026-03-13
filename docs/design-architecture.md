# Architecture & Components

## High-Level Architecture

### Layers
- **Presentation Layer:** Mobile client (Flutter) that talks to the API
- **API Layer:** REST/GraphQL service that handles user requests, authentication, and synchronization
- **Processing Layer:** Background worker service(s) for fetching feeds, parsing content, and sending notifications
- **Data Layer:** Database(s) for storing users, feeds, articles, and state

## Key Components

### Feed Fetcher
- Polls feed URLs on a schedule
- Supports incremental fetching (ETag/Last-Modified)
- Handles feed format variations and errors
- Emits normalized items into the system

### Content Parser & Enrichment
- Parses HTML to extract main content (e.g., readability algorithm)
- Sanitizes HTML to prevent XSS
- Extracts metadata (images, published date, authors)

### Article Store
- Stores normalized item data with pointers to original feed
- Indexes text for search
- Tracks read/unread status per user

### Sync Engine
- Manages user state (read markers, subscriptions)
- Provides endpoints for clients to sync state efficiently
- Can use incremental sync tokens / delta sync APIs

### Notification Engine
- Sends push notifications for new items
- Allows user-configured triggers (e.g., keyword match)

## Technology Options (Example Stack)
- Backend: Node.js + TypeScript (or Python/Go/Java) API server
- Database: PostgreSQL (relational) + Redis (cache, job queue)
- Search: PostgreSQL full-text / Elasticsearch / Meilisearch
- Message Queue: Redis Streams / RabbitMQ / Kafka
- Mobile: Flutter (iOS + Android) as the primary client
- Client DB: Local SQLite (see `client-schema.md`)
- Server DB: PostgreSQL (see `database-schema.md`)

## Client vs Server Responsibilities

> **MVP philosophy:** keep server-side logic minimal; do as much as possible on the client, with server only supporting sync, authorization, and optional proxying when needed.

### Client-side (Flutter)
- UI rendering and navigation (feed lists, article reader, settings)
- Local persistence (SQLite/NoSQL store) for offline reading and cache
- Feed fetching & parsing when CORS and network policies allow (direct RSS/Atom retrieval)
- Optional sync logic (delta sync / backup) for multi-device support; core MVP can run fully offline
- UI gestures and touch interactions (swipe actions, pull-to-refresh)
- Local notifications based on background fetch
- Local search (offline) and optional remote search via API
- User-curated content management (marketplace feeds, custom feeds)
- Input validation for local forms (subscription URLs, settings)

### Server-side (API + Backend Services)
- User authentication & authorization (tokens, sessions, OAuth)
- Optional sync endpoints (read/star state) for multi-device support
- Optional feed proxying service for feeds that require a server-side fetch (CORS, auth-protected feeds)
- Marketplace feed catalog (curated feed list + categories)
- Optional notification dispatch (push tokens, email digest delivery) if push/email is enabled
- Minimal background jobs (marketplace updates, cleanup tasks)
