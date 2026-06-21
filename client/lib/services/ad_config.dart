class AdConfig {
  AdConfig._({
    required this.nativeAdUnitId,
    required this.bannerAdUnitId,
  });

  final String nativeAdUnitId;
  final String bannerAdUnitId;

  static final test = AdConfig._(
    nativeAdUnitId: 'ca-app-pub-3940256099942544/2247696110',
    bannerAdUnitId: 'ca-app-pub-3940256099942544/6300978111',
  );

  static final production = AdConfig._(
    nativeAdUnitId: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
    bannerAdUnitId: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
  );

  static AdConfig get instance {
    const mode = String.fromEnvironment('admob_mode', defaultValue: 'test');
    return mode == 'production' ? production : test;
  }
}
