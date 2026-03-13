# Development Tooling & Test-Driven Development (TDD)

This document describes the tools and workflows used across the `aware` project, and provides a simple, repeatable Test-Driven Development (TDD) approach.

---

## 🛠️ Project Tooling Overview

### 1) Code formatting and linting

#### Flutter (client)
- Format: `flutter format .`
- Analyze: `flutter analyze`

> The client uses `analysis_options.yaml` (based on `package:flutter_lints`) to enforce idiomatic Dart/Flutter patterns.

#### Node/TypeScript (backend)
- Format: `npm run format` (runs Prettier)
- Lint: `npm run lint` (runs ESLint)

> The backend is configured in `backend/package.json` and uses TypeScript linting rules from `backend/.eslintrc.json`.


### 2) Running the app locally

#### Backend
```bash
cd backend
npm install
npm run dev
```

#### Flutter client
```bash
cd client
flutter pub get
flutter run
```


### 3) CI / automation
- A GitHub Actions workflow is configured at: `.github/workflows/ci.yml`
- It runs:
  - backend lint + build
  - flutter analyze + flutter test


---

## ✅ Test-Driven Development (TDD) Guidelines

TDD is a disciplined approach to building software. The recommendation for this repo is to follow **Red → Green → Refactor**.

### 1) Red (write a failing test first)
- Identify the behavior you want (e.g., “Feed items are marked read when opened”).
- Write a new unit/widget/test case that asserts the desired behavior.
- Run tests and confirm it fails (this ensures the test is valid).

### 2) Green (make it pass)
- Implement the smallest change necessary to make the test pass.
- Avoid wide refactors or unrelated improvements on the first pass.
- Run the test suite again to confirm the behavior is now correct.

### 3) Refactor (cleanup)
- Refactor code for readability, performance, or reuse.
- Keep tests green as you refactor.
- Remove duplication and apply lint/format rules.


### 📌 Quick tips
- Keep tests small and focused.
- Prefer deterministic tests (avoid network calls / time-dependent logic).
- Use mocks/fakes or dependency injection for external systems (API, database).
- Add tests for regressions when you fix a bug.


---

## 🧪 Running tests (current setup)

### Flutter client
```bash
cd client
flutter test
```

### Backend (future)
Currently, the backend does not have automated tests defined yet. Adding a test runner (e.g., Jest) is a recommended next step.
