class BisConfig {
  static const String base = 'http://apis.data.go.kr/6260000/BusanBIMS';
  static const String key = String.fromEnvironment('BIS_SERVICE_KEY');
  static const Duration timeout = Duration(seconds: 6);
}
