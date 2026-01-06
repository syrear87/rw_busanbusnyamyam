// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CachedStationImpl _$$CachedStationImplFromJson(Map<String, dynamic> json) =>
    _$CachedStationImpl(
      bstopid: json['bstopid'] as String,
      bstopnm: json['bstopnm'] as String,
      arsno: json['arsno'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$CachedStationImplToJson(_$CachedStationImpl instance) =>
    <String, dynamic>{
      'bstopid': instance.bstopid,
      'bstopnm': instance.bstopnm,
      'arsno': instance.arsno,
      'lat': instance.lat,
      'lng': instance.lng,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_$CachedArrivalImpl _$$CachedArrivalImplFromJson(Map<String, dynamic> json) =>
    _$CachedArrivalImpl(
      arsno: json['arsno'] as String,
      bstopid: json['bstopid'] as String,
      nodenm: json['nodenm'] as String,
      gpsx: (json['gpsx'] as num).toDouble(),
      gpsy: (json['gpsy'] as num).toDouble(),
      lineno: json['lineno'] as String,
      lineid: json['lineid'] as String,
      bstopidx: (json['bstopidx'] as num).toInt(),
      bustype: json['bustype'] as String,
      carno1: json['carno1'] as String,
      carno2: json['carno2'] as String,
      min1: json['min1'] as String,
      min2: json['min2'] as String,
      station1: json['station1'] as String,
      station2: json['station2'] as String,
      lowplate1: json['lowplate1'] as String,
      lowplate2: json['lowplate2'] as String,
      seat1: json['seat1'] as String,
      seat2: json['seat2'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$CachedArrivalImplToJson(_$CachedArrivalImpl instance) =>
    <String, dynamic>{
      'arsno': instance.arsno,
      'bstopid': instance.bstopid,
      'nodenm': instance.nodenm,
      'gpsx': instance.gpsx,
      'gpsy': instance.gpsy,
      'lineno': instance.lineno,
      'lineid': instance.lineid,
      'bstopidx': instance.bstopidx,
      'bustype': instance.bustype,
      'carno1': instance.carno1,
      'carno2': instance.carno2,
      'min1': instance.min1,
      'min2': instance.min2,
      'station1': instance.station1,
      'station2': instance.station2,
      'lowplate1': instance.lowplate1,
      'lowplate2': instance.lowplate2,
      'seat1': instance.seat1,
      'seat2': instance.seat2,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_$CachedRouteImpl _$$CachedRouteImplFromJson(Map<String, dynamic> json) =>
    _$CachedRouteImpl(
      lineid: json['lineid'] as String,
      lineno: json['lineno'] as String,
      routeType: json['routeType'] as String,
      startStation: json['startStation'] as String,
      endStation: json['endStation'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$CachedRouteImplToJson(_$CachedRouteImpl instance) =>
    <String, dynamic>{
      'lineid': instance.lineid,
      'lineno': instance.lineno,
      'routeType': instance.routeType,
      'startStation': instance.startStation,
      'endStation': instance.endStation,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_$CachePolicyImpl _$$CachePolicyImplFromJson(Map<String, dynamic> json) =>
    _$CachePolicyImpl(
      arrivalCacheExpiry: json['arrivalCacheExpiry'] == null
          ? const Duration(minutes: 5)
          : Duration(microseconds: (json['arrivalCacheExpiry'] as num).toInt()),
      stationCacheExpiry: json['stationCacheExpiry'] == null
          ? const Duration(hours: 24)
          : Duration(microseconds: (json['stationCacheExpiry'] as num).toInt()),
      routeCacheExpiry: json['routeCacheExpiry'] == null
          ? const Duration(hours: 12)
          : Duration(microseconds: (json['routeCacheExpiry'] as num).toInt()),
      refreshInterval: json['refreshInterval'] == null
          ? const Duration(minutes: 1)
          : Duration(microseconds: (json['refreshInterval'] as num).toInt()),
      enableOfflineMode: json['enableOfflineMode'] as bool? ?? true,
    );

Map<String, dynamic> _$$CachePolicyImplToJson(_$CachePolicyImpl instance) =>
    <String, dynamic>{
      'arrivalCacheExpiry': instance.arrivalCacheExpiry.inMicroseconds,
      'stationCacheExpiry': instance.stationCacheExpiry.inMicroseconds,
      'routeCacheExpiry': instance.routeCacheExpiry.inMicroseconds,
      'refreshInterval': instance.refreshInterval.inMicroseconds,
      'enableOfflineMode': instance.enableOfflineMode,
    };

_$CacheStatusImpl _$$CacheStatusImplFromJson(Map<String, dynamic> json) =>
    _$CacheStatusImpl(
      isOnline: json['isOnline'] as bool,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      totalCachedItems: (json['totalCachedItems'] as num).toInt(),
      expiredItems: (json['expiredItems'] as num).toInt(),
      hasOfflineData: json['hasOfflineData'] as bool,
    );

Map<String, dynamic> _$$CacheStatusImplToJson(_$CacheStatusImpl instance) =>
    <String, dynamic>{
      'isOnline': instance.isOnline,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'totalCachedItems': instance.totalCachedItems,
      'expiredItems': instance.expiredItems,
      'hasOfflineData': instance.hasOfflineData,
    };
