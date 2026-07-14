import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  Future<void> initAdMob() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      print('AdService.initAdMob failed: $e');
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    instance._initialized = false;
  }

  NativeAd loadNativeAd({
    required void Function(NativeAd ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    NativeTemplateStyle? nativeTemplateStyle,
  }) {
    final ad = NativeAd(
      adUnitId: AdConfig.instance.nativeAdUnitId,
      factoryId: 'nativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => onAdLoaded(ad as NativeAd),
        onAdFailedToLoad: onAdFailedToLoad,
      ),
      nativeTemplateStyle: nativeTemplateStyle,
    );
    ad.load();
    return ad;
  }

  BannerAd loadBannerAd({
    required AdSize size,
    required void Function(BannerAd ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    final ad = BannerAd(
      adUnitId: AdConfig.instance.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(ad as BannerAd),
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
    ad.load();
    return ad;
  }
}
