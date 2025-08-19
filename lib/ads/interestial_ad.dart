import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterestialAds {
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;
  bool _isLoading = false;
  bool _isDisposed = false;

  // Singleton pattern to ensure only one instance of InterestialAds
  static InterestialAds? _instance;

  factory InterestialAds() {
    _instance ??= InterestialAds._();
    return _instance!;
  }

  InterestialAds._();

  void loadInterstitialAd() {
    try {
      if (_isDisposed || _isLoading) return;

      _isLoading = true;
      print('Loading interstitial ad...');

      InterstitialAd.load(
        adUnitId: 'ca-app-pub-2864387622629553/2309153588',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            try {
              print('Interstitial ad loaded successfully');
              _interstitialAd = ad;
              _isLoading = false;

              // Set up callbacks for the loaded ad
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (InterstitialAd ad) {
                  try {
                    print('Interstitial ad showed full screen content');
                  } catch (e) {
                    print('Error in onAdShowedFullScreenContent: $e');
                  }
                },
                onAdDismissedFullScreenContent: (InterstitialAd ad) {
                  try {
                    print('Interstitial ad dismissed');
                    ad.dispose();
                    _interstitialAd = null;
                    loadInterstitialAd(); // Load a new ad
                  } catch (e) {
                    print('Error in onAdDismissedFullScreenContent: $e');
                    _interstitialAd = null;
                    loadInterstitialAd();
                  }
                },
                onAdFailedToShowFullScreenContent:
                    (InterstitialAd ad, AdError error) {
                  try {
                    print('Interstitial ad failed to show: $error');
                    ad.dispose();
                    _interstitialAd = null;
                    loadInterstitialAd(); // Load a new ad
                  } catch (e) {
                    print('Error in onAdFailedToShowFullScreenContent: $e');
                    _interstitialAd = null;
                    loadInterstitialAd();
                  }
                },
              );
            } catch (e) {
              print('Error in onAdLoaded: $e');
              _isLoading = false;
            }
          },
          onAdFailedToLoad: (error) {
            try {
              print('InterstitialAd failed to load: $error');
              _interstitialAd = null;
              _isLoading = false;
            } catch (e) {
              print('Error in onAdFailedToLoad: $e');
              _isLoading = false;
            }
          },
        ),
      );
    } catch (e) {
      print('Error loading interstitial ad: $e');
      _isLoading = false;
    }
  }

  void showInterstitialAd() {
    try {
      if (_isDisposed) {
        print('Interstitial ad manager is disposed');
        return;
      }

      if (_interstitialAd == null) {
        print('InterstitialAd is not loaded yet. Loading now...');
        loadInterstitialAd();
        return;
      }

      // Check if ad is ready to show
      if (_interstitialAd!.responseInfo == null) {
        print('Interstitial ad is not ready to show');
        return;
      }

      _interstitialAd!.show();
      print('Interstitial ad shown successfully');
    } catch (e) {
      print('Error showing interstitial ad: $e');
      // Clean up on error
      try {
        _interstitialAd?.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Try to load a new ad
      } catch (disposeError) {
        print('Error disposing interstitial ad: $disposeError');
      }
    }
  }

  // You may want to add a method to dispose of the interstitial ad when it's no longer needed.
  void dispose() {
    try {
      _isDisposed = true;
      _isLoading = false;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _interstitialTimer?.cancel();
      _interstitialTimer = null;
      print('Interstitial ad manager disposed');
    } catch (e) {
      print('Error disposing interstitial ad manager: $e');
    }
  }

  bool get isAdLoaded {
    try {
      return _interstitialAd != null && !_isDisposed;
    } catch (e) {
      print('Error checking if interstitial ad is loaded: $e');
      return false;
    }
  }

  bool get isLoading {
    try {
      return _isLoading && !_isDisposed;
    } catch (e) {
      print('Error checking if interstitial ad is loading: $e');
      return false;
    }
  }
}
