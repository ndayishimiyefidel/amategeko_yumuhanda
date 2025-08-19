import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    try {
      _loadBannerAd();
    } catch (e) {
      print('Error initializing banner ad: $e');
    }
  }

  void _loadBannerAd() {
    try {
      if (_isDisposed) return;

      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-2864387622629553/7276208106',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            try {
              print('Banner ad loaded: ${ad.adUnitId}');
              if (mounted && !_isDisposed) {
                setState(() {
                  _isLoaded = true;
                });
              }
            } catch (e) {
              print('Error in banner ad onAdLoaded: $e');
            }
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            try {
              print('Banner ad failed to load: ${ad.adUnitId}, $error');
              ad.dispose(); // Dispose the ad to avoid memory leaks.
              if (mounted && !_isDisposed) {
                setState(() {
                  _isLoaded = false;
                });
              }
            } catch (e) {
              print('Error in banner ad onAdFailedToLoad: $e');
            }
          },
          onAdOpened: (Ad ad) {
            try {
              print('Banner ad opened: ${ad.adUnitId}');
            } catch (e) {
              print('Error in banner ad onAdOpened: $e');
            }
          },
          onAdClosed: (Ad ad) {
            try {
              print('Banner ad closed: ${ad.adUnitId}');
            } catch (e) {
              print('Error in banner ad onAdClosed: $e');
            }
          },
        ),
      );

      _bannerAd?.load();
    } catch (e) {
      print('Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    try {
      _isDisposed = true;
      _bannerAd?.dispose();
      _bannerAd = null;
    } catch (e) {
      print('Error disposing banner ad: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_isDisposed) {
        return const SizedBox.shrink();
      }

      if (!_isLoaded || _bannerAd == null) {
        return Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text(
            'Loading ad...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      }

      return Container(
        alignment: Alignment.bottomCenter,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } catch (e) {
      print('Error building banner ad widget: $e');
      return const SizedBox.shrink();
    }
  }
}
