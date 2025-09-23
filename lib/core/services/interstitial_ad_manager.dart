import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';

class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  static InterstitialAdManager get instance => _instance ??= InterstitialAdManager._();
  
  InterstitialAdManager._();
  
  bool _isAdLoaded = false;
  bool _isLoading = false;
  
  /// 전면 광고 로드
  Future<void> loadAd() async {
    if (_isAdLoaded || _isLoading) return;
    
    _isLoading = true;
    
    await AdMobService.loadInterstitialAd(
      onAdLoaded: () {
        _isAdLoaded = true;
        _isLoading = false;
      },
      onAdFailedToLoad: (error) {
        debugPrint('Interstitial ad failed to load: $error');
        _isLoading = false;
      },
    );
  }
  
  /// 전면 광고 표시
  Future<void> showAd({
    VoidCallback? onAdShowed,
    VoidCallback? onAdDismissed,
    Function(AdError)? onAdFailedToShow,
  }) async {
    if (!_isAdLoaded) {
      await loadAd();
      if (!_isAdLoaded) return;
    }
    
    AdMobService.showInterstitialAd(
      onAdShowed: () {
        onAdShowed?.call();
      },
      onAdDismissed: () {
        _isAdLoaded = false;
        onAdDismissed?.call();
        // 다음 광고 미리 로드
        loadAd();
      },
      onAdFailedToShow: (error) {
        _isAdLoaded = false;
        onAdFailedToShow?.call(error);
        // 다음 광고 미리 로드
        loadAd();
      },
    );
  }
  
  /// 광고 로드 상태 확인
  bool get isAdLoaded => _isAdLoaded;
  
  /// 광고 로딩 중인지 확인
  bool get isLoading => _isLoading;
  
  /// 광고 해제
  void dispose() {
    AdMobService.disposeInterstitialAd();
    _isAdLoaded = false;
    _isLoading = false;
  }
}
