---
layout: spec
status: draft
---

# AdMob Integration

## Problem

The Aware feed reader has no monetization strategy. To sustain ongoing development
and server costs, the app needs a lightweight, non-intrusive ad placement that
generates revenue without degrading the reading experience.

## User Stories

- As a reader, I see occasional native-style ads in my article feed so that
  the app remains free to use.
- As a reader, I see a small banner ad at the bottom of the article reader
  screen so that ads don't interrupt my reading.
- As a reader, the banner ad disappears when I use text-to-speech so that
  I am not distracted while listening.
- As a developer, I can configure ad unit IDs via a single config object
  so that switching between test and production IDs is trivial.

## Functional Requirements

### In-Feed Native Ads

1. Native ads appear as an article card in the article list (`ArticleListScreen`).
2. An ad is inserted every 5th position (index 4, 9, 14, ...) in the list.
3. The native ad card is visually consistent with article cards (same
   padding, typography scale, dark mode support).
4. Ads are only loaded when the feed is visible and have a visible
   impression tracker for analytics (future use).
5. If a native ad fails to load, the slot is left empty (no placeholder).

### Reader Screen Banner

1. A smart banner (`AdSize.smartBanner`) is shown at the bottom of the
   reader screen (`ReaderScreen`), above the bottom action bar.
2. The banner is hidden during text-to-speech playback.
3. The banner is anchored to the bottom and does not overlap article text.

### Ad Configuration

1. Ad unit IDs are defined in a single `AdConfig` class with separate
   entries for test and production.
2. The active set is selected by a compile-time flag (`--dart-define=
   admob_mode=test|production`), defaulting to test.
3. Test ad unit IDs from Google's published test samples are used.

### Non-Requirements (MVP)

- No interstitials, rewarded ads, or app open ads.
- No ad mediation or network waterfall.
- No GDPR / consent SDK (no user data is collected).
- No ad analytics or reporting beyond what AdMob provides by default.

## Data Model

No new database tables. Ad state is ephemeral (in-memory):

```
AdConfig
  nativeAdUnitId : String
  bannerAdUnitId : String
  mode : String (test|production)

AdService
  config : AdConfig
  isTtsActive : Boolean  (observed from SyncProvider / TTS state)
```

## Acceptance Criteria

1. Given the app is running with `admob_mode=test`, when I scroll to
   positions 5, 10, 15, etc. in the article list, I see native ad cards
   with test-ad labeling.
2. Given I open an article, a smart banner is visible at the bottom of
   the reader screen.
3. Given text-to-speech is playing on the reader screen, the banner is
   hidden.
4. Given text-to-speech stops, the banner reappears.
5. Given the app is compiled without `admob_mode`, test IDs are used.
6. `flutter analyze` reports zero errors after integration.

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| AdMob SDK increases APK size | Medium | Use `play-services-ads-lite` if size becomes an issue; re-evaluate at release |
| Ads slow down article list scrolling | Low | Native ads load asynchronously; failed impressions don't block the UI |
| Banner overlaps reader content | Low | Banner uses `AdSize.smartBanner` with proper bottom anchoring |
| Admob policy violation (no consent) | Low | No personal data collected; app serves only non-personalized ads |
