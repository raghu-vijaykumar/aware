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
