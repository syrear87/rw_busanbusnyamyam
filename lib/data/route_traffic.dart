import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'busan_bis_api.dart';

/// 트래픽 상태 색상 상수
class TrafficColors {
  static const int grey = -1;   // #BDBDBD - 데이터 없음
  static const int green = 0;   // #43A047 - 원활
  static const int amber = 1;   // #FB8C00 - 보통 혼잡
  static const int red = 2;     // #E53935 - 심한 혼잡
  
  static const Map<int, String> colorHex = {
    grey: '#BDBDBD',
    green: '#43A047',
    amber: '#FB8C00',
    red: '#E53935',
  };
}

/// 차량 위치 스냅샷
class VehicleSnapshot {
  final String carno;
  final int index;
  final DateTime timestamp;
  
  const VehicleSnapshot({
    required this.carno,
    required this.index,
    required this.timestamp,
  });
}

/// 구간별 트래픽 상태 추정 클래스
class RouteTraffic {
  static final Map<String, _CacheEntry> _cache = {};
  static final Map<String, List<VehicleSnapshot>> _vehicleHistory = {};
  static const int _cacheTtlSeconds = 10;
  static const int _throttleMs = 600; // 호출 간 최소 간격
  
  /// Plan A: 차량 위치 기반 속도 계산으로 트래픽 상태 추정
  /// Returns: List<int> where -1=grey, 0=green, 1=amber, 2=red
  static Future<List<int>> estimateFromVehiclePositions(String lineid, List<RouteStop> stops) async {
    final cacheKey = '${lineid}_vehicle_${stops.length}';
    
    // 캐시 확인
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      print('🚦 차량 위치 기반 트래픽 상태 캐시 사용: $cacheKey');
      return cached.data;
    }
    
    print('🚦 Plan A: 차량 위치 기반 트래픽 상태 추정 시작: $lineid');
    
    try {
      // busInfoByRouteId API 호출로 차량 위치 정보 가져오기
      final currentVehicles = await _getVehiclePositions(lineid);
      
      if (currentVehicles.isEmpty) {
        print('⚠️ 차량 위치 정보 없음 → 모든 구간 초록색 (원활)');
        final segmentColors = List<int>.filled(stops.length - 1, TrafficColors.green);
        _cache[cacheKey] = _CacheEntry(segmentColors, DateTime.now());
        return segmentColors;
      }
      
      // 이전 스냅샷과 비교하여 속도 계산
      final segmentColors = _calculateTrafficFromVehicleSpeed(
        lineid, 
        stops, 
        currentVehicles
      );
      
      // 캐시 저장
      _cache[cacheKey] = _CacheEntry(segmentColors, DateTime.now());
      
      final greenCount = segmentColors.where((c) => c == TrafficColors.green).length;
      final amberCount = segmentColors.where((c) => c == TrafficColors.amber).length;
      final redCount = segmentColors.where((c) => c == TrafficColors.red).length;
      final greyCount = segmentColors.where((c) => c == TrafficColors.grey).length;
      
      print('✅ Plan A 완료: 초록 $greenCount, 주황 $amberCount, 빨강 $redCount, 회색 $greyCount');
      
      return segmentColors;
    } catch (e) {
      print('💥 Plan A 실패: $e');
      return List<int>.filled(stops.length - 1, TrafficColors.green);
    }
  }
  
  /// 차량 위치 정보 조회
  static Future<List<VehicleSnapshot>> _getVehiclePositions(String lineid) async {
    try {
      final vehicles = await BisApi.vehiclePositions(lineid);
      final now = DateTime.now();
      
      return vehicles.map((v) => VehicleSnapshot(
        carno: v.carno,
        index: v.index,
        timestamp: now,
      )).toList();
    } catch (e) {
      print('💥 차량 위치 조회 실패: $e');
      return [];
    }
  }
  
  /// 차량 속도 기반 트래픽 색상 계산
  static List<int> _calculateTrafficFromVehicleSpeed(
    String lineid, 
    List<RouteStop> stops, 
    List<VehicleSnapshot> currentVehicles
  ) {
    final segmentColors = List<int>.filled(stops.length - 1, TrafficColors.green);
    final vehicleHistory = _vehicleHistory[lineid] ?? [];
    
    // 현재 차량들을 히스토리에 추가
    _vehicleHistory[lineid] = currentVehicles;
    
    if (vehicleHistory.isEmpty) {
      print('⚠️ 이전 차량 위치 없음 → 차량이 있는 구간만 주황색 (정체 의심)');
      // 첫 번째 호출: 차량이 있는 구간을 주황색으로 표시 (정체 의심 구간)
      for (final vehicle in currentVehicles) {
        if (vehicle.index < stops.length - 1) {
          segmentColors[vehicle.index] = TrafficColors.amber;
        }
      }
      return segmentColors;
    }
    
    // 각 차량의 속도 계산
    for (final currentVehicle in currentVehicles) {
      final previousVehicle = vehicleHistory.firstWhere(
        (v) => v.carno == currentVehicle.carno,
        orElse: () => currentVehicle, // 이전 위치가 없으면 현재 위치 사용
      );
      
      final timeDiff = currentVehicle.timestamp.difference(previousVehicle.timestamp).inSeconds;
      if (timeDiff <= 0) continue;
      
      final indexDiff = currentVehicle.index - previousVehicle.index;
      if (indexDiff <= 0) continue; // 역방향 이동은 무시
      
      // 구간 거리 계산 (km)
      final segmentDistance = _calculateSegmentDistance(stops, previousVehicle.index, currentVehicle.index);
      if (segmentDistance <= 0) continue;
      
      // 속도 계산 (km/h)
      final speed = (segmentDistance / timeDiff) * 3600; // km/h
      
      print('🚌 차량 ${currentVehicle.carno}: ${previousVehicle.index}→${currentVehicle.index}, 속도: ${speed.toStringAsFixed(1)}km/h');
      
      // 구간별 색상 결정 (막히는 부분만 주황/빨강 표시)
      for (int i = previousVehicle.index; i < currentVehicle.index && i < segmentColors.length; i++) {
        if (speed < 9) {
          segmentColors[i] = TrafficColors.red;    // < 9 km/h → Red (심한 정체)
        } else if (speed < 18) {
          segmentColors[i] = TrafficColors.amber;  // 9–18 km/h → Amber (보통 정체)
        }
        // speed >= 18 km/h는 기본 초록색 유지 (색상 변경 안함)
      }
    }
    
    return segmentColors;
  }
  
  /// 구간 거리 계산 (km)
  static double _calculateSegmentDistance(List<RouteStop> stops, int startIndex, int endIndex) {
    if (startIndex >= stops.length || endIndex >= stops.length) return 0;
    
    double totalDistance = 0;
    for (int i = startIndex; i < endIndex && i < stops.length - 1; i++) {
      totalDistance += _haversineDistance(
        stops[i].lat, stops[i].lng,
        stops[i + 1].lat, stops[i + 1].lng,
      );
    }
    return totalDistance;
  }
  
  /// 두 정류장 간 구간의 트래픽 상태 추정
  static Future<int> _estimateSegment(RouteStop stopA, RouteStop stopB, String lineid) async {
    try {
      print('🔍 구간 추정: ${stopA.nodenm} → ${stopB.nodenm}');
      print('   📍 정류장 A: ${stopA.nodeid} (${stopA.lat}, ${stopA.lng})');
      print('   📍 정류장 B: ${stopB.nodeid} (${stopB.lat}, ${stopB.lng})');
      
      // 두 정류장의 도착정보 조회
      final arrivalsA = await _getArrivalTime(stopA.nodeid, lineid);
      final arrivalsB = await _getArrivalTime(stopB.nodeid, lineid);
      
      if (arrivalsA == null || arrivalsB == null) {
        print('   ⚠️ 도착정보 없음 (A: $arrivalsA, B: $arrivalsB) → 회색');
        return TrafficColors.grey;
      }
      
      // 거리 계산 (km)
      final distKm = _haversineDistance(stopA.lat, stopA.lng, stopB.lat, stopB.lng);
      if (distKm == 0) {
        print('   ⚠️ 거리 0 → 회색');
        return TrafficColors.grey;
      }
      
      // 시간 차이 계산 (분)
      final dMin = (arrivalsB - arrivalsA).clamp(-30, 60);
      
      // 비율 계산 (분/2km 기준, 최소 0.3km 보호)
      final ratio = dMin / max(distKm * 2.0, 0.3);
      
      print('   📊 도착시간: ${arrivalsA}분 → ${arrivalsB}분 (차이: ${dMin}분)');
      print('   📏 거리: ${distKm.toStringAsFixed(2)}km, 비율: ${ratio.toStringAsFixed(2)}');
      
      // 색상 결정
      if (ratio <= 1.5) {
        print('   🟢 원활한 구간');
        return TrafficColors.green;
      } else if (ratio <= 3.0) {
        print('   🟠 보통 혼잡 구간');
        return TrafficColors.amber;
      } else {
        print('   🔴 심한 혼잡 구간');
        return TrafficColors.red;
      }
    } catch (e) {
      print('   💥 구간 추정 실패: $e → 회색');
      return TrafficColors.grey;
    }
  }
  
  
  /// 정류장의 도착시간 조회 (분)
  static Future<int?> _getArrivalTime(String nodeid, String lineid) async {
    try {
      print('   🔍 도착정보 조회: nodeid=$nodeid, lineid=$lineid');
      final arrivals = await BisApi.arrivalsByStop(nodeid, lineid: lineid);
      print('   📊 도착정보 개수: ${arrivals.length}');
      
      if (arrivals.isEmpty) {
        print('   ⚠️ 도착정보 없음');
        return null;
      }
      
      final arrival = arrivals.first;
      print('   📋 전체 도착정보:');
      print('     - lineid: ${arrival.lineid}');
      print('     - lineno: ${arrival.lineno}');
      print('     - nodenm: ${arrival.nodenm}');
      print('     - min1: "${arrival.min1}"');
      print('     - station1: "${arrival.station1}"');
      print('     - min2: "${arrival.min2}"');
      print('     - station2: "${arrival.station2}"');
      print('     - bustype: "${arrival.bustype}"');
      
      final min1 = arrival.min1;
      print('   ⏰ min1 값: "$min1"');
      
      if (min1?.isEmpty ?? true) {
        print('   ⚠️ min1이 빈 문자열 또는 null');
        return null;
      }
      
      final parsed = int.tryParse(min1 ?? '');
      print('   🔢 파싱된 값: $parsed');
      return parsed;
    } catch (e) {
      print('   💥 도착정보 조회 실패: $e');
      return null;
    }
  }
  
  /// 두 지점 간 거리 계산 (Haversine 공식, km)
  static double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371.0; // 지구 반지름 (km)
    
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static double _toRadians(double degrees) => degrees * (pi / 180);
  
  /// 빈 구간들을 전후 색상으로 보간
  static void _interpolateColors(List<int> colors) {
    if (colors.isEmpty) return;
    
    // 앞에서부터 채우기
    for (int i = 1; i < colors.length; i++) {
      if (colors[i] == TrafficColors.grey && colors[i - 1] != TrafficColors.grey) {
        colors[i] = colors[i - 1];
      }
    }
    
    // 뒤에서부터 채우기
    for (int i = colors.length - 2; i >= 0; i--) {
      if (colors[i] == TrafficColors.grey && colors[i + 1] != TrafficColors.grey) {
        colors[i] = colors[i + 1];
      }
    }
  }
  
  /// 캐시 정리
  static void clearCache() {
    _cache.clear();
    print('🗑️ 트래픽 상태 캐시 정리');
  }
  
  /// 만료된 캐시 정리
  static void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpired);
    print('🗑️ 만료된 트래픽 상태 캐시 정리');
  }
}

/// 캐시 엔트리
class _CacheEntry {
  final List<int> data;
  final DateTime timestamp;
  
  _CacheEntry(this.data, this.timestamp);
  
  bool get isExpired => 
      DateTime.now().difference(timestamp).inSeconds > RouteTraffic._cacheTtlSeconds;
}
