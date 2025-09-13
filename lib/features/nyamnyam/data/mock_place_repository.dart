import 'dart:convert';
import 'package:flutter/services.dart';
import 'place_model.dart';
import 'place_repository.dart';

class MockPlaceRepository implements PlaceRepository {
  final Map<String, _CacheEntry> _cache = {};
  
  @override
  Future<List<Place>> search({
    required double lat, 
    required double lng, 
    required int radiusM, 
    required String category,
  }) async {
    final key = '${category}|${lat.toStringAsFixed(4)}|${lng.toStringAsFixed(4)}|$radiusM';
    final now = DateTime.now();
    final hit = _cache[key];
    if (hit != null && now.difference(hit.t).inMinutes < 10) return hit.v;

    // load bundled JSON: assets/mock/nyam_<cat>.json
    final jsonStr = await rootBundle.loadString('assets/mock/nyam_${category}.json');
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    final docs = (map['documents'] as List).cast<Map<String, dynamic>>();

    // distance string -> int, sort asc
    final items = docs.map((d) {
      final dist = int.tryParse('${d['distance'] ?? ''}');
      return Place(
        id: d['id'] as String,
        name: d['place_name'] as String,
        url: d['place_url'] as String? ?? '',
        category: d['category_group_code'] as String? ?? category,
        lat: double.parse((d['y'] ?? d['center_y']).toString()),
        lng: double.parse((d['x'] ?? d['center_x']).toString()),
        distanceM: dist,
        address: (d['road_address_name'] as String?)?.isNotEmpty == true
            ? d['road_address_name'] as String
            : d['address_name'] as String?,
      );
    }).toList()
      ..sort((a, b) => (a.distanceM ?? 1<<30).compareTo(b.distanceM ?? 1<<30));

    final top = items.take(20).toList();
    _cache[key] = _CacheEntry(top, now);
    return top;
  }
}

class _CacheEntry { 
  final List<Place> v; 
  final DateTime t; 
  _CacheEntry(this.v, this.t); 
}

