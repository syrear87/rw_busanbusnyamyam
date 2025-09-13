import 'place_model.dart';

abstract class PlaceRepository {
  Future<List<Place>> search({
    required double lat,
    required double lng,
    required int radiusM,        // 200|400|700
    required String category,    // 'FD6' or 'CE7'
  });
}

