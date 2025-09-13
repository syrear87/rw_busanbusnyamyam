import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'place_repository.dart';
import 'mock_place_repository.dart';
import 'place_model.dart';

final selectedStopNameProvider = StateProvider<String>((_) => '정류장 미선택');
final categoryProvider = StateProvider<String>((_) => 'FD6'); // FD6 맛집, CE7 카페
final radiusProvider = StateProvider<int>((_) => 400);
final placeRepoProvider = Provider<PlaceRepository>((_) => MockPlaceRepository());

final placeResultsProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final repo = ref.read(placeRepoProvider);
  final cat = ref.watch(categoryProvider);
  final rad = ref.watch(radiusProvider);
  // temp coordinates (부산 시청 근처). Replace with chosen stop lat/lng via another provider.
  final lat = 35.1796, lng = 129.0756;
  return repo.search(lat: lat, lng: lng, radiusM: rad, category: cat);
});

