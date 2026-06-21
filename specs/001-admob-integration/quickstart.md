---
layout: quickstart
status: draft
---

# AdMob Integration — Quickstart

## What Was Built

- `AdConfig` — manages test/production ad unit IDs.
- `AdService` — singleton for AdMob lifecycle (init, load native, load banner).
- `AdBanner` — smart banner widget for the reader screen (hides during TTS).
- `NativeAdTile` — native ad card for the article feed (every 5th position).

## How to Test

### Prerequisites

- A physical Android/iOS device or emulator with Google Play Services.
- The app already has `google_mobile_ads: ^5.0.0` in `pubspec.yaml`.

### Run with Test Ads

```sh
cd client
flutter run --dart-define=admob_mode=test
```

Test ads will appear immediately. They display "Test Mode" labels.

### Verify Behavior

1. **Feed ads:** Scroll the article list. At positions 5, 10, 15, ... you
   should see native ad cards styled like articles.
2. **Banner ads:** Open any article. A smart banner should appear at the
   bottom.
3. **TTS hiding:** Enable text-to-speech on the reader screen. The banner
   should disappear. Stop TTS — it should reappear.

### Run Production

```sh
flutter run --dart-define=admob_mode=production
```

Ensure `AdConfig.production` has your real AdMob unit IDs before building
for release.

## Files Touched

| File | Change |
|------|--------|
| `lib/services/ad_config.dart` | New — ad unit ID configuration |
| `lib/services/ad_service.dart` | New — AdMob lifecycle manager |
| `lib/widgets/ad_banner.dart` | New — bottom banner widget |
| `lib/widgets/native_ad_tile.dart` | New — in-feed native ad widget |
| `lib/screens/article_list_screen.dart` | Modified — insert native ads in list |
| `lib/screens/reader_screen.dart` | Modified — add banner, TTS-aware |
| `lib/main.dart` | Modified — AdMob SDK init |
