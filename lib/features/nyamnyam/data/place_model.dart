enum PlaceCategory {
  restaurant('RESTAURANT'),
  cafe('CAFE');

  const PlaceCategory(this.value);
  final String value;
}

enum PlaceSource {
  osm('OSM');

  const PlaceSource(this.value);
  final String value;
}

enum PlaceSort {
  distance('DISTANCE'),
  name('NAME');

  const PlaceSort(this.value);
  final String value;
}

class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final double lat;
  final double lon;
  final String? address;
  final String? phone;
  final double? rating;
  final int distanceMeters;
  final PlaceSource source;
  final Map<String, String> tags;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lon,
    required this.distanceMeters,
    required this.source,
    this.address,
    this.phone,
    this.rating,
    this.tags = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.value,
    'lat': lat,
    'lon': lon,
    'address': address,
    'phone': phone,
    'rating': rating,
    'distanceMeters': distanceMeters,
    'source': source.value,
    'tags': tags,
  };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    id: json['id'],
    name: json['name'],
    category: PlaceCategory.values.firstWhere(
      (c) => c.value == json['category'],
      orElse: () => PlaceCategory.restaurant,
    ),
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
    address: json['address'],
    phone: json['phone'],
    rating: json['rating']?.toDouble(),
    distanceMeters: json['distanceMeters'],
    source: PlaceSource.values.firstWhere(
      (s) => s.value == json['source'],
      orElse: () => PlaceSource.osm,
    ),
    tags: Map<String, String>.from(json['tags'] ?? {}),
  );
}

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  final bool isFromCache;

  const Success(this.data, {this.isFromCache = false});
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;

  const Failure(this.message, {this.exception});
}

class PlaceSearchParams {
  final double centerLat;
  final double centerLon;
  final int radiusMeters;
  final List<PlaceCategory> categories;
  final int limit;
  final PlaceSort sort;

  const PlaceSearchParams({
    required this.centerLat,
    required this.centerLon,
    required this.radiusMeters,
    this.categories = const [PlaceCategory.restaurant, PlaceCategory.cafe],
    this.limit = 50,
    this.sort = PlaceSort.distance,
  });

  String get cacheKey => '${centerLat.toStringAsFixed(6)}_${centerLon.toStringAsFixed(6)}_${radiusMeters}_${categories.map((c) => c.value).join(',')}_${sort.value}';

  Map<String, dynamic> toJson() => {
    'centerLat': centerLat,
    'centerLon': centerLon,
    'radiusMeters': radiusMeters,
    'categories': categories.map((c) => c.value).toList(),
    'limit': limit,
    'sort': sort.value,
  };

  factory PlaceSearchParams.fromJson(Map<String, dynamic> json) => PlaceSearchParams(
    centerLat: (json['centerLat'] as num).toDouble(),
    centerLon: (json['centerLon'] as num).toDouble(),
    radiusMeters: json['radiusMeters'],
    categories: (json['categories'] as List<dynamic>)
        .map((c) => PlaceCategory.values.firstWhere((cat) => cat.value == c))
        .toList(),
    limit: json['limit'] ?? 50,
    sort: PlaceSort.values.firstWhere(
      (s) => s.value == json['sort'],
      orElse: () => PlaceSort.distance,
    ),
  );
}

