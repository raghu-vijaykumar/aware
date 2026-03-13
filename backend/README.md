# aware Backend

This is a minimal Node.js + TypeScript backend for the **aware** feed reader app.

## Getting Started

1. Copy `.env.example` to `.env` and update values:
   ```
   cp .env.example .env
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run in dev mode:
   ```bash
   npm run dev
   ```

## API Endpoints

### Auth
- `POST /auth/register` — register
- `POST /auth/login` — login
- `POST /auth/refresh` — refresh token

### Marketplace
- `GET /marketplace/categories`
- `GET /marketplace/feeds?category=...&page=1&limit=20`

### Sync
- `GET /sync/changes?lastSync=...`
- `POST /sync/state` (body: `{ read: [...], starred: [...] }`)

### Proxy
- `GET /proxy/feed?url=...`

## Database

This backend expects a PostgreSQL database. Use `database-schema.md` in `docs/` as a reference schema.
