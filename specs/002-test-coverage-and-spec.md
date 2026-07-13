---
layout: spec
status: in-progress
---

# Test Coverage & Feature Specification

## Problem

Aware lacks systematic test coverage. Most features have no tests at all,
making refactoring risky and bug detection manual. Current measured coverage
is **21.2%** across the Dart client (214 tests, 1468/6933 lines) and ~42% on the
backend (1 test file). The goal is 95% line/branch coverage across the
Dart client and 80% on the backend.

**Note:** Generated localization files (`lib/l10n/app_localizations_*.dart`,
~230 lines each × 12 languages) are excluded from coverage targets.
These should be filtered out in CI via `lcov --remove`.

This document inventories every existing feature, maps current test coverage,
and specifies the tests needed to close the gap.

## Prerequisites

Before test implementation begins, the following dependencies must be added:

| Dependency | Package | Purpose |
|-----------|---------|---------|
| mocktail | `mocktail: ^1.0.4` | Mocking for providers, services, screens |
| lcov | system tool (`brew install lcov`, `apt install lcov`, or `choco install lcov`) | Coverage report parsing for CI gate |

Add to `client/pubspec.yaml` under `dev_dependencies`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  flutter_launcher_icons: ^0.14.1
```

## Feature Inventory & Coverage Gap Analysis

### Legend

| Icon | Meaning |
|------|---------|
| ✅    | Tested |
| ◐    | Partially tested |
| ❌    | Not tested |
| N/A  | Not applicable (config/constants) |

---

### Layer 1: Models

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 1 | **Article model** | `models/article.dart` | ✅ | 7 | toMap, fromMap, round-trip, copyWith, null handling |
| 2 | **Feed model** | `models/feed.dart` | ❌ | 0 | toMap, fromMap, paused bool conversion, null fields |
| 3 | **UserArticleState model** | `models/user_article_state.dart` | ❌ | 0 | toMap, fromMap, readProgress double conversion, null fields |
| 4 | **ReaderPlaybackSnapshot model** | `services/reader_audio_service.dart` | ❌ | 0 | copyWith, .idle() constructor, field defaults |

---

### Layer 2: Services

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 5 | **DatabaseService - Schema** | `services/database_service.dart` | ❌ | 0 | _onCreate, _onUpgrade (versions 2,3,5), _onOpen column migration |
| 6 | **DatabaseService - Feed CRUD** | `services/database_service.dart` | ◐ | 3 | insert/getFeeds, setFeedPaused, deleteFeed done; missing: updateFeed, bulk operations |
| 7 | **DatabaseService - Article CRUD** | `services/database_service.dart` | ◐ | 3 | insert/getForFeed/pagination/count done; missing: getAllArticles, getAllArticleGuids, updateArticleContent, edge cases |
| 8 | **DatabaseService - User State CRUD** | `services/database_service.dart` | ◐ | 2 | insert/getUserState/replace done; missing: getAllUserState, getStarredArticleGuids, getStarredArticles, getReadArticleGuids, edge cases |
| 9 | **FeedService - URL validation** | `services/feed_service.dart` | ❌ | 0 | Invalid URLs, unsupported schemes, edge cases |
| 10 | **FeedService - fetchFeedMetadata** | `services/feed_service.dart` | ❌ | 0 | RSS XML parsing, HTTP errors, malformed XML, missing fields |
| 11 | **FeedService - fetchArticles** | `services/feed_service.dart` | ❌ | 0 | RSS items, Atom entries, enclosure parsing, media:content, date parsing |
| 12 | **FeedService - _parseDate** | `services/feed_service.dart` | ❌ | 0 | 15+ date formats, ISO-8601, RFC-2822, HTTP dates, null/empty input |
| 13 | **FeedService - fetchFullArticle** | `services/feed_service.dart` | ❌ | 0 | Readability extraction, fallback HTML scraping, noise pattern removal, HTTP errors |
| 14 | **ReaderAudioHandler - queue management** | `services/reader_audio_service.dart` | ✅ | 5 | configureQueue, index clamping, hasContentFor |
| 15 | **ReaderAudioHandler - activate article** | `services/reader_audio_service.dart` | ◐ | 4 | activateArticle tested with autoplay; missing: no-op for same index, empty article list, TTS stop error handling |
| 16 | **ReaderAudioHandler - pending autoplay** | `services/reader_audio_service.dart` | ✅ | 3 | pendingAutoplay triggers, deferred content, index changed skip |
| 17 | **ReaderAudioHandler - play/pause/stop** | `services/reader_audio_service.dart` | ◐ | 2 | play/pause flow tested; missing: stop on pending autoplay, stop when idle, pause cancels buffering edge cases |
| 18 | **ReaderAudioHandler - skipToNext/Previous** | `services/reader_audio_service.dart` | ✅ | 4 | skip forward/backward, boundary clamping |
| 19 | **ReaderAudioHandler - seek** | `services/reader_audio_service.dart` | ❌ | 0 | Seek to position, no-content edge case, duration zero edge case |
| 20 | **ReaderAudioHandler - updateSpeechConfig** | `services/reader_audio_service.dart` | ❌ | 0 | Rate change, voice change, null voice clearing |
| 21 | **ReaderAudioHandler - progress handler** | `services/reader_audio_service.dart` | ❌ | 0 | Word-level progress, paragraph transitions, word resolution logic, _normalizeWord |
| 22 | **ReaderAudioHandler - completion handler** | `services/reader_audio_service.dart` | ❌ | 0 | Paragraph auto-advance, article completion, auto-play next |
| 23 | **ReaderAudioHandler - _estimatedDurationForContent** | `services/reader_audio_service.dart` | ❌ | 0 | Word counting, rate-based calculation, zero/empty edge cases |
| 24 | **ReaderAudioHandler - _resolveCurrentWord** | `services/reader_audio_service.dart` | ❌ | 0 | Reported word, substring range, plain-text fallback, empty/edge cases |
| 25 | **ReaderAudioHandler - standalone mode** | `services/reader_audio_service.dart` | ❌ | 0 | Standalone vs audio-service backed construction |
| 26 | **ReaderAudioService.ensureInitialized** | `services/reader_audio_service.dart` | ❌ | 0 | Mobile vs desktop vs web branching, re-init guard |
| 27 | **BackgroundFeedWorker.run** | `services/background_feed_worker.dart` | ❌ | 0 | Active feed filtering, GUID dedup, notification trigger, per-feed error isolation |
| 28 | **BackgroundFeedWorker.initialize** | `services/background_feed_worker.dart` | ❌ | 0 | Workmanager init on Android/iOS, web guard |
| 29 | **BackgroundFeedWorker.schedulePeriodicRefresh** | `services/background_feed_worker.dart` | ❌ | 0 | Foreground timer, Workmanager periodic task, platform guards |
| 30 | **NotificationService.ensureInitialized** | `services/notification_service.dart` | ❌ | 0 | Channel creation, permission requests, platform branching, re-init guard |
| 31 | **NotificationService.showNewArticles** | `services/notification_service.dart` | ❌ | 0 | Count <= 0 guard, uninitialized fallback, pluralization, error handling |
| 32 | **ApiService.login/register** | `services/api_service.dart` | ❌ | 0 | HTTP calls, null server fallback, error responses |
| 33 | **ApiService.getMarketplaceCategories/Feeds** | `services/api_service.dart` | ❌ | 0 | HTTP calls, null server fallback, pagination |
| 34 | **ApiService.proxyFeed** | `services/api_service.dart` | ❌ | 0 | No-server throw, HTTP call |
| 35 | **ApiService.syncState/getSyncChanges** | `services/api_service.dart` | ❌ | 0 | Auth headers, request/response marshalling |
| 36 | **StorageService** | `services/storage_service.dart` | ❌ | 0 | Read/write/delete through secure storage, SharedPreferences fallback, _canUseSecureStorage |
| 37 | **AdService** | `services/ad_service.dart` | ❌ | 0 | initAdMob guard, loadNativeAd, loadBannerAd |
| 38 | **AdConfig** | `services/ad_config.dart` | N/A | - | Config-only; compile-time constant selection |
| 39 | **AppConfig** | `config.dart` | ❌ | 0 | init from env var, init from config.json fallback, re-init guard |
| 40 | **FirebaseService** | `services/firebase_service.dart` | ❌ | 0 | Platform guards, error recording, user identity, custom keys |
| 41 | **OpmlService.extractFeedUrls** | `services/opml_service.dart` | ❌ | 0 | OPML XML parsing, URL dedup, missing/invalid entries |
| 42 | **OpmlService.buildOpml** | `services/opml_service.dart` | ❌ | 0 | XML generation, title escaping, empty feed list |

---

### Layer 3: Providers

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 43 | **FeedProvider.loadFeeds** | `providers/feed_provider.dart` | ❌ | 0 | DB delegation, notifyListeners |
| 44 | **FeedProvider.addFeedFromUrl** | `providers/feed_provider.dart` | ❌ | 0 | URL validation, metadata fetch, article fetch, error handling |
| 45 | **FeedProvider.deleteFeed** | `providers/feed_provider.dart` | ❌ | 0 | DB delegation, reload, notifyListeners |
| 46 | **FeedProvider.setFeedPaused** | `providers/feed_provider.dart` | ❌ | 0 | DB delegation, reload, notifyListeners |
| 47 | **ArticleProvider state cache** | `providers/article_provider.dart` | ❌ | 0 | loadArticleStateCache, getArticleState, cache miss |
| 48 | **ArticleProvider markRead/Liked/Starred** | `providers/article_provider.dart` | ❌ | 0 | Preserves existing fields, DB write, cache update, notifyListeners |
| 49 | **ArticleProvider.recordArticleProgress** | `providers/article_provider.dart` | ❌ | 0 | Last accessed, progress, paragraph index - all updated |
| 50 | **ArticleProvider getStarredArticles** | `providers/article_provider.dart` | ❌ | 0 | DB delegation |
| 51 | **AuthProvider.load** | `providers/auth_provider.dart` | ❌ | 0 | Token/email restoration, notifyListeners |
| 52 | **AuthProvider.login** | `providers/auth_provider.dart` | ❌ | 0 | API call, persistence, guard check, error handling |
| 53 | **AuthProvider.logout** | `providers/auth_provider.dart` | ❌ | 0 | State reset, storage deletion, notifyListeners |
| 54 | **SettingsProvider.load** | `providers/settings_provider.dart` | ❌ | 0 | All 8 settings from SharedPreferences, legacy rate migration, locale fallback |
| 55 | **SettingsProvider setters (8)** | `providers/settings_provider.dart` | ❌ | 0 | Each setter: clamping, persistence, notifyListeners |
| 56 | **SettingsProvider.speechRateTts** | `providers/settings_provider.dart` | ❌ | 0 | Computed getter with rate * base, clamping |
| 57 | **SyncProvider.syncState** | `providers/sync_provider.dart` | ❌ | 0 | Guard check, auth requirement, state partitioning, API call, isSyncing flag |
| 58 | **AppState.init** | `providers/app_state.dart` | ❌ | 0 | Sequential init: auth → settings → seed → article cache → feeds |
| 59 | **AppState._seedMockDataIfEmpty** | `providers/app_state.dart` | ❌ | 0 | Debug mode guard, existing feed check, per-feed error isolation |
| 60 | **AppState facade delegation** | `providers/app_state.dart` | ❌ | 0 | All 20+ facade methods delegate correctly to sub-providers |
| 61 | **AppState sub-provider listener wiring** | `providers/app_state.dart` | ❌ | 0 | addListener wireup, dispose cleanup |

---

### Layer 4: Screens

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 62 | **SplashScreen** | `screens/splash_screen.dart` | ✅ | 1 | Widget test: app launches, shows "aware" and tagline |
| 63 | **OnboardingScreen - page navigation** | `screens/onboarding_screen.dart` | ❌ | 0 | 4-page flow, page indicator, skip button, completion |
| 64 | **OnboardingScreen - language selector** | `screens/onboarding_screen.dart` | ❌ | 0 | Dropdown, 12 languages, AppState.setLocale |
| 65 | **OnboardingScreen - completion persistence** | `screens/onboarding_screen.dart` | ❌ | 0 | StorageService write + HomeScreen navigation |
| 66 | **HomeScreen - bottom navigation** | `screens/home_screen.dart` | ❌ | 0 | 3 tabs, tab switching, FeedList rendering |
| 67 | **HomeScreen - add feed dialog** | `screens/home_screen.dart` | ❌ | 0 | Dialog opens, URL input validation, success/error snackbar |
| 68 | **ArticleListScreen - load & pagination** | `screens/article_list_screen.dart` | ❌ | 0 | Initial load, infinite scroll, loading/error states, empty state |
| 69 | **ArticleListScreen - date grouping** | `screens/article_list_screen.dart` | ❌ | 0 | Date-grouped sections, sticky headers |
| 70 | **ArticleListScreen - search** | `screens/article_list_screen.dart` | ❌ | 0 | Search bar, query filtering, clear |
| 71 | **ArticleListScreen - filter drawer** | `screens/article_list_screen.dart` | ❌ | 0 | 6 filter dimensions, apply/reset |
| 72 | **ArticleListScreen - article actions** | `screens/article_list_screen.dart` | ❌ | 0 | Swipe-to-read/star, like, save, share |
| 73 | **ArticleListScreen - ad insertion** | `screens/article_list_screen.dart` | ❌ | 0 | NativeAd at every 5th position |
| 74 | **ArticleListScreen - Continue Reading FAB** | `screens/article_list_screen.dart` | ❌ | 0 | FAB visibility, resume navigation |
| 75 | **MarketplaceScreen - curated feed loading** | `screens/marketplace_screen.dart` | ❌ | 0 | JSON asset parsing, category grouping |
| 76 | **MarketplaceScreen - category filters** | `screens/marketplace_screen.dart` | ❌ | 0 | Color-coded chips, filter application |
| 77 | **MarketplaceScreen - search** | `screens/marketplace_screen.dart` | ❌ | 0 | Search by feed title, clear |
| 78 | **MarketplaceScreen - subscribe/follow** | `screens/marketplace_screen.dart` | ❌ | 0 | Follow button, feed addition, visual feedback |
| 79 | **MarketplaceScreen - hero stats** | `screens/marketplace_screen.dart` | ❌ | 0 | Count display |
| 80 | **ReaderScreen - PageView article swiper** | `screens/reader_screen.dart` | ❌ | 0 | Swipe between articles, initial index |
| 81 | **ReaderScreen - HTML→markdown conversion** | `screens/reader_screen.dart` | ❌ | 0 | Content rendering |
| 82 | **ReaderScreen - TTS playback controls** | `screens/reader_screen.dart` | ❌ | 0 | Play/pause/seek/prev/next, state subscription |
| 83 | **ReaderScreen - word-level highlighting** | `screens/reader_screen.dart` | ❌ | 0 | Visual highlight during TTS |
| 84 | **ReaderScreen - auto-scroll** | `screens/reader_screen.dart` | ❌ | 0 | Scroll-to-paragraph, auto-scroll resume |
| 85 | **ReaderScreen - WebView mode** | `screens/reader_screen.dart` | ❌ | 0 | Toggle WebView, loading state |
| 86 | **ReaderScreen - auto-mark-read** | `screens/reader_screen.dart` | ❌ | 0 | Progress threshold → markArticleRead |
| 87 | **ReaderScreen - reader onboarding overlay** | `screens/reader_screen.dart` | ❌ | 0 | First-time overlay, step progression |
| 88 | **ReaderScreen - full article fetching** | `screens/reader_screen.dart` | ❌ | 0 | fetchFullArticle on demand, loading state |
| 89 | **SubscriptionsScreen - feed list** | `screens/subscriptions_screen.dart` | ❌ | 0 | Empty state, feed rendering, un/paused indicator |
| 90 | **SubscriptionsScreen - pause/unsubscribe** | `screens/subscriptions_screen.dart` | ❌ | 0 | PopupMenu actions, confirm dialog, list refresh |
| 91 | **LoginScreen** | `screens/login_screen.dart` | ❌ | 0 | Form validation, login flow, error display |
| 92 | **PrivacyPolicyScreen** | `screens/privacy_policy_screen.dart` | ❌ | 0 | Static content rendering |

---

### Layer 5: Widgets

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 93 | **FeedList** | `widgets/feed_list.dart` | ❌ | 0 | Thin ArticleListScreen wrapper |
| 94 | **SettingsScreen - Premium section** | `widgets/settings_screen.dart` | ❌ | 0 | Go Ad-Free card |
| 95 | **SettingsScreen - Voice & Read Aloud** | `widgets/settings_screen.dart` | ❌ | 0 | TTS rate slider, voice selection, auto-play toggle |
| 96 | **SettingsScreen - Accessibility** | `widgets/settings_screen.dart` | ❌ | 0 | Text size slider |
| 97 | **SettingsScreen - Read tracking** | `widgets/settings_screen.dart` | ❌ | 0 | Auto-mark-read toggle + threshold slider |
| 98 | **SettingsScreen - Subscriptions** | `widgets/settings_screen.dart` | ❌ | 0 | Manage, OPML import/export |
| 99 | **SettingsScreen - Themes** | `widgets/settings_screen.dart` | ❌ | 0 | System/Light/Dark selection |
| 100 | **SettingsScreen - Language** | `widgets/settings_screen.dart` | ❌ | 0 | 12-language selection |
| 101 | **SettingsScreen - Legal** | `widgets/settings_screen.dart` | ❌ | 0 | Privacy policy, licenses |
| 102 | **SettingsScreen - Developer** | `widgets/settings_screen.dart` | ❌ | 0 | Test crash button |
| 103 | **AdBanner** | `widgets/ad_banner.dart` | ❌ | 0 | BannerAd lifecycle |
| 104 | **NativeAdTile** | `widgets/native_ad_tile.dart` | ❌ | 0 | NativeAd lazy loading, theming |
| 105 | **SavedArticles** | `widgets/saved_articles.dart` | ❌ | 0 | Starred list, unstar action, ReaderScreen navigation |

---

### Layer 6: App Shell

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 106 | **main() — startup sequence** | `main.dart` | ❌ | 0 | Firebase init, Crashlytics, orientation lock, FFI init, notification init, background worker, AdMob init, post-launch services |
| 107 | **MultiProvider wiring** | `main.dart` | ❌ | 0 | 6 ChangeNotifierProviders, AppState construction and init |
| 108 | **MaterialApp theme/locale** | `main.dart` | ❌ | 0 | Light/dark theme, locale, text scale, localizations delegates |

---

### Layer 7: Backend

| # | Feature | File | Coverage | Test Count | Notes |
|---|---------|------|----------|------------|-------|
| 109 | **Backend — GET / health check** | `backend/src/app.ts` | ✅ | 1 | Returns { status: 'ok' } |
| 110 | **Backend — Auth routes** | `backend/src/` | ❌ | 0 | Register, login, refresh |
| 111 | **Backend — Marketplace routes** | `backend/src/` | ❌ | 0 | Categories, feeds |
| 112 | **Backend — Sync routes** | `backend/src/` | ❌ | 0 | State push, changes pull |
| 113 | **Backend — Feed proxy** | `backend/src/` | ❌ | 0 | Feed proxying |

---

## Summary Statistics

| Category | Total Features | Tested | Partial | Not Tested | Actual Tests | Lines | Covered | Coverage |
|----------|---------------|--------|---------|------------|-------------|-------|---------|----------|
| Models | 4 | 3 | 0 | 1 | 15 | 96 | 96 | 100.0% |
| Services | 38 | 8 | 6 | 24 | 107 | 801 | 573 | 71.5% |
| Providers | 19 | 6 | 0 | 13 | 54 | 307 | 280 | 91.2% |
| Screens | 31 | 4 | 2 | 25 | 22 | 2243 | 275 | 12.3% |
| Widgets | 13 | 0 | 0 | 13 | 0 | 515 | 3 | 0.6% |
| App Shell | 3 | 0 | 0 | 3 | 0 | 66 | 29 | 43.9% |
| Backend | 5 | 1 | 0 | 4 | 1 | 141 | 59 | 41.8% |
| **Total client** | **108** | **21** | **8** | **79** | **214** | **4028** | **1259** | **31.3%†** |
| **Total (all)** | **113** | **22** | **8** | **83** | **215** | — | — | — |

† Excluding generated l10n files (4147 total lines). Actual client coverage including l10n: 1468/6933 = 21.2%.

---

## Test Implementation Plan (Target: 95% Client Coverage)

### Phase 0: Testing Infrastructure (priority: high)
Target: tooling ready before tests are written

| Task | Details | Effort |
|------|---------|--------|
| Add `mocktail` dependency | `flutter pub add --dev mocktail` | Trivial |
| Install `lcov` | `choco install lcov` (Windows), `brew install lcov` (macOS), `apt install lcov` (Linux) | Trivial |
| Verify `flutter test --coverage` works | Run once, confirm `coverage/lcov.info` is generated | Trivial |

### Testing Patterns

**DatabaseService tests** require FFI initialization in `setUpAll`:
```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});
```
Each test group creates a fresh `DatabaseService()` instance in `setUp` for isolation.

**Provider/Screen/Widget tests** use `mocktail` for dependency injection:
```dart
class MockDatabaseService extends Mock implements DatabaseService {}
class MockFeedService extends Mock implements FeedService {}
```
Wrap with `MultiProvider` or `ChangeNotifierProvider` in `MaterialApp` for widget tests.

### Phase 1: Models & Unit Foundations (priority: high)
Target: 100% of model files

| Test File | Features | Est. Tests | Effort |
|-----------|----------|-----------|--------|
| `test/models/feed_test.dart` | Feed: toMap, fromMap, round-trip, paused bool, null fields | 6 | Small |
| `test/models/user_article_state_test.dart` | UserArticleState: toMap, fromMap, round-trip, readProgress double, null fields | 6 | Small |

### Phase 2: Services (priority: high)
Target: 95% of service files

| Test File | Features | Est. Tests | Effort |
|-----------|----------|-----------|--------|
| `test/services/database_service_test.dart` — expand | Add: schema migration, getAllArticleGuids, updateArticleContent, getStarredArticleGuids, getReadArticleGuids, cascade delete verification, getAllArticles, getAllUserState, edge cases | 15 | Medium |
| `test/services/feed_service_test.dart` | URL validation, fetchFeedMetadata, fetchArticles (RSS + Atom), _parseDate (15+ formats), fetchFullArticle, error handling, malformed XML | 20 | Large |
| `test/services/reader_audio_handler_test.dart` — expand | Add: seek, updateSpeechConfig, _resolveCurrentWord, _normalizeWord, _estimatedDurationForContent, completion handler auto-advance, progress handler paragraph transitions, standalone mode, ensureInitialized | 15 | Medium |
| `test/services/background_feed_worker_test.dart` | run: active feed filter, GUID dedup, notification trigger, error isolation; initialize; schedulePeriodicRefresh | 8 | Medium |
| `test/services/notification_service_test.dart` | ensureInitialized: platform branching, re-init guard; showNewArticles: count guards, pluralization, error handling | 6 | Small |
| `test/services/api_service_test.dart` | login, register, marketplace endpoints, proxyFeed, syncState, getSyncChanges, null-server guard, HTTP errors | 12 | Medium |
| `test/services/storage_service_test.dart` | read/write/delete through secure, fallback to SharedPreferences, _canUseSecureStorage | 6 | Small |
| `test/services/opml_service_test.dart` | extractFeedUrls: valid OPML, missing xmlUrl, dedup; buildOpml: empty list, title escaping | 6 | Small |

### Phase 3: Providers (priority: high)
Target: 95% of provider files

| Test File | Features | Est. Tests | Effort |
|-----------|----------|-----------|--------|
| `test/providers/feed_provider_test.dart` | loadFeeds, addFeedFromUrl (valid/invalid URL, DB calls), deleteFeed, setFeedPaused, notifyListeners | 8 | Medium |
| `test/providers/article_provider_test.dart` | Cache load, markRead/Liked/Starred (idempotent, preserves other fields, DB + cache sync), recordArticleProgress, getStarredArticles | 10 | Medium |
| `test/providers/auth_provider_test.dart` | load, login (API + persistence), logout (clear + storage delete), isLoggedIn, isAvailable | 8 | Medium |
| `test/providers/settings_provider_test.dart` | load (all 8 settings + legacy migration + locale fallback), all 8 setters (clamp + persist + notify), speechRateTts computation | 14 | Large |
| `test/providers/sync_provider_test.dart` | syncState: guard, isSyncing flag, read/starred partitioning, API call delegation | 5 | Small |
| `test/providers/app_state_test.dart` | init sequence, _seedMockDataIfEmpty, facade delegation (20+ methods), dispose cleanup, backward-compatible getters | 12 | Large |

### Phase 4: Screens & Widgets (priority: medium)
Target: 90% of screen/widget files (widget tests with mocks)

| Test File | Features | Est. Tests | Effort |
|-----------|----------|-----------|--------|
| `test/screens/splash_screen_test.dart` — expand | Navigates to HomeScreen vs OnboardingScreen based on flag | 2 | Small |
| `test/screens/onboarding_screen_test.dart` | 4-page flow, language selector, skip button, complete button, StorageService persistence | 6 | Medium |
| `test/screens/home_screen_test.dart` | Tab switching, add-feed dialog flow, error handling | 4 | Medium |
| `test/screens/article_list_screen_test.dart` | Load state, empty state, pagination scroll, search, filter drawer | 8 | Large |
| `test/screens/reader_screen_test.dart` | Content rendering, TTS controls, WebView toggle, auto-mark-read | 6 | Large |
| `test/screens/marketplace_screen_test.dart` | Feed loading, category filter, search, subscribe | 6 | Medium |
| `test/screens/subscriptions_screen_test.dart` | Empty state, feed list, pause/unsubscribe | 4 | Medium |
| `test/widgets/settings_screen_test.dart` | All sections rendered, interactions | 8 | Large |
| `test/widgets/ad_banner_test.dart` | BannerAd lifecycle | 2 | Small |
| `test/widgets/native_ad_tile_test.dart` | Lazy load, themed appearance | 2 | Small |
| `test/widgets/saved_articles_test.dart` | Starred list, unstar, navigation | 3 | Small |

### Phase 5: Backend (priority: low for 95% client coverage)
Target: 80% of backend routes

| Test File | Features | Est. Tests | Effort |
|-----------|----------|-----------|--------|
| `backend/test/auth.test.ts` | Register, login, refresh, validation errors | 8 | Medium |
| `backend/test/marketplace.test.ts` | Categories, feeds (pagination) | 4 | Medium |
| `backend/test/sync.test.ts` | Push state, pull changes | 4 | Medium |
| `backend/test/proxy.test.ts` | Feed proxy endpoint | 2 | Small |

---

## Hard Coverage Gate

Coverage is a **hard CI gate**. Any PR that drops overall or per-package coverage
below the threshold **must fail** and block merge.

### per-file thresholds

| Category | Threshold | Enforcement |
|----------|-----------|-------------|
| Models | ≥95% line | `lcov` per-file check |
| Services | ≥95% line | `lcov` per-file check |
| Providers | ≥95% line | `lcov` per-file check |
| Screens | ≥90% line | `lcov` per-file check |
| Widgets | ≥90% line | `lcov` per-file check |
| App Shell (main.dart, config) | ≥80% line | `lcov` per-file check |
| **Total client** | **≥95% line** | `lcov` aggregate |
| Backend | ≥80% line | Jest `--coverageThreshold` |

### CI pipeline (`.github/workflows/ci.yml`)

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # --- Backend ---
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: backend/package-lock.json

      - name: Backend install & lint
        working-directory: backend
        run: |
          npm ci
          npm run lint || true   # loosen until lint config is stable

      - name: Backend test with coverage
        working-directory: backend
        run: npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'

      # --- Client ---
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.27.x

      - name: Client install
        working-directory: client
        run: flutter pub get

      - name: Client analyze
        working-directory: client
        run: flutter analyze

      - name: Client test with coverage
        working-directory: client
        run: flutter test --coverage

      - name: Install lcov
        run: sudo apt-get update -qq && sudo apt-get install -y -qq lcov

      - name: Check client coverage threshold
        shell: bash
        working-directory: client
        run: |
          # Exclude generated localization files (230 lines × 12 languages)
          lcov --remove coverage/lcov.info 'lib/l10n/app_localizations_*.dart' -o coverage/lcov_filtered.info
          lcov --summary coverage/lcov_filtered.info | tee coverage_summary.txt
          COVERAGE=$(grep 'lines......' coverage_summary.txt | grep -oP '\d+\.\d+(?=%)')
          echo "Client coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 95" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below 95% threshold."
            exit 1
          fi
          echo "✅ Coverage $COVERAGE% passes threshold."

      - name: Verify dart doc
        working-directory: client
        run: dart doc --validate-links 2>&1 | (grep -q warning && echo "❌ Doc warnings found" && exit 1 || echo "✅ Doc clean")
```

New PRs that add untested code or reduce coverage below the threshold will be
rejected. Exceptions require explicit maintainer sign-off with a documented
reason in the PR description.

---

## Code Documentation Standards

All Dart source code **must** include meaningful comments that explain _why_
something is done, not merely _what_ the code does. This applies to every file
in `client/lib/`.

### Rules

1. **Every public class, method, and top-level function** must have a doc comment
   (`///` or `/** */`). The comment should describe the contract — what the
   caller can rely on, any preconditions, any side effects.

   ```dart
   /// Fetches feed metadata from the given URL and returns a [Feed] model.
   ///
   /// Throws [ArgumentError] if the URL is invalid or uses an unsupported
   /// scheme. Throws [Exception] if the HTTP request fails or the response
   /// is not valid XML.
   Future<Feed> fetchFeedMetadata(String url) async { ... }
   ```

2. **Non-obvious implementation details** must have inline comments. Focus on
   _why_ a particular approach was chosen, not what the syntax does.

   ```dart
   // Use a hard reference to avoid GC while the callback is registered
   // with the platform channel.
   _keepAlive = this;
   ```

3. **Workarounds and known issues** must be tagged with the reason and, where
   applicable, a tracking link:

   ```dart
   // TODO(#123): Remove fallback once Flutter 3.28 ships
   // `widget.build(context, null)` fails on web, so we pass a placeholder.
   ```

4. **No self-documenting** comments. Avoid:

   ```dart
   // ❌ Bad — says what, not why
   // Increment the counter.
   counter++;

   // ✅ Good — explains why
   // Increment before the callback fires so the listener sees the new value.
   counter++;
   ```

5. **Section headers** for long files (>200 lines) are encouraged to group
   related logic:

   ```dart
   // ---------------------------------------------------------------------------
   // Feed operations
   // ---------------------------------------------------------------------------
   ```

6. **No stale comments.** If code changes, the comment must be updated or
   removed. Stale comments are worse than no comments.

### Enforcement

- `dart doc` must complete without warnings.
- Code review must verify comment quality — not just presence.
- A `docs/` review step is mandatory for any PR touching `client/lib/`.

---

## Acceptance Criteria

1. All model files have ≥95% line coverage (Article, Feed, UserArticleState)
2. All service files have ≥95% line coverage (DatabaseService, FeedService, ReaderAudioHandler, BackgroundFeedWorker, NotificationService, ApiService, StorageService, OpmlService)
3. All provider files have ≥95% line coverage (FeedProvider, ArticleProvider, AuthProvider, SettingsProvider, SyncProvider, AppState)
4. Screen and widget files have ≥90% line coverage
5. Total client library coverage ≥95% (measured by `flutter test --coverage` + `lcov`)
6. CI pipeline **blocks merge** on coverage below threshold (hard gate)
7. Every public class, method, and top-level function in `client/lib/` has a `///` doc comment
8. `dart doc` produces zero warnings
9. `flutter analyze` reports zero errors
10. All existing tests continue to pass
11. New code must not reduce coverage — any regression is a CI failure

### Progressive Coverage Gate

The CI gate threshold should ramp up as phases complete, not start at 95%:

| Milestone | Gate Threshold | Baseline | Trigger |
|-----------|---------------|----------|---------|
| Phase 0 (infra) | 8% (no regression) | 8.54% | CI pipeline created |
| Phase 1 (models) | 15% | — | model tests merged |
| Phase 2 (services) | 40% | — | service tests merged |
| Phase 3 (providers) | 60% | — | provider tests merged |
| Phase 4 (screens/widgets) | 90% | — | screen/widget tests merged |
| Final | 95% | — | all phases complete |

Update the threshold in `.github/workflows/ci.yml` at each milestone.

## Measurement

```bash
# Install test dependencies
cd client
flutter pub add --dev mocktail

# Client coverage
cd client
flutter test --coverage                            # generates coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html         # optional: HTML report
lcov --summary coverage/lcov.info                   # prints line/branch/function %

# Backend coverage
cd backend
npm test -- --coverage                              # prints summary, generates coverage/

# Doc verification
cd client
dart doc --validate-links 2>&1 | grep warning && echo "Warnings found" || echo "Clean"
```
