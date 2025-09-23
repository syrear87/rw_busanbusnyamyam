import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  
  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd(
      adSize: widget.adSize,
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
          _isAdFailed = false;
        });
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: $error');
        setState(() {
          _isAdLoaded = false;
          _isAdFailed = true;
        });
      },
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
      margin: widget.margin,
      child: _isAdLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : _buildFallbackWidget(),
    );
  }

  Widget _buildFallbackWidget() {
    return Container(
      height: widget.adSize.height.toDouble(),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          '부산버스냠냠',
          style: TextStyle(
            fontSize: 19,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 하단 배너 광고 위젯
class BottomBannerAdWidget extends StatelessWidget {
  final EdgeInsets? margin;
  
  const BottomBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.banner,
      margin: margin ?? const EdgeInsets.all(8.0),
    );
  }
}

/// 큰 배너 광고 위젯
class LargeBannerAdWidget extends StatelessWidget {
  final EdgeInsets? margin;
  
  const LargeBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.largeBanner,
      margin: margin ?? const EdgeInsets.all(8.0),
    );
  }
}
