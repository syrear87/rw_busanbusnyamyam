import 'place_model.dart';

abstract class PlaceRepository {
  Future<Result<List<Place>>> findPlaces({
    required double centerLat,
    required double centerLon,
    required int radiusMeters,
    List<PlaceCategory> categories = const [PlaceCategory.restaurant, PlaceCategory.cafe],
    int limit = 50,
    PlaceSort sort = PlaceSort.distance,
  });
}

