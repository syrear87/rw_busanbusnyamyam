import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'banner_ad_widget.dart';

class BottomBannerAdWidget extends StatelessWidget {
  final EdgeInsets? margin;
  
  const BottomBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 배너 광고
        BannerAdWidget(
          adSize: AdSize(width: 320, height: 50),
          margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
        ),
        // 하단 구분선
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }
}
