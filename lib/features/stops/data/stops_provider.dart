import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'stop_model.dart';
import 'location_provider.dart';

// Assets에서 정류장 데이터를 로드하는 provider
final stopsProvider = FutureProvider<List<Stop>>((ref) async {
  final txt = await rootBundle.loadString('assets/data/busan_stops.json');
  final List data = json.decode(txt);
  return data.map((e) => Stop.fromJson(e)).toList();
});

// 거리 계산 함수
int _distM(double aLat, double aLng, double bLat, double bLng) =>
    Geolocator.distanceBetween(aLat, aLng, bLat, bLng).round();

// 가까운 정류장 provider (사용자 위치 기준)
final nearestStopsProvider = Provider<List<({Stop s, int m})>>((ref) {
  final stops = ref
      .watch(stopsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <Stop>[]);
  final pos = ref
      .watch(locationController)
      .maybeWhen(data: (p) => p, orElse: () => null);

  if (pos == null) {
    return stops.map((s) => (s: s, m: 999999)).toList();
  }

  // bbox 필터로 가볍게 컷 (~2km)
  final lat0 = pos.latitude;
  final lng0 = pos.longitude;
  final res = <({Stop s, int m})>[];

  for (final s in stops) {
    if ((s.lat - lat0).abs() > 0.02 || (s.lng - lng0).abs() > 0.02) continue;
    res.add((s: s, m: _distM(lat0, lng0, s.lat, s.lng)));
  }

  res.sort((a, b) => a.m.compareTo(b.m));
  return res.take(50).toList();
});

// 지도 중심 위치 provider
final mapCenterProvider = StateProvider<LatLng?>((ref) => null);

// 지도 중심 기준 반경 500m 내 정류장 provider (지도용)
final nearbyStopsProvider = Provider<List<({Stop s, int m})>>((ref) {
  final stops = ref
      .watch(stopsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <Stop>[]);
  final mapCenter = ref.watch(mapCenterProvider);
  final userPos = ref
      .watch(locationController)
      .maybeWhen(data: (p) => p, orElse: () => null);

  // 지도 중심이 없으면 사용자 위치 사용
  final center =
      mapCenter ??
      (userPos != null ? LatLng(userPos.latitude, userPos.longitude) : null);

  if (center == null) return [];

  final res = <({Stop s, int m})>[];

  for (final s in stops) {
    final distance = _distM(center.latitude, center.longitude, s.lat, s.lng);
    // 반경 500m 내의 정류장만 포함 (지도용)
    if (distance <= 500) {
      res.add((s: s, m: distance));
    }
  }

  res.sort((a, b) => a.m.compareTo(b.m));
  return res;
});

// 선택된 반경 provider
final selectedRadiusProvider = StateProvider<int>((ref) => 300);

// 리스트용: 사용자 위치 기준 선택된 반경 내 정류장 provider
final nearbyStopsListProvider = Provider<List<({Stop s, int m})>>((ref) {
  final stops = ref
      .watch(stopsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <Stop>[]);
  final userPos = ref
      .watch(locationController)
      .maybeWhen(data: (p) => p, orElse: () => null);
  final selectedRadius = ref.watch(selectedRadiusProvider);

  print('📍 nearbyStopsListProvider 실행 - 반경: ${selectedRadius}m, 정류장 수: ${stops.length}');

  if (userPos == null) {
    print('📍 사용자 위치 없음');
    return [];
  }

  final res = <({Stop s, int m})>[];

  for (final s in stops) {
    final distance = _distM(userPos.latitude, userPos.longitude, s.lat, s.lng);
    // 선택된 반경 내의 정류장만 포함 (리스트용)
    if (distance <= selectedRadius) {
      res.add((s: s, m: distance));
    }
  }

  res.sort((a, b) => a.m.compareTo(b.m));
  print('📍 필터링 결과: ${res.length}개 정류장 (반경 ${selectedRadius}m)');
  return res;
});

// 검색 쿼리 provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 검색된 정류장 provider
final searchResultsProvider = Provider<List<Stop>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final stops = ref
      .watch(stopsProvider)
      .maybeWhen(data: (v) => v, orElse: () => const <Stop>[]);

  if (query.isEmpty) return [];

  final lowerQuery = query.toLowerCase();
  return stops.where((stop) {
    return stop.name.toLowerCase().contains(lowerQuery) ||
        stop.id.toLowerCase().contains(lowerQuery) ||
        stop.arsno.toLowerCase().contains(lowerQuery);
  }).toList();
});
