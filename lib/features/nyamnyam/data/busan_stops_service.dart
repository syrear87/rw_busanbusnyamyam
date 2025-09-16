import 'dart:convert';
import 'package:flutter/services.dart';

class BusanStop {
  final String id;
  final String arsno;
  final String name;
  final double lng;
  final double lat;

  const BusanStop({
    required this.id,
    required this.arsno,
    required this.name,
    required this.lng,
    required this.lat,
  });

  factory BusanStop.fromJson(Map<String, dynamic> json) {
    return BusanStop(
      id: json['id'] as String,
      arsno: json['arsno'] as String,
      name: json['name'] as String,
      lng: (json['lng'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'BusanStop{id: $id, arsno: $arsno, name: $name, lat: $lat, lng: $lng}';
  }
}

class BusanStopsService {
  static BusanStopsService? _instance;
  List<BusanStop>? _stops;

  BusanStopsService._();

  static BusanStopsService get instance {
    _instance ??= BusanStopsService._();
    return _instance!;
  }

  /// 정류장 데이터 로드 (한 번만 실행)
  Future<void> _loadStops() async {
    if (_stops != null) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/busan_stops.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _stops = jsonList.map((json) => BusanStop.fromJson(json)).toList();
      print('✅ 정류장 데이터 로드 완료: ${_stops!.length}개');
    } catch (e) {
      print('❌ 정류장 데이터 로드 실패: $e');
      _stops = [];
    }
  }

  /// 정류장 ID로 좌표 조회
  Future<(double, double)?> getStopCoordinates(String nodeId) async {
    await _loadStops();

    try {
      final stop = _stops!.where((stop) => stop.id == nodeId).firstOrNull;

      if (stop != null) {
        return (stop.lat, stop.lng);
      }

      return null;
    } catch (e) {
      print('❌ 정류장 좌표 조회 실패: $e');
      return null;
    }
  }

  /// 정류장 이름으로 검색
  Future<List<BusanStop>> searchStopsByName(String name) async {
    await _loadStops();

    if (name.isEmpty) return [];

    return _stops!
        .where((stop) => stop.name.contains(name))
        .take(10) // 최대 10개만 반환
        .toList();
  }

  /// ARS 번호로 검색
  Future<BusanStop?> getStopByArsno(String arsno) async {
    await _loadStops();

    return _stops!.where((stop) => stop.arsno == arsno).firstOrNull;
  }

  /// 전체 정류장 수 반환
  Future<int> getTotalStopsCount() async {
    await _loadStops();
    return _stops!.length;
  }
}