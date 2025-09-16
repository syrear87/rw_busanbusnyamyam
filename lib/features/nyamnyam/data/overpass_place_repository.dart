import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'place_model.dart';
import 'place_repository.dart';

class OverpassPlaceRepository implements PlaceRepository {
  static const String _primaryEndpoint = 'https://overpass-api.de/api/interpreter';
  static const List<String> _mirrorEndpoints = [
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass-api.de/api/interpreter',
  ];

  static const int _timeoutSeconds = 25;
  static const int _maxRetries = 2;

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
      final query = _buildOverpassQuery(
        centerLat: centerLat,
        centerLon: centerLon,
        radiusMeters: radiusMeters,
        categories: categories,
        limit: limit,
      );

      final response = await _executeQueryWithRetry(query);
      if (response == null) {
        return const Failure('모든 서버에서 응답을 받을 수 없습니다');
      }

      final places = _parseOverpassResponse(
        response,
        centerLat: centerLat,
        centerLon: centerLon,
      );

      final sortedPlaces = _sortPlaces(places, sort);
      return Success(sortedPlaces.take(limit).toList());

    } catch (e, stack) {
      return Failure('장소 검색 중 오류가 발생했습니다: $e', exception: e is Exception ? e : Exception(e.toString()));
    }
  }

  String _buildOverpassQuery({
    required double centerLat,
    required double centerLon,
    required int radiusMeters,
    required List<PlaceCategory> categories,
    required int limit,
  }) {
    final amenityValues = categories.map((c) {
      switch (c) {
        case PlaceCategory.restaurant:
          return 'restaurant';
        case PlaceCategory.cafe:
          return 'cafe';
      }
    }).join('|');

    return '''
[out:json][timeout:$_timeoutSeconds];
(
  node["amenity"~"^($amenityValues)\$"](around:$radiusMeters,$centerLat,$centerLon);
  way["amenity"~"^($amenityValues)\$"](around:$radiusMeters,$centerLat,$centerLon);
  relation["amenity"~"^($amenityValues)\$"](around:$radiusMeters,$centerLat,$centerLon);
);
out center tags $limit;
''';
  }

  Future<Map<String, dynamic>?> _executeQueryWithRetry(String query) async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      for (final endpoint in (attempt == 0 ? [_primaryEndpoint] : _mirrorEndpoints)) {
        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'data': query},
          ).timeout(Duration(seconds: _timeoutSeconds));

          if (response.statusCode == 200) {
            return json.decode(response.body);
          } else if (response.statusCode == 429) {
            await Future.delayed(Duration(seconds: (attempt + 1) * 2));
            continue;
          }
        } catch (e) {
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: (attempt + 1) * 2));
          }
        }
      }
    }
    return null;
  }

  List<Place> _parseOverpassResponse(
    Map<String, dynamic> response, {
    required double centerLat,
    required double centerLon,
  }) {
    final elements = response['elements'] as List<dynamic>? ?? [];
    final places = <Place>[];

    for (final element in elements) {
      try {
        final tags = Map<String, String>.from(element['tags'] ?? {});
        final name = tags['name'];
        if (name == null || name.isEmpty) continue;

        double? lat, lon;

        if (element['type'] == 'node') {
          lat = (element['lat'] as num?)?.toDouble();
          lon = (element['lon'] as num?)?.toDouble();
        } else if (element['center'] != null) {
          lat = (element['center']['lat'] as num?)?.toDouble();
          lon = (element['center']['lon'] as num?)?.toDouble();
        }

        if (lat == null || lon == null) continue;

        final amenity = tags['amenity'] ?? '';
        PlaceCategory category;
        if (amenity == 'restaurant') {
          category = PlaceCategory.restaurant;
        } else if (amenity == 'cafe') {
          category = PlaceCategory.cafe;
        } else {
          continue;
        }

        final distance = _calculateDistance(centerLat, centerLon, lat, lon);

        final place = Place(
          id: element['id'].toString(),
          name: name,
          category: category,
          lat: lat,
          lon: lon,
          address: _buildAddress(tags),
          phone: tags['phone'],
          distanceMeters: distance,
          source: PlaceSource.osm,
          tags: tags,
        );

        places.add(place);
      } catch (e) {
        continue;
      }
    }

    return places;
  }

  String? _buildAddress(Map<String, String> tags) {
    final parts = <String>[];

    if (tags['addr:street'] != null && tags['addr:housenumber'] != null) {
      parts.add('${tags['addr:street']} ${tags['addr:housenumber']}');
    }
    if (tags['addr:city'] != null) {
      parts.add(tags['addr:city']!);
    }

    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  int _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) *
        sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return (earthRadius * c).round();
  }

  List<Place> _sortPlaces(List<Place> places, PlaceSort sort) {
    switch (sort) {
      case PlaceSort.distance:
        places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        break;
      case PlaceSort.name:
        places.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return places;
  }
}