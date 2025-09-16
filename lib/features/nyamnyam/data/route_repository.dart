import 'place_model.dart';
import 'route_model.dart';

abstract class RouteRepository {
  /// 노선 번호로 노선 정보 검색
  Future<Result<List<BusRoute>>> searchRoutes(String query);

  /// 노선의 정류장 목록 조회
  Future<Result<List<RouteStop>>> getRouteStops(String routeId);

  /// 근처 정류장 검색 (위치 기반)
  Future<Result<List<BusStop>>> getNearbyStops({
    required double lat,
    required double lon,
    required int radiusMeters,
    int limit = 20,
  });

  /// ARS 번호로 정류장 검색
  Future<Result<BusStop?>> getStopByArsNumber(String arsNumber);

  /// 정류장 이름으로 정류장 검색
  Future<Result<List<BusStop>>> searchStops(String query);
}

class RouteSearchParams {
  final String query;
  final int limit;

  const RouteSearchParams({
    required this.query,
    this.limit = 20,
  });
}

class StopSearchParams {
  final double? centerLat;
  final double? centerLon;
  final int? radiusMeters;
  final String? query;
  final String? arsNumber;
  final int limit;

  const StopSearchParams({
    this.centerLat,
    this.centerLon,
    this.radiusMeters,
    this.query,
    this.arsNumber,
    this.limit = 20,
  });

  bool get isLocationSearch => centerLat != null && centerLon != null && radiusMeters != null;
  bool get isTextSearch => query != null && query!.isNotEmpty;
  bool get isArsSearch => arsNumber != null && arsNumber!.isNotEmpty;
}