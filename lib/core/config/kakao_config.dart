import 'package:flutter/foundation.dart';

class KakaoConfig {
  // 카카오맵 REST API 키
  static const String _debugApiKey = '91349bd186e3fe5612d42a8b0d681fae'; // 테스트용
  static const String _releaseApiKey = '4b32986a70b1007f8b5d4870164bd893'; // 릴리즈용
  
  // 디버그/릴리즈 모드에 따른 API 키 선택
  static String get restApiKey {
    return kDebugMode ? _debugApiKey : _releaseApiKey;
  }
  
  // 카카오맵 API 엔드포인트
  static const String baseUrl = 'https://dapi.kakao.com/v2/local';
  
  // 장소 검색 엔드포인트
  static const String searchKeywordUrl = '$baseUrl/search/keyword.json';
  
  // 카테고리 코드 매핑
  static const Map<String, String> categoryCodes = {
    'restaurant': 'FD6',  // 음식점
    'cafe': 'CE7',        // 카페
  };
}
