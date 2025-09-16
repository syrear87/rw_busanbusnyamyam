import 'dart:developer' as dev;
import 'place_model.dart';
import 'place_repository.dart';
import 'place_cache.dart';

class CachedPlaceRepository implements PlaceRepository {
  final PlaceRepository _repository;
  final PlaceCache _cache = PlaceCache();

  CachedPlaceRepository(this._repository);

  @override
  Future<Result<List<Place>>> findPlaces({
    required double centerLat,
    required double centerLon,
    required int radiusMeters,
    List<PlaceCategory> categories = const [PlaceCategory.restaurant, PlaceCategory.cafe],
    int limit = 50,
    PlaceSort sort = PlaceSort.distance,
  }) async {
    final params = PlaceSearchParams(
      centerLat: centerLat,
      centerLon: centerLon,
      radiusMeters: radiusMeters,
      categories: categories,
      limit: limit,
      sort: sort,
    );

    // Try cache first
    final cached = await _cache.get(params);
    if (cached != null) {
      return cached;
    }

    // Fetch from repository
    try {
      final result = await _repository.findPlaces(
        centerLat: centerLat,
        centerLon: centerLon,
        radiusMeters: radiusMeters,
        categories: categories,
        limit: limit,
        sort: sort,
      );

      switch (result) {
        case Success(data: final places):
          // Cache successful result
          await _cache.set(params, places);
          dev.log('Network SUCCESS: ${places.length} places');
          return Success(places);
        case Failure(message: final message, exception: final exception):
          // Try to return last successful result on network failure
          final fallback = await _cache.getLastSuccess();
          if (fallback != null) {
            dev.log('Network FAILED, using fallback cache');
            return fallback;
          } else {
            dev.log('Network FAILED, no fallback available');
            return Failure(message, exception: exception);
          }
      }
    } catch (e) {
      // Try fallback cache on any error
      final fallback = await _cache.getLastSuccess();
      if (fallback != null) {
        dev.log('Exception occurred, using fallback cache: $e');
        return fallback;
      } else {
        dev.log('Exception occurred, no fallback available: $e');
        return Failure('네트워크 오류가 발생했습니다: $e');
      }
    }
  }
}