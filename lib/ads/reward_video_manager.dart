import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedVideoAdManager {
  static RewardedAd? _rewardedAd;

  static void loadRewardAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2709049779',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Reward ad failed to load: $error');
        },
      ),
    );
  }

  static bool showRewardAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {},
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          loadRewardAd(); // Load a new ad after it's dismissed
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          loadRewardAd(); // Load a new ad after it fails to show
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('$ad with reward ${RewardItem(reward.amount, reward.type)}');
        },
      );

      return true; // Ad was shown successfully
    } else {
      return false; // Ad is not loaded
    }
  }

  static void dispose() {
    _rewardedAd?.dispose();
  }
}
