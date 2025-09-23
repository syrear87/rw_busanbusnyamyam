import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'banner_ad_widget.dart';

class TopBannerAdWidget extends StatelessWidget {
  final EdgeInsets? margin;
  
  const TopBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BannerAdWidget(
      adSize: AdSize(width: screenWidth.toInt(), height: 50),
      margin: margin ?? EdgeInsets.zero,
    );
  }
}
