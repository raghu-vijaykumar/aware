# Aware - Project Conventions

## Flutter / Dart
- Use `debugPrint()` over `print()` for debug logging; tag logs with `[ScreenName]` or `[ServiceName]`.
- Prefer `SurfaceContainerHighest` over deprecated `surfaceVariant`.
- Prefer `.withValues()` over deprecated `.withOpacity()`.
- Always add `break` in switch cases to avoid `use_of_void_result`.
- Use `const` constructors where possible.

## Localization (ARB)
- Source of truth: `client/lib/l10n/app_en.arb`.
- Run `flutter gen-l10n` after adding/modifying ARB keys.
- New keys must also be added to translation JSON files in `client/lib/l10n/translations/`.
- For languages without grammatical number (ja, ko, zh), placeholder `count` must have `"type": "num"` in ICU-plural messages.

## Code Style
- Always add meaningful comments to code explaining _why_ something is done, not just _what_.
- Keep responses concise; avoid unnecessary preamble/postamble.
- Follow existing patterns when creating components (same library choices, naming, typing).

## Test Helper Conventions
- `client/test/helpers/` contains `pump_app.dart` for wrapping widgets with providers/themes
- `client/test/helpers/mocks.dart` contains shared mock declarations (MockDatabaseService, etc.)
- `client/test/helpers/` also contains `test_reader_audio_handler.dart` for standalone TTS handler creation
- Always use `pumpApp` instead of `pumpWidget` in widget tests to include proper provider wrapping

## Coverage Notes
- **Overall (excl. l10n)**: 80.5% (3306/4106 lines), **387 tests**.
- **At 100%**: SplashScreen, OnboardingScreen, ArticleProvider, AppState, ArticleModel, FeedModel, UserArticleState, SettingsProvider, AuthProvider, FeedProvider, SyncProvider, HomeScreen, FeedList, OPMLService, AdConfig, PrivacyPolicyScreen, MarketplaceScreen, ApiService, AppTheme, FeedService.
- **DatabaseService**: 97.1% (135/139) — 4 unreachable lines are `_ensureLikedColumn` ALTER TABLE branches that `_onOpen` already covers.
- **AdService**: 90.5% (19/21) — `onAdLoaded` lambdas not triggered by mock channel.
- **SubscriptionsScreen**: 98.4% (60/61) — `Image.network` for `feed.iconUrl` (network/layout issues in test).
- **ArticleListScreen**: 99.7% (719/721) — 2 uncovered: scroll fallback (107) depends on precise pixel positions; `_timelineIndexFor` StateError throw is unreachable dead code.
- **SettingsScreen**: 90.3% (364/403) — import/export subscriptions (130–217, blocked on file_picker/share_plus/path_provider).
- **Url launcher mocking**: `MethodChannel('plugins.flutter.io/url_launcher')` with `'launch'` method.
- **Flutter_tts mocking**: `MethodChannel('flutter_tts')`, respond to `'getVoices'`.
- **Google Mobile Ads mocking**: `MethodChannel('plugins.flutter.io/google_mobile_ads', StandardMethodCodec(AdMessageCodec()))`.
- **Workmanager**: Pigeon-based platform interface; requires `WorkmanagerPlatform` subclass to mock.
- **file_picker/share_plus/path_provider**: All require platform channel mocking; large blocks of settings_screen (108 lines) and article_list_screen (121 lines) depend on these.
- **Key limit**: Real async I/O (sqflite_ffi, platform channels) needs `tester.runAsync()` in widget tests.
- **DB migration tests**: Create DB at older version via `openDatabase(path, version: 1, ...)`, close, then let `DatabaseService().database` trigger `onUpgrade`. Full-suite file contention mitigated by 10-retry loop in `_ensureDbGone`.
- **Image.network** in widget tests causes network errors and layout failures — hard to test without HTTP mocking.
- **AppConfig._()**, **AppTextStyles._()**, **StorageService._()** private constructors are never invoked — permanently 0-coverage lines.

## Git Workflow
- Always commit and push at regular intervals during implementation, not all at once.
- Commit logical units of work as they complete (e.g., one screen's test, one service feature).
- Each commit should represent a coherent, reviewable step.

## Project Structure
- `client/` — Flutter app
- `client/lib/screens/` — screen widgets
- `client/lib/services/` — services (audio, database, etc.)
- `client/lib/providers/` — state providers (ChangeNotifier)
- `client/lib/widgets/` — reusable widgets
- `client/lib/models/` — data models
- `client/lib/l10n/` — localization ARB files and generated Dart
- `client/lib/theme/` — theme configuration
