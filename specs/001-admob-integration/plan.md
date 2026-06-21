---
layout: plan
status: draft
---

# AdMob Integration — Implementation Plan

## Phase 1: Configuration Layer

**Files:** `lib/services/ad_config.dart`

- Create `AdConfig` class with static instances for test/production.
- Read `admob_mode` from `--dart-define` (default: `test`).
- Use Google's published test ad unit IDs:
  - Native: `ca-app-pub-3940256099942544/2247696110`
  - Banner: `ca-app-pub-3940256099942544/6300978111`

## Phase 2: Ad Service

**Files:** `lib/services/ad_service.dart`

- Create `AdService` singleton that manages ad lifecycle.
- Methods: `initAdMob()`, `loadNativeAd()`, `loadBannerAd()`.
- Handle load failures gracefully (return null / no-op).
- Observe TTS state to toggle banner visibility.

## Phase 3: Ad Banner Widget

**Files:** `lib/widgets/ad_banner.dart`

- StatefulWidget wrapping `AdWidget` with a `BannerAd`.
- Listens to TTS state from `SyncProvider` (or equivalent).
- Disposes the ad on widget dispose.

## Phase 4: Native Ad Tile Widget

**Files:** `lib/widgets/native_ad_tile.dart`

- StatefulWidget wrapping `AdWidget` with a `NativeAd`.
- Matches article card styling (Card, ListTile-like layout).
- Supports dark mode.

## Phase 5: Wire into Article List Screen

**Files:** `lib/screens/article_list_screen.dart`

- In `build` or list builder, insert a `NativeAdTile` every 5 items.
- Use `(index + 1) % 5 == 0` to trigger ad placement.

## Phase 6: Wire into Reader Screen

**Files:** `lib/screens/reader_screen.dart`

- In the `Scaffold` bottom widget, conditionally render `AdBanner`.
- Banner visible when TTS is not active.
- Banner anchored to bottom via `bottomNavigationBar` or `Stack`.

## Phase 7: Initialize SDK in main.dart

**Files:** `lib/main.dart`

- Call `AdService.instance.initAdMob()` after `WidgetsFlutterBinding.ensureInitialized()`.
- Wrap with try/catch; failure should not crash the app.
