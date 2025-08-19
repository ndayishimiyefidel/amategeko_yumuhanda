import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedVideoAdManager {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  static bool _isDisposed = false;

  static void loadRewardAd() {
    try {
      if (_isDisposed || _isLoading) return;

      _isLoading = true;
      print('Loading reward ad...');

      RewardedAd.load(
        adUnitId: 'ca-app-pub-2864387622629553/2709049779',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            try {
              print('Reward ad loaded successfully');
              _rewardedAd = ad;
              _isLoading = false;
            } catch (e) {
              print('Error in onAdLoaded: $e');
              _isLoading = false;
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            try {
              print('Reward ad failed to load: $error');
              _rewardedAd = null;
              _isLoading = false;
            } catch (e) {
              print('Error in onAdFailedToLoad: $e');
              _isLoading = false;
            }
          },
        ),
      );
    } catch (e) {
      print('Error loading reward ad: $e');
      _isLoading = false;
    }
  }

  static bool showRewardAd() {
    try {
      if (_isDisposed) {
        print('Reward ad manager is disposed');
        return false;
      }

      if (_rewardedAd == null) {
        print('Reward ad is not loaded');
        loadRewardAd(); // Try to load a new ad
        return false;
      }

      // Check if ad is ready to show
      if (_rewardedAd!.responseInfo == null) {
        print('Reward ad is not ready to show');
        return false;
      }

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          try {
            print('Reward ad showed full screen content');
          } catch (e) {
            print('Error in onAdShowedFullScreenContent: $e');
          }
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          try {
            print('Reward ad dismissed');
            ad.dispose();
            _rewardedAd = null;
            loadRewardAd(); // Load a new ad after it's dismissed
          } catch (e) {
            print('Error in onAdDismissedFullScreenContent: $e');
            _rewardedAd = null;
            loadRewardAd();
          }
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          try {
            print('Reward ad failed to show: $error');
            ad.dispose();
            _rewardedAd = null;
            loadRewardAd(); // Load a new ad after it fails to show
          } catch (e) {
            print('Error in onAdFailedToShowFullScreenContent: $e');
            _rewardedAd = null;
            loadRewardAd();
          }
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          try {
            print('User earned reward: ${reward.amount} ${reward.type}');
          } catch (e) {
            print('Error in onUserEarnedReward: $e');
          }
        },
      );

      print('Reward ad shown successfully');
      return true; // Ad was shown successfully
    } catch (e) {
      print('Error showing reward ad: $e');
      // Clean up on error
      try {
        _rewardedAd?.dispose();
        _rewardedAd = null;
        loadRewardAd(); // Try to load a new ad
      } catch (disposeError) {
        print('Error disposing reward ad: $disposeError');
      }
      return false;
    }
  }

  static void dispose() {
    try {
      _isDisposed = true;
      _isLoading = false;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      print('Reward ad manager disposed');
    } catch (e) {
      print('Error disposing reward ad manager: $e');
    }
  }

  static bool get isAdLoaded {
    try {
      return _rewardedAd != null && !_isDisposed;
    } catch (e) {
      print('Error checking if ad is loaded: $e');
      return false;
    }
  }

  static bool get isLoading {
    try {
      return _isLoading && !_isDisposed;
    } catch (e) {
      print('Error checking if ad is loading: $e');
      return false;
    }
  }
}
