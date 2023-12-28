import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterestialAds {
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;

  // Singleton pattern to ensure only one instance of InterestialAds
  static InterestialAds? _instance;

  factory InterestialAds() {
    _instance ??= InterestialAds._();
    return _instance!;
  }

  InterestialAds._();

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2309153588',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      // print('InterstitialAd is not loaded yet.');
      print('InterstitialAd is not loaded yet. Loading now...');
      loadInterstitialAd();
    }
  }

  // You may want to add a method to dispose of the interstitial ad when it's no longer needed.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
  }
}
