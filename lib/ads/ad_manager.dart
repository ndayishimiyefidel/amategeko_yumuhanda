import 'package:flutter/material.dart';
import 'banner_widget.dart';
import 'interestial_ad.dart';
import 'reward_video_manager.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Ad frequency control
  static int _interstitialCounter = 0;
  static int _rewardedCounter = 0;
  static DateTime? _lastInterstitialTime;
  static DateTime? _lastRewardedTime;

  // Minimum intervals between ads (in seconds)
  static const int _minInterstitialInterval = 60; // 1 minute
  static const int _minRewardedInterval = 30; // 30 seconds
  static const int _interstitialFrequency = 3; // Show every 3 actions
  static const int _rewardedFrequency = 2; // Show every 2 actions

  // Initialize all ad types
  static void initializeAds() {
    try {
      // Load interstitial ad
      InterestialAds().loadInterstitialAd();

      // Load rewarded ad
      RewardedVideoAdManager.loadRewardAd();

      print('🔍 DEBUG: All ads initialized successfully');
    } catch (e) {
      print('🔍 DEBUG: Error initializing ads: $e');
    }
  }

  // Show interstitial ad with frequency control
  static void showInterstitialAd({String? context}) {
    try {
      final now = DateTime.now();

      // Check if enough time has passed since last ad
      if (_lastInterstitialTime != null) {
        final timeDiff = now.difference(_lastInterstitialTime!).inSeconds;
        if (timeDiff < _minInterstitialInterval) {
          print(
              '🔍 DEBUG: Interstitial ad skipped - too soon (${timeDiff}s < ${_minInterstitialInterval}s)');
          return;
        }
      }

      // Check frequency
      _interstitialCounter++;
      if (_interstitialCounter % _interstitialFrequency != 0) {
        print(
            '🔍 DEBUG: Interstitial ad skipped - frequency control ($_interstitialCounter)');
        return;
      }

      print('🔍 DEBUG: Showing interstitial ad (context: $context)');
      InterestialAds().showInterstitialAd();
      _lastInterstitialTime = now;
    } catch (e) {
      print('🔍 DEBUG: Error showing interstitial ad: $e');
    }
  }

  // Show rewarded ad with frequency control
  static bool showRewardedAd({String? context}) {
    try {
      final now = DateTime.now();

      // Check if enough time has passed since last ad
      if (_lastRewardedTime != null) {
        final timeDiff = now.difference(_lastRewardedTime!).inSeconds;
        if (timeDiff < _minRewardedInterval) {
          print(
              '🔍 DEBUG: Rewarded ad skipped - too soon (${timeDiff}s < ${_minRewardedInterval}s)');
          return false;
        }
      }

      // Check frequency
      _rewardedCounter++;
      if (_rewardedCounter % _rewardedFrequency != 0) {
        print(
            '🔍 DEBUG: Rewarded ad skipped - frequency control ($_rewardedCounter)');
        return false;
      }

      print('🔍 DEBUG: Showing rewarded ad (context: $context)');
      final result = RewardedVideoAdManager.showRewardAd();
      if (result) {
        _lastRewardedTime = now;
      }
      return result;
    } catch (e) {
      print('🔍 DEBUG: Error showing rewarded ad: $e');
      return false;
    }
  }

  // Get banner ad widget
  static Widget getBannerAd() {
    return const AdBannerWidget();
  }

  // Reset counters (useful for testing or user preferences)
  static void resetCounters() {
    _interstitialCounter = 0;
    _rewardedCounter = 0;
    _lastInterstitialTime = null;
    _lastRewardedTime = null;
    print('🔍 DEBUG: Ad counters reset');
  }

  // Dispose all ads
  static void dispose() {
    try {
      InterestialAds().dispose();
      RewardedVideoAdManager.dispose();
      print('🔍 DEBUG: All ads disposed');
    } catch (e) {
      print('🔍 DEBUG: Error disposing ads: $e');
    }
  }

  // Get ad statistics for debugging
  static Map<String, dynamic> getAdStats() {
    return {
      'interstitialCounter': _interstitialCounter,
      'rewardedCounter': _rewardedCounter,
      'lastInterstitialTime': _lastInterstitialTime?.toIso8601String(),
      'lastRewardedTime': _lastRewardedTime?.toIso8601String(),
      'interstitialFrequency': _interstitialFrequency,
      'rewardedFrequency': _rewardedFrequency,
    };
  }

  static void onDocumentDownload() {
    AdManager.showRewardedAd(context: 'document_download');
  }
}

// Ad placement strategies for different screens
class AdPlacement {
  // Show rewarded ad when user completes an exam
  static void onExamCompletion() {
    AdManager.showRewardedAd(context: 'exam_completion');
  }

  // Show interstitial ad when user navigates between major sections
  static void onSectionNavigation() {
    AdManager.showInterstitialAd(context: 'section_navigation');
  }

  // Show rewarded ad for bonus features
  static bool onBonusFeature() {
    return AdManager.showRewardedAd(context: 'bonus_feature');
  }

  // Show interstitial ad when user views course content
  static void onCourseView() {
    AdManager.showInterstitialAd(context: 'course_view');
  }

  // Show interstitial ad when user creates content (admin)
  static void onContentCreation() {
    AdManager.showInterstitialAd(context: 'content_creation');
  }

  // Show rewarded ad for unlocking premium content
  static bool onPremiumUnlock() {
    return AdManager.showRewardedAd(context: 'premium_unlock');
  }

  // Show interstitial ad when user logs in
  static void onUserLogin() {
    AdManager.showInterstitialAd(context: 'user_login');
  }

  // Show interstitial ad when user signs up
  static void onUserSignup() {
    AdManager.showInterstitialAd(context: 'user_signup');
  }

  // Show rewarded ad when user downloads a document
  static void onDocumentDownload() {
    AdManager.showRewardedAd(context: 'document_download');
  }

  // Show rewarded ad when user views a video
  static void onVideoView() {
    AdManager.showRewardedAd(context: 'video_view');
  }

  // Show rewarded ad when user views a quiz
  static void onQuizView() {
    AdManager.showRewardedAd(context: 'quiz_view');
  }

  // Show rewarded ad when user logs out
  static void onLogout() {
    AdManager.showRewardedAd(context: 'logout');
  }

  // on dashboard action
  static void onDashboardAction() {
    AdManager.showInterstitialAd(context: 'dashboard_action');
  }
}
