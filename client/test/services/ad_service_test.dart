import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aware/services/ad_service.dart';
import 'package:aware/services/ad_config.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      (MethodCall methodCall) async {
        // Return null for all calls - this prevents MissingPluginException
        // and lets the Google Mobile Ads package's own error handling work
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      null,
    );
  });

  group('AdService', () {
    test('initAdMob handles platform unavailability', () async {
      await AdService.instance.initAdMob();
    });

    test('initAdMob guard prevents double initialization', () async {
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
}
