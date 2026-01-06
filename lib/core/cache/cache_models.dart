import 'package:freezed_annotation/freezed_annotation.dart';

part 'cache_models.freezed.dart';
part 'cache_models.g.dart';

/// 캐시된 정류장 정보
@freezed
class CachedStation with _$CachedStation {
  const factory CachedStation({
    required String bstopid,
    required String bstopnm,
    required String arsno,
    required double lat,
    required double lng,
    required DateTime cachedAt,
    required DateTime expiresAt,
  }) = _CachedStation;

  factory CachedStation.fromJson(Map<String, dynamic> json) =>
      _$CachedStationFromJson(json);
}

/// 캐시된 도착 정보
@freezed
class CachedArrival with _$CachedArrival {
  const factory CachedArrival({
    required String arsno,
    required String bstopid,
    required String nodenm,
    required double gpsx,
    required double gpsy,
    required String lineno,
    required String lineid,
    required int bstopidx,
    required String bustype,
    required String carno1,
    required String carno2,
    required String min1,
    required String min2,
    required String station1,
    required String station2,
    required String lowplate1,
    required String lowplate2,
    required String seat1,
    required String seat2,
    required DateTime cachedAt,
    required DateTime expiresAt,
  }) = _CachedArrival;

  factory CachedArrival.fromJson(Map<String, dynamic> json) =>
      _$CachedArrivalFromJson(json);
}

/// 캐시된 노선 정보
@freezed
class CachedRoute with _$CachedRoute {
  const factory CachedRoute({
    required String lineid,
    required String lineno,
    required String routeType,
    required String startStation,
    required String endStation,
    required DateTime cachedAt,
    required DateTime expiresAt,
  }) = _CachedRoute;

  factory CachedRoute.fromJson(Map<String, dynamic> json) =>
      _$CachedRouteFromJson(json);
}

/// 캐시 정책 설정
@freezed
class CachePolicy with _$CachePolicy {
  const factory CachePolicy({
    @Default(Duration(minutes: 5)) Duration arrivalCacheExpiry,
    @Default(Duration(hours: 24)) Duration stationCacheExpiry,
    @Default(Duration(hours: 12)) Duration routeCacheExpiry,
    @Default(Duration(minutes: 1)) Duration refreshInterval,
    @Default(true) bool enableOfflineMode,
  }) = _CachePolicy;

  factory CachePolicy.fromJson(Map<String, dynamic> json) =>
      _$CachePolicyFromJson(json);
}

/// 캐시 상태 정보
@freezed
class CacheStatus with _$CacheStatus {
  const factory CacheStatus({
    required bool isOnline,
    required DateTime lastUpdate,
    required int totalCachedItems,
    required int expiredItems,
    required bool hasOfflineData,
  }) = _CacheStatus;

  factory CacheStatus.fromJson(Map<String, dynamic> json) =>
      _$CacheStatusFromJson(json);
}

