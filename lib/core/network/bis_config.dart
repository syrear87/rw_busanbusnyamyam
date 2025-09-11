import '../config/api_keys.dart';

/// Official base (REST, XML, HTTP)
class BisConfig {
  static const base = 'http://apis.data.go.kr/6260000/BusanBIMS';
  static const _env = String.fromEnvironment('BIS_SERVICE_KEY');
  static String get key {
    // 1. dart-define에서 먼저 확인 (우선순위)
    if (_env.isNotEmpty) {
      return _env.contains('%') ? Uri.decodeComponent(_env) : _env;
    }
    // 2. 공통 파일에서 가져오기
    return ApiKeys.bisServiceKey;
  }
  // Exact paths from the spec
  static const pathStationList        = '/busStopList';                 // 정류소정보 조회
  static const pathLineInfo           = '/busInfo';                     // 노선정보 조회
  static const pathLineStations       = '/busInfoByRouteId';            // 노선 정류소 조회(+차량 위치 포함)
  static const pathArrivalsByStopId   = '/stopArrByBstopid';            // 정류소 도착(정류장ID)
  static const pathArrivalByLineStop  = '/busStopArrByBstopidLineid';   // 노선 정류소 도착
  static const pathArrivalsByArsNo    = '/bitArrByArsno';               // 정류소 도착(ARS)
  static const timeout = Duration(seconds: 8);
}
