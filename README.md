# aware

**aware** is a modern, minimalist mobile-first feed reader designed for clean reading, easy organization, and optional cross-device sync.

This repository contains the project documentation and planning assets. The actual client and backend codebases are intended to live in dedicated subfolders (e.g., `client/`, `backend/`).

## 📚 Docs
All design and product docs live under `docs/`:

- `docs/design.md` — entry point (index) for design docs
- `docs/design-overview.md` — vision + product goals
- `docs/design-architecture.md` — architecture & component breakdown
- `docs/design-data-and-api.md` — data model + API
- `docs/ux-design.md` — UX patterns and considerations
- `docs/ui-spec.md` — UI spec (modern/minimalist)
- `docs/design-technical.md` — scaling, security, next steps

## 🚀 Getting Started
The next step is to scaffold the client and backend:

- **Client (Flutter)**: mobile app UI + local persistence (✅ Done in `client/`)
- **Backend (Node/TypeScript)**: auth, marketplace, sync endpoints (✅ Done in `backend/`)

## ✅ Next Tasks
1. Wire Flutter client to backend API (auth + marketplace)
2. Implement feed fetching and RSS parsing in client
3. Add article reader with swipe gestures
4. Test offline sync and background refresh

---

## 🧰 Tooling & Testing
- CI is configured via GitHub Actions: `.github/workflows/ci.yml`
- Development tooling and Test-Driven Development (TDD) guidance: `docs/development-tooling.md`

---

> Note: This repository currently contains planning and design docs only. The codebases will be added as separate modules when development begins.
