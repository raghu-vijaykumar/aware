import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';
import '../theme/theme.dart';

class NativeAdTile extends StatefulWidget {
  const NativeAdTile({super.key});

  @override
  State<NativeAdTile> createState() => _NativeAdTileState();
}

class _NativeAdTileState extends State<NativeAdTile> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;
  bool _adFailed = false;
  bool _adLoadingStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adLoadingStarted) {
      _adLoadingStarted = true;
      _loadAd();
    }
  }

  void _loadAd() {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    AdService.instance.loadNativeAd(
      onAdLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _nativeAd = ad;
          _adLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        if (mounted) {
          setState(() => _adFailed = true);
        }
      },
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: isLight ? Colors.white : Colors.grey[850],
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: isLight ? Colors.black87 : Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 18,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onSurfaceVariant,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: colorScheme.onSurfaceVariant,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adFailed) {
      return const SizedBox.shrink();
    }
    if (!_adLoaded || _nativeAd == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final cardShadowColor =
        colorScheme.shadow.withOpacity(isLight ? 0.25 : 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Material(
        color: Colors.transparent,
        elevation: isLight ? 10 : 14,
        shadowColor: cardShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AdWidget(ad: _nativeAd!),
          ),
        ),
      ),
    );
  }
}
