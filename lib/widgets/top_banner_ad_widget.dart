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

    // 화면 크기에 따라 적절한 AdMob 표준 사이즈 선택
    AdSize adSize;
    if (screenWidth >= 728) {
      adSize = AdSize.leaderboard; // 728x90 (태블릿용)
    } else if (screenWidth >= 468) {
      adSize = AdSize.fullBanner; // 468x60
    } else if (screenWidth >= 320) {
      // 표준 배너를 화면 너비에 맞춰 비례 확대
      const standardHeight = 50.0;
      final proportionalHeight = (screenWidth * standardHeight / 320).round();
      adSize = AdSize(width: screenWidth.toInt(), height: proportionalHeight);
    } else {
      adSize = AdSize.banner; // 320x50 (기본)
    }

    return SizedBox(
      height: adSize.height.toDouble(),
      child: BannerAdWidget(
        adSize: adSize,
        margin: margin ?? EdgeInsets.zero,
      ),
    );
  }
}
