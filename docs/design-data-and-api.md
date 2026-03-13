# Data Model & API Surface

This document defines the core data entities and the API surface used by the client and backend.

## Data Model (Core Entities)

### User
- id (UUID)
- email
- passwordHash (or OAuth provider link)
- preferences (poll intervals, notification settings)
- createdAt / updatedAt

### Feed
- id (UUID)
- url
- title
- description
- siteUrl
- language
- iconUrl
- categories/tags
- lastFetchedAt
- etag / lastModified
- status (active, disabled, errored)

### Subscription
- id (UUID)
- userId
- feedId
- folderId (optional)
- addedAt
- sortOrder
- customTitle
- customTags

### Article (Feed Item)
- id (UUID)
- feedId
- guid (feed item ID)
- url
- title
- summary
- content (HTML/plain)
- author
- publishedAt
- fetchedAt
- imageUrl
- rawData (optional JSON blob)

### UserArticleState
- id (UUID)
- userId
- articleId
- readAt
- starredAt
- tags
- sharedAt

### Folder / Tag
- id (UUID)
- userId
- name
- parentFolderId (optional)
- createdAt

---

## API Surface

### Authentication
- `POST /auth/register` (email + password)
- `POST /auth/login` (email + password)
- `POST /auth/refresh` (refresh token)
- OAuth providers (Google, GitHub, etc.)

### Marketplace
- `GET /marketplace/categories` (list feed categories)
- `GET /marketplace/feeds?category=...` (list feeds in category)

### Sync Endpoints
- `GET /sync/changes` (delta sync for client state)
- `POST /sync/last-seen` (update sync cursor)
- `POST /sync/state` (bulk update read/star state)

### Optional Proxy
- `GET /proxy/feed?url=...` (fetch feed if CORS blocked)
