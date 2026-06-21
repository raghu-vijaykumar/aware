---
layout: tasks
status: draft
---

# AdMob Integration — Tasks

## Configuration

- [ ] Create `lib/services/ad_config.dart` with test/production ID sets.
- [ ] Wire `admob_mode` dart-define flag.
- [ ] Default to test mode when flag is absent.

## Ad Service

- [ ] Create `lib/services/ad_service.dart` singleton.
- [ ] Implement `initAdMob()` with error handling.
- [ ] Implement `loadNativeAd()` returning a `NativeAd?`.
- [ ] Implement `loadBannerAd()` returning a `BannerAd?`.

## Banner Widget

- [ ] Create `lib/widgets/ad_banner.dart`.
- [ ] Wire TTS state visibility toggle.
- [ ] Dispose ad on widget dispose.

## Native Ad Widget

- [ ] Create `lib/widgets/native_ad_tile.dart`.
- [ ] Match article card dark-mode styling.
- [ ] Handle load failures gracefully (empty slot).

## Article List Integration

- [ ] Insert native ad every 5th item in `ArticleListScreen`.
- [ ] Ensure scrolling performance is not degraded.

## Reader Screen Integration

- [ ] Add banner to reader screen `Scaffold`.
- [ ] Conditionally hide during TTS playback.
- [ ] Verify banner does not overlap article text.

## Initialization

- [ ] Initialize AdMob SDK in `main.dart`.
- [ ] Wrap in try/catch to prevent crash on init failure.

## Verification

- [ ] Run `flutter analyze` — 0 errors.
- [ ] Run `flutter test` — all existing tests pass.
- [ ] Manual: verify test ads appear in feed and reader on emulator.
