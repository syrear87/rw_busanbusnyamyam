class AdMobConfig {
  // Android AdMob IDs
  static const String androidAppId = 'ca-app-pub-9521594552515663~3304973425';
  static const String androidBannerId = 'ca-app-pub-9521594552515663/8768165043';
  static const String androidInterstitialId = 'ca-app-pub-9521594552515663/6832606159';
  
  // iOS AdMob IDs
  static const String iosAppId = 'ca-app-pub-9521594552515663~2087260521';
  static const String iosBannerId = 'ca-app-pub-9521594552515663/8357101501';
  static const String iosInterstitialId = 'ca-app-pub-9521594552515663/5711096176';
  
  // Test Ad IDs (for development)
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Get platform-specific App ID
  static String get appId {
    // This will be determined at runtime based on platform
    return androidAppId; // Default to Android, will be overridden in main.dart
  }
  
  // Get platform-specific Banner ID
  static String get bannerId {
    // This will be determined at runtime based on platform
    return androidBannerId; // Default to Android, will be overridden in main.dart
  }
  
  // Get platform-specific Interstitial ID
  static String get interstitialId {
    // This will be determined at runtime based on platform
    return androidInterstitialId; // Default to Android, will be overridden in main.dart
  }
  
  // Check if running in test mode
  static bool get isTestMode {
    // You can set this to true during development
    return false; // Set to true for testing with test ads
  }
}
