import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'place_repository.dart';
import 'overpass_place_repository.dart';
import 'kakao_place_repository.dart';
import 'cached_place_repository.dart';
import 'place_model.dart';
import 'nyam_query_state.dart';
import 'location_provider.dart';
import '../../stops/data/location_provider.dart' as stops_location;

// Repository provider - 카카오맵 API 사용
final placeRepoProvider = Provider<PlaceRepository>((ref) {
  final kakaoRepo = KakaoPlaceRepository();
  return CachedPlaceRepository(kakaoRepo);
});

// Query state provider with location integration
final nyamQueryProvider =
    StateNotifierProvider<NyamQueryNotifier, NyamQueryState>((ref) {
      final notifier = NyamQueryNotifier();

      // Watch stops location changes and update center automatically
      ref.listen(stops_location.locationController, (previous, next) {
        final position = next.maybeWhen(data: (pos) => pos, orElse: () => null);
        if (position != null) {
          print('📍 정류장 탭 위치 변경 감지: ${position.latitude}, ${position.longitude}');
          notifier.updateFromLocation(position.latitude, position.longitude);
        }
      });

      return notifier;
    });

// Places provider with debouncing
final placesProvider = AsyncNotifierProvider<PlacesNotifier, List<Place>>(() {
  return PlacesNotifier();
});

class PlacesNotifier extends AsyncNotifier<List<Place>> {
  Timer? _debounceTimer;
  String? _lastQueryHash;
  List<Place>? _lastSuccessfulResult;

  @override
  Future<List<Place>> build() async {
    final query = ref.watch(nyamQueryProvider);
    final location = ref.watch(locationProvider);
    final queryHash = _generateQueryHash(query);

    // 정류장이 선택된 경우나 유효한 위치가 있을 때만 검색 실행
    if (query.selectedStop == null && !location.hasValidLocation) {
      print('⏸️ 위치 로드 대기 중... 검색 보류');
      return []; // 빈 리스트 반환하여 검색 보류
    }

    // 정류장이 선택된 경우 로그 출력
    if (query.selectedStop != null) {
      print('🚏 정류장 주변 검색: ${query.selectedStop!.name} (${query.radius}m)');
    } else {
      print('📍 내 위치 주변 검색: (${query.centerLat.toStringAsFixed(4)}, ${query.centerLon.toStringAsFixed(4)}) (${query.radius}m)');
    }

    // 동일한 파라미터로 중복 호출 방지
    if (_lastQueryHash == queryHash && _lastSuccessfulResult != null) {
      return _lastSuccessfulResult!;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create completer for debounced execution
    final completer = Completer<List<Place>>();

    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      try {
        final repo = ref.read(placeRepoProvider);
        final result = await repo.findPlaces(
          centerLat: query.centerLat,
          centerLon: query.centerLon,
          radiusMeters: query.radius,
          categories: query.placeCategories,
          limit: 50,
          sort: PlaceSort.distance, // Always sort by distance
        );

        switch (result) {
          case Success(data: final places):
            print('✅ 검색 완료: ${places.length}개 장소 발견');
            _lastQueryHash = queryHash;
            _lastSuccessfulResult = places;
            completer.complete(places);
          case Failure(message: final message):
            print('❌ 검색 실패: $message');
            completer.completeError(Exception(message));
        }
      } catch (e) {
        print('💥 검색 오류: $e');
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  String _generateQueryHash(NyamQueryState query) {
    return '${query.centerLat.toStringAsFixed(6)}_${query.centerLon.toStringAsFixed(6)}_${query.radius}_${query.category.name}_${query.selectedStop?.id ?? 'null'}';
  }

  void refresh() {
    ref.invalidateSelf();
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
