import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'place_model.dart';
import 'route_model.dart';
import 'route_repository.dart';
import '../../../core/config/api_keys.dart';

class BusanBisRouteRepository implements RouteRepository {
  static const String _baseUrl = 'http://apis.data.go.kr/6260000/BusanBIMS';

  String get _apiKey => ApiKeys.bisServiceKey;

  @override
  Future<Result<List<BusRoute>>> searchRoutes(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/busInfo')
          .replace(queryParameters: {
        'serviceKey': _apiKey,
        'lineno': query,
      });

      print('🚌 BIS 노선 검색 시작 - 노선번호: $query');
      print('🔗 BIS GET ${url.toString()}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('네트워크 요청 시간 초과'),
      );

      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        return const Failure('BIS API 호출 실패');
      }

      final document = XmlDocument.parse(response.body);
      final resultCode = document.findAllElements('resultCode').firstOrNull?.text;
      final resultMsg = document.findAllElements('resultMsg').firstOrNull?.text;

      print('🔍 BIS 응답 코드: $resultCode');
      print('🔍 BIS 응답 메시지: $resultMsg');

      if (resultCode != '00') {
        return Failure('BIS API 오류: $resultMsg');
      }

      final items = document.findAllElements('item');
      final routes = <BusRoute>[];

      for (final item in items) {
        try {
          final routeData = <String, dynamic>{};
          for (final element in item.children.whereType<XmlElement>()) {
            routeData[element.name.local] = element.text;
          }

          final route = BusRoute.fromJson(routeData);
          routes.add(route);
        } catch (e) {
          print('⚠️ 노선 파싱 오류: $e');
        }
      }

      print('✅ BIS 노선 검색 성공: ${routes.length}개 노선 반환');
      return Success(routes);
    } catch (e) {
      print('❌ BIS 노선 검색 실패: $e');
      return Failure('노선 검색 실패: $e');
    }
  }

  @override
  Future<Result<List<RouteStop>>> getRouteStops(String routeId) async {
    try {
      final url = Uri.parse('$_baseUrl/busStopList')
          .replace(queryParameters: {
        'serviceKey': _apiKey,
        'lineid': routeId,
      });

      print('🚌 BIS 노선 정류장 조회 시작 - 노선ID: $routeId');
      print('🔗 BIS GET ${url.toString()}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('네트워크 요청 시간 초과'),
      );

      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        return const Failure('BIS API 호출 실패');
      }

      final document = XmlDocument.parse(response.body);
      final resultCode = document.findAllElements('resultCode').firstOrNull?.text;
      final resultMsg = document.findAllElements('resultMsg').firstOrNull?.text;

      print('🔍 BIS 응답 코드: $resultCode');
      print('🔍 BIS 응답 메시지: $resultMsg');

      if (resultCode != '00') {
        return Failure('BIS API 오류: $resultMsg');
      }

      final items = document.findAllElements('item');
      final stops = <RouteStop>[];

      for (final item in items) {
        try {
          final stopData = <String, dynamic>{};
          for (final element in item.children.whereType<XmlElement>()) {
            stopData[element.name.local] = element.text;
          }

          final stop = RouteStop.fromJson(stopData);
          stops.add(stop);
        } catch (e) {
          print('⚠️ 정류장 파싱 오류: $e');
        }
      }

      // 순서대로 정렬
      stops.sort((a, b) => a.sequence.compareTo(b.sequence));

      print('✅ BIS 노선 정류장 조회 성공: ${stops.length}개 정류장 반환');
      return Success(stops);
    } catch (e) {
      print('❌ BIS 노선 정류장 조회 실패: $e');
      return Failure('노선 정류장 조회 실패: $e');
    }
  }

  @override
  Future<Result<List<BusStop>>> getNearbyStops({
    required double lat,
    required double lon,
    required int radiusMeters,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/busStopList')
          .replace(queryParameters: {
        'serviceKey': _apiKey,
        'numOfRows': limit.toString(),
      });

      print('🚌 BIS 근처 정류장 검색 시작 - 위치: ($lat, $lon), 반경: ${radiusMeters}m');
      print('🔗 BIS GET ${url.toString()}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('네트워크 요청 시간 초과'),
      );

      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        return const Failure('BIS API 호출 실패');
      }

      final document = XmlDocument.parse(response.body);
      final resultCode = document.findAllElements('resultCode').firstOrNull?.text;

      if (resultCode != '00') {
        return const Failure('BIS API 오류');
      }

      final items = document.findAllElements('item');
      final stops = <BusStop>[];

      for (final item in items) {
        try {
          final stopData = <String, dynamic>{};
          for (final element in item.children.whereType<XmlElement>()) {
            stopData[element.name.local] = element.text;
          }

          final stop = BusStop.fromJson(stopData);

          // 거리 계산 및 필터링
          final distance = _calculateDistance(lat, lon, stop.lat, stop.lon);
          if (distance <= radiusMeters) {
            stops.add(stop);
          }
        } catch (e) {
          print('⚠️ 정류장 파싱 오류: $e');
        }
      }

      // 거리순 정렬
      stops.sort((a, b) {
        final distA = _calculateDistance(lat, lon, a.lat, a.lon);
        final distB = _calculateDistance(lat, lon, b.lat, b.lon);
        return distA.compareTo(distB);
      });

      print('✅ BIS 근처 정류장 검색 성공: ${stops.length}개 정류장 반환');
      return Success(stops.take(limit).toList());
    } catch (e) {
      print('❌ BIS 근처 정류장 검색 실패: $e');
      return Failure('근처 정류장 검색 실패: $e');
    }
  }

  @override
  Future<Result<BusStop?>> getStopByArsNumber(String arsNumber) async {
    try {
      final url = Uri.parse('$_baseUrl/busStopInfo')
          .replace(queryParameters: {
        'serviceKey': _apiKey,
        'arsno': arsNumber,
      });

      print('🚌 BIS ARS 번호 정류장 조회 시작 - ARS: $arsNumber');
      print('🔗 BIS GET ${url.toString()}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('네트워크 요청 시간 초과'),
      );

      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        return const Failure('BIS API 호출 실패');
      }

      final document = XmlDocument.parse(response.body);
      final resultCode = document.findAllElements('resultCode').firstOrNull?.text;
      final resultMsg = document.findAllElements('resultMsg').firstOrNull?.text;

      print('🔍 BIS 응답 코드: $resultCode');
      print('🔍 BIS 응답 메시지: $resultMsg');

      if (resultCode != '00') {
        return Failure('BIS API 오류: $resultMsg');
      }

      final item = document.findAllElements('item').firstOrNull;
      if (item == null) {
        print('⚠️ 정류장을 찾을 수 없음: $arsNumber');
        return const Success(null);
      }

      final stopData = <String, dynamic>{};
      for (final element in item.children.whereType<XmlElement>()) {
        stopData[element.name.local] = element.text;
      }

      final stop = BusStop.fromJson(stopData);

      print('✅ BIS ARS 번호 정류장 조회 성공: ${stop.stopName}');
      return Success(stop);
    } catch (e) {
      print('❌ BIS ARS 번호 정류장 조회 실패: $e');
      return Failure('정류장 조회 실패: $e');
    }
  }

  @override
  Future<Result<List<BusStop>>> searchStops(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/busStopList')
          .replace(queryParameters: {
        'serviceKey': _apiKey,
        'bstopnm': query,
      });

      print('🚌 BIS 정류장 이름 검색 시작 - 검색어: $query');
      print('🔗 BIS GET ${url.toString()}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('네트워크 요청 시간 초과'),
      );

      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        return const Failure('BIS API 호출 실패');
      }

      final document = XmlDocument.parse(response.body);
      final resultCode = document.findAllElements('resultCode').firstOrNull?.text;
      final resultMsg = document.findAllElements('resultMsg').firstOrNull?.text;

      print('🔍 BIS 응답 코드: $resultCode');
      print('🔍 BIS 응답 메시지: $resultMsg');

      if (resultCode != '00') {
        return Failure('BIS API 오류: $resultMsg');
      }

      final items = document.findAllElements('item');
      final stops = <BusStop>[];

      for (final item in items) {
        try {
          final stopData = <String, dynamic>{};
          for (final element in item.children.whereType<XmlElement>()) {
            stopData[element.name.local] = element.text;
          }

          final stop = BusStop.fromJson(stopData);
          stops.add(stop);
        } catch (e) {
          print('⚠️ 정류장 파싱 오류: $e');
        }
      }

      print('✅ BIS 정류장 이름 검색 성공: ${stops.length}개 정류장 반환');
      return Success(stops);
    } catch (e) {
      print('❌ BIS 정류장 이름 검색 실패: $e');
      return Failure('정류장 검색 실패: $e');
    }
  }

  /// Haversine 공식을 사용한 거리 계산 (미터 단위)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}