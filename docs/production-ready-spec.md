# Production Readiness Spec

This document classifies the 22 pending items into two independent tracks:

- **Spec A: Purely Local** — Client-only. Runs on-device with SQLite. No server, no cloud costs, no accounts.
- **Spec B: Self-Hosted Server** — Adds the Node.js backend for auth, sync, proxy, and marketplace API.

The app is designed to work fully in Spec A mode. Spec B is additive.

---

## Spec A: Purely Local

Everything here runs entirely on the device. No backend required.

### A1. Auth tokens in plaintext (Item 4)

**Problem:** `client/lib/services/storage_service.dart` stores tokens in `SharedPreferences` (plaintext). On local-only mode there are no server tokens, but the code still has the pattern ready for when server mode is enabled.

**Fix (local):** Add `flutter_secure_storage` package. Wrap storage access so it transparently falls back to `SharedPreferences` when no secure backend is available (Windows/Linux desktop). This costs nothing and protects tokens on mobile.

**Files:** `client/lib/services/storage_service.dart`, `pubspec.yaml`

---

### A2. Hardcoded API URL → environment config (Item 12)

**Problem:** `client/lib/services/api_service.dart:5` has `http://localhost:4000` hardcoded.

**Fix (local):** Move base URL to a config file (`lib/config.dart`) that reads from:
1. Compile-time `--dart-define` flags (for CI)
2. A local `config.yaml` in the app data directory (allows user to point to their own server)
3. Fallback: `null` (API calls are skipped gracefully when no server is configured)

ApiService should degrade cleanly — when base URL is null, all server-dependent methods return empty/error states without crashing.

**Files:** `client/lib/services/api_service.dart`, new `lib/config.dart`

---

### A3. Marketplace feeds → local curated list (Item 13)

**Problem:** `client/lib/screens/marketplace_screen.dart:33-282` has 40+ feeds hardcoded in Dart. The API marketplace endpoint exists but the UI never calls it.

**Fix (local):** Move hardcoded feeds into a structured JSON asset file (`assets/curated_feeds.json`). The marketplace screen loads from this file by default. When a server is configured and online, it fetches from the API instead and caches the result in SQLite.

This decouples feed curation from code — users can edit the JSON file on desktop, or we can ship updated assets without a Play Store release.

**Files:** `client/lib/screens/marketplace_screen.dart`, new `assets/curated_feeds.json`, `pubspec.yaml`

---

### A4. Folder management UI (Item 14)

**Problem:** Database has `folders` and `feed_folders` tables but zero UI to create, rename, or organise feeds into folders.

**Fix (local):** Add a folder management layer:
- `FolderListScreen` — list/create/rename/delete folders
- Feed subscription dialog gains "Move to folder" dropdown
- Home screen shows folder groups (expandable) alongside uncategorised feeds
- All state persisted to SQLite via existing tables

**Files:** New `client/lib/screens/folders_screen.dart`, modify `client/lib/screens/home_screen.dart`, `client/lib/providers/app_state.dart`

---

### A5. Push notifications (Item 15)

**Problem:** Only local notifications exist. No push infrastructure.

**Fix (local):** For purely local mode, local notifications are sufficient and correct. No change needed. The existing `notification_service.dart` + `background_feed_worker.dart` already deliver local notifications for new articles found during background refresh.

If server mode is added later, FCM can be integrated as a separate effort (Firebase is free).

**Files:** None (already works for local mode).

---

### A6. Search UI (Item 16)

**Problem:** Full-text search is documented but no search bar exists in the UI.

**Fix (local):** Add:
- Search icon in the app bar on the Feeds/Article List screens
- Search delegate that queries SQLite FTS (the `articles` table can have a virtual FTS5 table or use `LIKE` on title/summary/content)
- Results rendered in the existing article list tile
- "Clear search" and recent searches in-memory

**Files:** `client/lib/screens/home_screen.dart`, `client/lib/screens/article_list_screen.dart`, `client/lib/services/database_service.dart`

---

### A7. Onboarding flow (Item 17)

**Problem:** App starts → splash → home. No first-run tutorial, no permissions onboarding.

**Fix (local):** Add a 3-page indicator-based onboarding shown only on first launch:
1. **Welcome** — branding + tagline
2. **How it works** — "Add feeds, read offline, listen with TTS"
3. **Permissions** — notification permission request + shortcut to add first feed

Track completion in `SharedPreferences` (`onboarding_complete`). Skip if returning user.

**Files:** New `client/lib/screens/onboarding_screen.dart`, modify `client/lib/screens/splash_screen.dart`, `client/lib/services/storage_service.dart`

---

### A8. Pagination in article list (Item 19)

**Problem:** `client/lib/screens/article_list_screen.dart` loads all articles into memory at once.

**Fix (local):** Implement lazy loading with SQLite `LIMIT`/`OFFSET`:
- Load initial batch (e.g. 50 articles)
- Add scroll listener — when within 200px of bottom, fetch next batch
- Show a subtle loading indicator at the list bottom during fetch
- Keep `_articles` as a lazy-loading list in AppState (or a dedicated provider)

**Files:** `client/lib/screens/article_list_screen.dart`, `client/lib/providers/app_state.dart`, `client/lib/services/database_service.dart`

---

### A9. Monolithic AppState refactor (Item 20)

**Problem:** `client/lib/providers/app_state.dart:14-444` is a single 444-line ChangeNotifier handling feeds, auth, TTS, sync, settings, and article state.

**Fix (local):** Split into focused providers:

| Provider | Responsibility |
|----------|---------------|
| `FeedProvider` | Feed subscriptions, add/remove/pause, folder assignments |
| `ArticleProvider` | Article list, filters, pagination, read/star state |
| `ReaderProvider` | Current article, TTS state, progress, swipe navigation |
| `SettingsProvider` | Theme, data mode, TTS voice/speed, accessibility |
| `SyncProvider` | Server sync (only when server is configured) |
| `AuthProvider` | Login/register/tokens (only when server is configured) |

Use `MultiProvider` in `main.dart`. This makes testing easier and reduces unnecessary rebuilds.

**Files:** `client/lib/providers/app_state.dart` → multiple files in `client/lib/providers/`

---

### A10. Client tests (Item 22)

**Problem:** Single widget test checking for "Feeds" text. No unit tests for services or providers.

**Fix (local):** Add tests targeting local-only code paths:
- `DatabaseService` — CRUD for feeds, articles, user state (use `sqflite_common_ffi` on desktop/CI)
- `FeedService` — RSS/Atom parsing with fixture XML files
- `OpmlService` — import/export round-trip
- `StorageService` — read/write/clear
- Each new provider — state transitions, filter logic
- Widget tests — onboarding screen, empty states, folder list

**Files:** New files under `client/test/` mirroring `client/lib/` structure

---

## Spec B: Self-Hosted Server

Everything here requires the Node.js backend to be running. The client is already architected to talk to it — these fixes make it safe and reliable.

### B1. SSRF / Open proxy fix (Item 1)

**Problem:** `backend/src/routes/proxy.ts:12` calls `fetch(url)` on arbitrary user-supplied URLs with no allowlist. This is an open proxy that can hit internal services (cloud metadata, Redis, the DB itself).

**Fix:** 
- Add a URL allowlist (only `http://` and `https://`, block private IP ranges (`10.x`, `172.16-31.x`, `192.168.x`, `127.x`, `169.254.x`))
- Require authentication on the proxy endpoint
- Add rate limiting specific to the proxy route
- Add a timeout floor (minimum 1s, maximum 15s — already partially done)
- Block common cloud metadata endpoints (`/latest/meta-data/`, etc.) via pattern check
- Validate that the response Content-Type starts with `text/xml`, `application/xml`, `application/atom+xml`, `application/rss+xml` — reject non-feed responses

**Files:** `backend/src/routes/proxy.ts`, `backend/src/middleware/validateUrl.ts` (new)

---

### B2. Rate limiting (Item 2)

**Problem:** No rate limiting anywhere. `/auth/login` is brute-forceable. `/proxy/feed` is a free-for-all.

**Fix:**
- Add `express-rate-limit` package
- General API limiter: 100 req/min per IP
- Auth endpoints: 10 req/min per IP (login/register)
- Proxy endpoint: 30 req/min per IP + per authenticated user
- Store rate limit data in memory (simple for single-process) or optionally Redis if scaling

**Files:** `backend/src/index.ts`, new `backend/src/middleware/rateLimit.ts`

---

### B3. Weak JWT default → validated config (Item 3)

**Problem:** `backend/src/env.ts:8` falls back to `'please-change-me'`. If `.env` is not set, the secret is public.

**Fix:**
- At startup, validate all required env vars
- If `JWT_SECRET` is missing or equals `'please-change-me'`, crash with a clear error: "JWT_SECRET must be set. Generate one with: node -e \"console.log(require('crypto').randomBytes(32).toString('hex'))\""
- Add `NODE_ENV` validation — reject common defaults when `NODE_ENV=production`
- Validate `DATABASE_URL` format and test connectivity at boot

**Files:** `backend/src/env.ts`

---

### B4. Security headers (Item 5)

**Problem:** No helmet.js. No CSP, HSTS, X-Frame-Options, X-Content-Type-Options.

**Fix:**
- Add `helmet` package with strict defaults
- Set CSP to restrict script/style sources to self
- Enable HSTS with a 1-year max-age (only in production)
- Disable `X-Powered-By: Express` header

**Files:** `backend/src/index.ts`

---

### B5. Request validation (Item 6)

**Problem:** Auth routes have manual `if (!email || !password)` checks. No typed validation. Proxy URL has zero validation.

**Fix:**
- Add `zod` package for runtime validation
- Login body: `z.object({ email: z.string().email(), password: z.string().min(8).max(128) })`
- Register body: same + optional `displayName`
- Refresh body: `z.object({ refreshToken: z.string() })`
- Proxy query: `z.object({ url: z.string().url() })`
- Marketplace query: `z.object({ category: z.string().optional(), page: z.coerce.number().int().positive().default(1) })`
- Sync body: full schema validation for article state objects
- Return 422 with structured error messages on validation failure

**Files:** New `backend/src/middleware/validate.ts`, modify all route files

---

### B6. CORS restrictions (Item 7)

**Problem:** `app.use(cors())` with no options allows all origins.

**Fix:**
- In production: restrict to known origins (e.g., the Flutter web domain, or the app's custom scheme)
- In development: allow localhost origins
- Set `credentials: true` if cookies/session tokens are used

**Files:** `backend/src/index.ts`, `backend/src/env.ts`

---

### B7. Database migrations (Item 8)

**Problem:** `backend/src/db.ts` creates a pool. No migration system. Tables must be created by hand.

**Fix:**
- Use `node-pg-migrate` for simple file-based migrations
- Directory: `backend/migrations/`
- Migration 001: create `users`, `refresh_tokens` tables
- Migration 002: create `marketplace_categories`, `marketplace_feeds` tables
- Migration 003: create `sync_state` table
- Run migrations at startup (or via `make migrate`)
- Add a `make migrate-down` for rollbacks

**Files:** New `backend/migrations/` directory, `backend/src/db.ts`, `Makefile`

---

### B8. Docker setup (Item 9)

**Problem:** No Dockerfile or docker-compose.yml despite being in tech-stack docs.

**Fix:**
- `backend/Dockerfile` — multi-stage: `npm ci` → build → `node dist/index.js`
- `backend/Dockerfile.dev` — hot-reload with `ts-node-dev`
- `docker-compose.yml` at repo root:
  - `api` service (backend)
  - `db` service (postgres:16-alpine)
  - Volume for DB data persistence
  - `.env` file injection
- `docker-compose.prod.yml` — adds health checks, restart policy, resource limits

**Files:** `backend/Dockerfile`, `backend/Dockerfile.dev`, `docker-compose.yml`, `docker-compose.prod.yml`

---

### B9. CI/CD (Item 10)

**Problem:** `.github/workflows/` directory doesn't exist on disk (referenced in docs and Makefile but absent).

**Fix:**
- `.github/workflows/ci.yml`:
  - Trigger: push to main, PRs to main
  - Jobs: lint (ESLint + Prettier), typecheck (tsc), test (jest), build (tsc)
  - Flutter job: analyze + test (using `submodules: false`, just the client dir)
- `.github/workflows/release.yml`:
  - Trigger: tag push (`v*`)
  - Build Docker image, push to registry (ghcr.io)
  - Deploy to server via SSH (placeholder)

**Files:** `.github/workflows/ci.yml`, `.github/workflows/release.yml`

---

### B10. Structured logging (Item 11)

**Problem:** Uses `console.log` only. No request logging, no structured output.

**Fix:**
- Add `pino` + `pino-http` for structured JSON logging
- Development: pretty-print via `pino-pretty`
- Add request ID middleware (correlation IDs for tracing)
- Log: request method/path/duration/status, DB query errors, auth failures, proxy request summary (URL host, status, bytes)
- Never log: passwords, tokens, article content

**Files:** `backend/src/index.ts`, new `backend/src/middleware/logger.ts`

---

### B11. Email verification / password strength (Item 18)

**Problem:** Registration returns JWT immediately. Any non-empty password accepted.

**Fix:**
- Password: enforce `z.string().min(8).max(128).regex(/[A-Z]/).regex(/[a-z]/).regex(/[0-9]/)`
- Registration: create user as `unverified`, return `{ message: "Check your email" }`
- Add email verification flow:
  - Generate verification token, store in `users.email_verification_token`
  - `POST /auth/verify-email?token=xxx` — sets `email_verified_at`
  - `POST /auth/resend-verification` — rate limited to 1/min
- For MVP, print verification URL to console (no real email sending). Add a config flag `SKIP_EMAIL_VERIFICATION` for local dev.

**Files:** `backend/src/routes/auth.ts`, database migration for `users.email_verification_token` and `email_verified_at`

---

### B12. Backend tests (Item 21)

**Problem:** `test/app.test.ts` has 1 test checking `GET /` returns `ok`.

**Fix:**
- Use `testcontainers` for a real PostgreSQL instance in CI (or mock with `pg-mem`)
- Test suites:
  - `auth.test.ts` — register, login, refresh, invalid credentials, duplicate email
  - `marketplace.test.ts` — list categories, filter by category, pagination
  - `proxy.test.ts` — valid feed URL, blocked IP range, missing URL
  - `sync.test.ts` — push state, pull changes, conflict behavior

**Files:** New files under `backend/test/`, update `backend/jest.config.ts`

---

### B13. Auth token security — refresh rotation & logout (bonus)

While not in the original 22, fixing the refresh token flow makes the server secure:

- **Refresh token rotation:** Each `/auth/refresh` call invalidates the old refresh token and issues a new one
- **Server-side logout:** `POST /auth/logout` invalidates the refresh token
- **Token blacklist:** Maintain a set of invalidated JWT `jti` values (in-memory or DB) so immediate logout works

**Files:** `backend/src/routes/auth.ts`, database migration for `refresh_tokens` table

---

## Quick Reference: Item → Spec Mapping

| # | Item | Spec | Effort |
|---|------|------|--------|
| 1 | SSRF / proxy fix | **B** Server | 2 days |
| 2 | Rate limiting | **B** Server | 1 day |
| 3 | Weak JWT default | **B** Server | 0.5 day |
| 4 | Auth tokens in plaintext | **A** Local | 0.5 day |
| 5 | Security headers | **B** Server | 0.5 day |
| 6 | Request validation | **B** Server | 1 day |
| 7 | CORS restrictions | **B** Server | 0.5 day |
| 8 | Database migrations | **B** Server | 1 day |
| 9 | Docker setup | **B** Server | 1 day |
| 10 | CI/CD | **B** Server | 1 day |
| 11 | Structured logging | **B** Server | 1 day |
| 12 | Hardcoded API URL → config | **A** Local | 1 day |
| 13 | Marketplace feeds → local JSON | **A** Local | 1 day |
| 14 | Folder management UI | **A** Local | 2 days |
| 15 | Push notifications | **A** Local | already works |
| 16 | Search UI | **A** Local | 2 days |
| 17 | Onboarding flow | **A** Local | 1 day |
| 18 | Email verification / password strength | **B** Server | 1.5 days |
| 19 | Article pagination | **A** Local | 1 day |
| 20 | Monolithic AppState refactor | **A** Local | 2 days |
| 21 | Backend tests | **B** Server | 2 days |
| 22 | Client tests | **A** Local | 3 days |

**Total Spec A (Local):** ~13.5 days  
**Total Spec B (Server):** ~13 days  
**Total overall:** ~26.5 days (1-2 developers)
