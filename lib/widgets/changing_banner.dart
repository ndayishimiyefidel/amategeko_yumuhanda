import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatelessWidget {
  final BannerAd ad;

  const BannerAdWidget({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: size.width.toDouble(),
        height: 50.0, // Set the desired height for the banner ad
        child: AdWidget(ad: ad),
      ),
    );
  }
}
