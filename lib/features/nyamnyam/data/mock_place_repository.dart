import 'dart:convert';
import 'package:flutter/services.dart';
import 'place_model.dart';
import 'place_repository.dart';

class MockPlaceRepository implements PlaceRepository {
  final Map<String, _CacheEntry> _cache = {};

  @override
  Future<Result<List<Place>>> findPlaces({
    required double centerLat,
    required double centerLon,
    required int radiusMeters,
    List<PlaceCategory> categories = const [PlaceCategory.restaurant, PlaceCategory.cafe],
    int limit = 50,
    PlaceSort sort = PlaceSort.distance,
  }) async {
    try {
      final key = '${categories.map((c) => c.value).join(',')}|${centerLat.toStringAsFixed(4)}|${centerLon.toStringAsFixed(4)}|$radiusMeters';
      final now = DateTime.now();
      final hit = _cache[key];
      if (hit != null && now.difference(hit.t).inMinutes < 10) {
        return Success(hit.v, isFromCache: true);
      }

      final allPlaces = <Place>[];

      for (final category in categories) {
        final categoryCode = category == PlaceCategory.restaurant ? 'FD6' : 'CE7';
        try {
          final jsonStr = await rootBundle.loadString('assets/mock/nyam_$categoryCode.json');
          final map = json.decode(jsonStr) as Map<String, dynamic>;
          final docs = (map['documents'] as List).cast<Map<String, dynamic>>();

          final items = docs.map((d) {
            final dist = int.tryParse('${d['distance'] ?? ''}') ?? 0;
            return Place(
              id: d['id'] as String,
              name: d['place_name'] as String,
              category: category,
              lat: double.parse((d['y'] ?? d['center_y']).toString()),
              lon: double.parse((d['x'] ?? d['center_x']).toString()),
              distanceMeters: dist,
              source: PlaceSource.osm,
              address: (d['road_address_name'] as String?)?.isNotEmpty == true
                  ? d['road_address_name'] as String
                  : d['address_name'] as String?,
            );
          }).toList();
          allPlaces.addAll(items);
        } catch (e) {
          // Skip if category file doesn't exist
        }
      }

      // Sort places
      switch (sort) {
        case PlaceSort.distance:
          allPlaces.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
          break;
        case PlaceSort.name:
          allPlaces.sort((a, b) => a.name.compareTo(b.name));
          break;
      }

      final top = allPlaces.take(limit).toList();
      _cache[key] = _CacheEntry(top, now);
      return Success(top);
    } catch (e) {
      return Failure('Mock 데이터 로드 중 오류가 발생했습니다: $e');
    }
  }
}

class _CacheEntry { 
  final List<Place> v; 
  final DateTime t; 
  _CacheEntry(this.v, this.t); 
}

