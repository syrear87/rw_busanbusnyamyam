import 'dart:async';
import 'package:flutter/foundation.dart';
import 'cache_database.dart';
import 'cache_models.dart';
import '../network/bis_models.dart';
import '../network/bis_api.dart';

/// 캐시 서비스 - API 호출과 로컬 캐시를 통합 관리
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final CachePolicy _policy = const CachePolicy();
  Timer? _cleanupTimer;

  /// 서비스 초기화
  Future<void> initialize() async {
    print('🚀 캐시 서비스 초기화');
    
    // 주기적으로 만료된 데이터 정리
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => CacheDatabase.cleanExpiredData(),
    );
  }

  /// 서비스 종료
  void dispose() {
    _cleanupTimer?.cancel();
    CacheDatabase.close();
  }

  /// 정류장 정보 조회 (캐시 우선, API 백업)
  Future<List<Station>> getStations({
    String? name,
    String? arsno,
    int page = 1,
    int rows = 10,
  }) async {
    try {
      print('🔍 정류장 정보 조회 시작 (캐시 우선)');
      
      // 1. API 호출 시도
      final apiStations = await BisApi.stationList(
        name: name,
        arsno: arsno,
        page: page,
        rows: rows,
      );

      // 2. API 성공 시 캐시에 저장
      for (final station in apiStations) {
        final cachedStation = CachedStation(
          bstopid: station.bstopid,
          bstopnm: station.bstopnm,
          arsno: station.arsno,
          lat: station.lat,
          lng: station.lng,
          cachedAt: DateTime.now(),
          expiresAt: DateTime.now().add(_policy.stationCacheExpiry),
        );
        await CacheDatabase.saveStation(cachedStation);
      }

      print('✅ API 호출 성공: ${apiStations.length}개 정류장');
      return apiStations;

    } catch (e) {
      print('❌ API 호출 실패, 캐시에서 조회: $e');
      
      // 3. API 실패 시 캐시에서 조회
      final cachedStations = <Station>[];
      
      if (name != null && name.isNotEmpty) {
        // 이름으로 검색하는 경우 캐시에서 직접 검색은 제한적
        // 대신 최근 조회한 정류장들 중에서 필터링
        print('⚠️ 이름 검색은 캐시에서 제한적 지원');
        return [];
      }
      
      if (arsno != null && arsno.isNotEmpty) {
        // ARS번호로 검색하는 경우 캐시에서 조회 가능
        final cachedStation = await CacheDatabase.getStation(arsno);
        if (cachedStation != null) {
          cachedStations.add(Station(
            bstopid: cachedStation.bstopid,
            bstopnm: cachedStation.bstopnm,
            arsno: cachedStation.arsno,
            lat: cachedStation.lat,
            lng: cachedStation.lng,
          ));
        }
      }

      print('📦 캐시에서 조회: ${cachedStations.length}개 정류장');
      return cachedStations;
    }
  }

  /// 도착 정보 조회 (캐시 우선, API 백업)
  Future<List<Arrival>> getArrivals(String arsno) async {
    try {
      print('🚌 도착 정보 조회 시작 (캐시 우선) - ARS: $arsno');
      
      // 1. API 호출 시도
      final apiArrivals = await BisApi.arrivalsByArs(arsno);

      // 2. API 성공 시 캐시에 저장
      final cachedArrivals = apiArrivals.map((arrival) => CachedArrival(
        arsno: arsno,
        bstopid: '', // ARS 기반 호출이므로 bstopid는 비어있음
        nodenm: arrival.nodenm,
        gpsx: 0.0, // ARS 기반 호출이므로 좌표는 비어있음
        gpsy: 0.0,
        lineno: arrival.lineno,
        lineid: arrival.lineid,
        bstopidx: 0, // ARS 기반 호출이므로 순번은 비어있음
        bustype: arrival.bustype,
        carno1: '', // BIS API에서 차량번호를 제공하지 않음
        carno2: '',
        min1: arrival.min1,
        min2: arrival.min2,
        station1: arrival.station1,
        station2: arrival.station2,
        lowplate1: '', // BIS API에서 저상버스 정보를 제공하지 않음
        lowplate2: '',
        seat1: '', // BIS API에서 좌석 정보를 제공하지 않음
        seat2: '',
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(_policy.arrivalCacheExpiry),
      )).toList();

      await CacheDatabase.saveArrivals(cachedArrivals);

      print('✅ API 호출 성공: ${apiArrivals.length}개 도착정보');
      return apiArrivals;

    } catch (e) {
      print('❌ API 호출 실패, 캐시에서 조회: $e');
      
      // 3. API 실패 시 캐시에서 조회
      final cachedArrivals = await CacheDatabase.getArrivals(arsno);
      final arrivals = cachedArrivals.map((cached) => Arrival(
        lineid: cached.lineid,
        lineno: cached.lineno,
        nodenm: cached.nodenm,
        min1: cached.min1,
        station1: cached.station1,
        min2: cached.min2,
        station2: cached.station2,
        bustype: cached.bustype,
      )).toList();

      print('📦 캐시에서 조회: ${arrivals.length}개 도착정보');
      return arrivals;
    }
  }

  /// 노선 정보 조회 (캐시 우선, API 백업)
  Future<List<RouteStop>> getRouteStations(String lineid) async {
    try {
      print('🚌 노선 정보 조회 시작 (캐시 우선) - LineID: $lineid');
      
      // 1. API 호출 시도
      final apiStations = await BisApi.lineStations(lineid);

      // 2. API 성공 시 캐시에 저장
      final cachedRoute = CachedRoute(
        lineid: lineid,
        lineno: apiStations.isNotEmpty ? apiStations.first.lineno : '',
        routeType: 'BUS', // 기본값
        startStation: apiStations.isNotEmpty ? apiStations.first.bstopnm : '',
        endStation: apiStations.isNotEmpty ? apiStations.last.bstopnm : '',
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(_policy.routeCacheExpiry),
      );
      await CacheDatabase.saveRoute(cachedRoute);

      print('✅ API 호출 성공: ${apiStations.length}개 정류장');
      return apiStations;

    } catch (e) {
      print('❌ API 호출 실패, 캐시에서 조회: $e');
      
      // 3. API 실패 시 캐시에서 조회
      final cachedRoute = await CacheDatabase.getRoute(lineid);
      if (cachedRoute != null) {
        print('📦 캐시에서 노선 정보 조회: ${cachedRoute.lineno}');
        // 캐시된 노선 정보만으로는 정류장 목록을 제공할 수 없으므로 빈 리스트 반환
        return [];
      }

      print('📦 캐시에 노선 정보 없음');
      return [];
    }
  }

  /// 강제 새로고침 (캐시 무시하고 API만 호출)
  Future<List<Arrival>> refreshArrivals(String arsno) async {
    print('🔄 도착 정보 강제 새로고침 - ARS: $arsno');
    
    try {
      final arrivals = await BisApi.arrivalsByArs(arsno);
      
      // 새 데이터를 캐시에 저장
      final cachedArrivals = arrivals.map((arrival) => CachedArrival(
        arsno: arsno,
        bstopid: '',
        nodenm: arrival.nodenm,
        gpsx: 0.0,
        gpsy: 0.0,
        lineno: arrival.lineno,
        lineid: arrival.lineid,
        bstopidx: 0,
        bustype: arrival.bustype,
        carno1: '',
        carno2: '',
        min1: arrival.min1,
        min2: arrival.min2,
        station1: arrival.station1,
        station2: arrival.station2,
        lowplate1: '',
        lowplate2: '',
        seat1: '',
        seat2: '',
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(_policy.arrivalCacheExpiry),
      )).toList();

      await CacheDatabase.saveArrivals(cachedArrivals);

      print('✅ 강제 새로고침 성공: ${arrivals.length}개 도착정보');
      return arrivals;

    } catch (e) {
      print('❌ 강제 새로고침 실패: $e');
      rethrow;
    }
  }

  /// 캐시 상태 조회
  Future<CacheStatus> getCacheStatus() async {
    final status = await CacheDatabase.getCacheStatus();
    return status;
  }

  /// 캐시 정리
  Future<void> clearCache() async {
    print('🧹 전체 캐시 정리');
    await CacheDatabase.cleanExpiredData();
  }

  /// 오프라인 모드 확인
  bool get isOfflineMode => _policy.enableOfflineMode;
}

