# API Specification (MVP)

This document outlines the minimal REST API endpoints for the Feed Reader MVP. The MVP is mobile-first: the client fetches feeds directly, stores articles and user state locally (SQLite), and uses the server primarily for metadata (user accounts, marketplace catalog). Optional sync endpoints exist for future multi-device support.

All endpoints return JSON, use JWT for auth, and are hosted at `https://api.feedreader.com`.

---

## 1. Authentication Endpoints

### POST /auth/register
Register a new user.
- **Body:** `{ "email": "string", "password": "string" }`
- **Response:** `{ "token": "jwt", "user": { "id": "uuid", "email": "string" } }`

### POST /auth/login
Login existing user.
- **Body:** `{ "email": "string", "password": "string" }`
- **Response:** `{ "token": "jwt", "user": { "id": "uuid", "email": "string" } }`

### POST /auth/refresh
Refresh JWT token.
- **Headers:** `Authorization: Bearer <token>`
- **Response:** `{ "token": "new_jwt" }`

---

## 2. Marketplace Endpoints

### GET /marketplace/categories
List available feed categories.
- **Response:** `[ { "id": "string", "name": "Tech" }, ... ]`

### GET /marketplace/feeds
List feeds in a category (paginated).
- **Query:** `?category=tech&page=1&limit=20`
- **Response:** `{ "feeds": [ { "id": "uuid", "title": "string", "url": "string", "description": "string" }, ... ], "total": 100 }`

---

## 3. Sync Endpoints (Optional)

The core MVP is designed for offline-first usage: the client fetches and caches feeds locally, and read/star state is stored on the device. The server provides metadata (user accounts, marketplace catalog) and can optionally store user state for backup or multi-device sync in later versions.

### GET /sync/changes
(Optional) Get delta changes since last sync.
- **Headers:** `Authorization: Bearer <token>`
- **Query:** `?lastSync=2023-01-01T00:00:00Z`
- **Response:** `{ "readStates": [ { "articleId": "uuid", "readAt": "timestamp" } ], "starred": [ ... ] }`

### POST /sync/state
(Optional) Bulk update user state.
- **Headers:** `Authorization: Bearer <token>`
- **Body:** `{ "read": [ "articleId1", "articleId2" ], "starred": [ "articleId3" ] }`
- **Response:** `{ "success": true }`

---

## 4. Search & Import/Export (MVP)

### GET /search
Search across local articles and, optionally, server-side metadata.
- **Query:** `?q=keyword`
- **Response:** `{ "results": [ { "id": "uuid", "title": "string", "snippet": "string", "source": "feed" }, ... ] }`

### POST /subscriptions/import
Import subscriptions from OPML (client uploads file; server can optionally store).
- **Headers:** `Authorization: Bearer <token>`
- **Body:** Multipart/form-data with file field `opml`
- **Response:** `{ "imported": 12, "failed": 0 }`

### GET /subscriptions/export
Export current subscriptions as OPML.
- **Headers:** `Authorization: Bearer <token>`
- **Response:** OPML XML file

---

## 4. Optional Proxy Endpoint

### GET /proxy/feed
Proxy fetch a feed if CORS blocked.
- **Query:** `?url=https://example.com/feed.xml`
- **Response:** Raw RSS/Atom XML

---

## Error Responses
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Invalid/missing token
- `429 Too Many Requests`: Rate limited
- `500 Internal Server Error`: Server error

All responses include `{ "error": "message" }` on failure.