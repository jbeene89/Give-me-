import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Minimal wrapper so you can disable ads during development.
abstract class AdsService {
  Future<void> init();
}

class AdMobAdsService implements AdsService {
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }
}

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdMobAdsService();
});
