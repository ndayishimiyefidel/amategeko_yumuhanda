import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2864387622629553/7276208106',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: ${ad.adUnitId}, $error');
          ad.dispose(); // Dispose the ad to avoid memory leaks.
        },
        onAdOpened: (Ad ad) => print('Ad opened: ${ad.adUnitId}'),
        onAdClosed: (Ad ad) => print('Ad closed: ${ad.adUnitId}'),
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: _bannerAd?.size.width.toDouble(),
      height: _bannerAd?.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
