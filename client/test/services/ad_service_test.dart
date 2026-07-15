import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';

import 'package:aware/services/ad_service.dart';
import 'package:aware/services/ad_config.dart';

MethodChannel _channel() => MethodChannel(
      'plugins.flutter.io/google_mobile_ads',
      StandardMethodCodec(AdMessageCodec()),
    );

void main() {
  group('AdService', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      AdService.resetForTesting();
    });

    test('initAdMob handles platform error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        _channel(),
        _adsMockHandler,
      );
      await AdService.instance.initAdMob();
    });

    test('initAdMob succeeds', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        _channel(),
        _adsInitializeHandler,
      );

      await AdService.instance.initAdMob();
    });

    test('initAdMob guard prevents double initialization', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        _channel(),
        _adsInitializeHandler,
      );

      await AdService.instance.initAdMob();
      await AdService.instance.initAdMob();
    });
  });

  group('AdConfig', () {
    test('test instance uses test ad unit IDs', () {
      expect(AdConfig.test.nativeAdUnitId, contains('3940256099942544'));
      expect(AdConfig.test.bannerAdUnitId, contains('3940256099942544'));
    });

    test('production instance uses placeholder IDs', () {
      expect(AdConfig.production.nativeAdUnitId, contains('XXXX'));
      expect(AdConfig.production.bannerAdUnitId, contains('XXXX'));
    });

    test('instance defaults to test mode', () {
      expect(AdConfig.instance.nativeAdUnitId, AdConfig.test.nativeAdUnitId);
    });
  });

  group('loadNativeAd', () {
    test('creates and returns NativeAd instance', () async {
      AdService.resetForTesting();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        _channel(),
        _nativeAdHandler,
      );
      await AdService.instance.initAdMob();

      final ad = AdService.instance.loadNativeAd(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (_, __) {},
      );
      expect(ad, isA<NativeAd>());
      ad.dispose();
    });
  });

  group('loadBannerAd', () {
    test('creates and returns BannerAd instance', () async {
      AdService.resetForTesting();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        _channel(),
        _bannerAdHandler,
      );
      await AdService.instance.initAdMob();

      final ad = AdService.instance.loadBannerAd(
        size: AdSize.banner,
        onAdLoaded: (_) {},
        onAdFailedToLoad: (_, __) {},
      );
      expect(ad, isA<BannerAd>());
      ad.dispose();
    });
  });
}

Future<dynamic> _adsMockHandler(MethodCall methodCall) async {
  return null;
}

Future<dynamic> _adsInitializeHandler(MethodCall methodCall) async {
  switch (methodCall.method) {
    case 'MobileAds#initialize':
      return InitializationStatus(<String, AdapterStatus>{});
    default:
      return null;
  }
}

Future<dynamic> _nativeAdHandler(MethodCall methodCall) async {
  switch (methodCall.method) {
    case 'MobileAds#initialize':
      return InitializationStatus(<String, AdapterStatus>{});
    default:
      return null;
  }
}

Future<dynamic> _bannerAdHandler(MethodCall methodCall) async {
  switch (methodCall.method) {
    case 'MobileAds#initialize':
      return InitializationStatus(<String, AdapterStatus>{});
    default:
      return null;
  }
}
