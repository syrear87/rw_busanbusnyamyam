import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdMobService {
  static bool _isInitialized = false;
  
  /// AdMob 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }
  
  /// 플랫폼별 앱 ID 가져오기
  static String get appId {
    if (Platform.isAndroid) {
      return AdMobConfig.androidAppId;
    } else if (Platform.isIOS) {
      return AdMobConfig.iosAppId;
    }
    return AdMobConfig.androidAppId; // 기본값
  }
  
  /// 플랫폼별 배너 광고 ID 가져오기
  static String get bannerAdId {
    if (AdMobConfig.isTestMode) {
      return AdMobConfig.testBannerId;
    }
    
    if (Platform.isAndroid) {
      return AdMobConfig.androidBannerId;
    } else if (Platform.isIOS) {
      return AdMobConfig.iosBannerId;
    }
    return AdMobConfig.androidBannerId; // 기본값
  }
  
  /// 플랫폼별 전면 광고 ID 가져오기
  static String get interstitialAdId {
    if (AdMobConfig.isTestMode) {
      return AdMobConfig.testInterstitialId;
    }
    
    if (Platform.isAndroid) {
      return AdMobConfig.androidInterstitialId;
    } else if (Platform.isIOS) {
      return AdMobConfig.iosInterstitialId;
    }
    return AdMobConfig.androidInterstitialId; // 기본값
  }
  
  /// 배너 광고 생성
  static BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
  
  /// 전면 광고 로드
  static InterstitialAd? _interstitialAd;
  
  static Future<void> loadInterstitialAd({
    required void Function() onAdLoaded,
    required void Function(LoadAdError) onAdFailedToLoad,
  }) async {
    await InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          onAdLoaded();
        },
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
  
  /// 전면 광고 표시
  static void showInterstitialAd({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(AdError) onAdFailedToShow,
  }) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          onAdShowed();
        },
        onAdDismissedFullScreenContent: (ad) {
          onAdDismissed();
          ad.dispose();
          _interstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          onAdFailedToShow(error);
          ad.dispose();
          _interstitialAd = null;
        },
      );
      
      _interstitialAd!.show();
    }
  }
  
  /// 전면 광고 해제
  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
