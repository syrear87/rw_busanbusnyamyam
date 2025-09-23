import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../core/config/kakao_config.dart';
import 'place_model.dart';
import 'place_repository.dart';

class KakaoPlaceRepository implements PlaceRepository {
  static const int _timeoutSeconds = 15;
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
      final places = <Place>[];
      
      // 각 카테고리별로 검색
      for (final category in categories) {
        final categoryCode = KakaoConfig.categoryCodes[category.name];
        if (categoryCode == null) continue;

        final searchResults = await _searchPlacesByCategory(
          centerLat: centerLat,
          centerLon: centerLon,
          radiusMeters: radiusMeters,
          categoryCode: categoryCode,
          limit: limit,
        );

        places.addAll(searchResults);
      }

      // 중복 제거 (같은 장소명과 주소)
      final uniquePlaces = _removeDuplicates(places);
      
      // 거리순 정렬
      final sortedPlaces = _sortPlacesByDistance(uniquePlaces, centerLat, centerLon);
      
      return Success(sortedPlaces.take(limit).toList());

    } catch (e, stack) {
      return Failure('카카오맵 검색 중 오류가 발생했습니다: $e', exception: e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<List<Place>> _searchPlacesByCategory({
    required double centerLat,
    required double centerLon,
    required int radiusMeters,
    required String categoryCode,
    required int limit,
  }) async {
    final query = '음식점'; // 카카오맵 API는 키워드 검색이므로 일반적인 키워드 사용
    final url = Uri.parse(KakaoConfig.searchKeywordUrl).replace(
      queryParameters: {
        'query': query,
        'x': centerLon.toString(),
        'y': centerLat.toString(),
        'radius': radiusMeters.toString(),
        'category_group_code': categoryCode,
        'size': limit.clamp(1, 15).toString(), // 카카오맵 API는 최대 15개까지만 지원
        'sort': 'distance', // 거리순 정렬
      },
    );

    final response = await _makeRequest(url);
    if (response == null) return [];

    return _parseKakaoResponse(response, centerLat, centerLon);
  }

  Future<http.Response?> _makeRequest(Uri url) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'KakaoAK ${KakaoConfig.restApiKey}',
            'Content-Type': 'application/json',
          },
        ).timeout(Duration(seconds: _timeoutSeconds));

        if (response.statusCode == 200) {
          return response;
        } else {
          print('❌ 카카오맵 API 오류: ${response.statusCode} - ${response.body}');
          if (attempt == _maxRetries - 1) {
            throw Exception('API 요청 실패: ${response.statusCode}');
          }
        }
      } catch (e) {
        print('❌ 카카오맵 API 요청 실패 (시도 ${attempt + 1}/$_maxRetries): $e');
        if (attempt == _maxRetries - 1) {
          rethrow;
        }
        // 재시도 전 잠시 대기
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    return null;
  }

  List<Place> _parseKakaoResponse(http.Response response, double centerLat, double centerLon) {
    try {
      final jsonData = json.decode(response.body);
      final documents = jsonData['documents'] as List<dynamic>? ?? [];

      return documents.map((doc) {
        final placeName = doc['place_name'] as String? ?? '';
        final address = doc['address_name'] as String? ?? doc['road_address_name'] as String? ?? '';
        final phone = doc['phone'] as String?;
        final category = doc['category_group_code'] as String? ?? '';
        final x = double.tryParse(doc['x']?.toString() ?? '0') ?? 0.0;
        final y = double.tryParse(doc['y']?.toString() ?? '0') ?? 0.0;

        // 거리 계산
        final distance = Geolocator.distanceBetween(centerLat, centerLon, y, x).round();

        // 카테고리 매핑
        PlaceCategory placeCategory;
        if (category == 'FD6') {
          placeCategory = PlaceCategory.restaurant;
        } else if (category == 'CE7') {
          placeCategory = PlaceCategory.cafe;
        } else {
          placeCategory = PlaceCategory.restaurant; // 기본값
        }

        return Place(
          id: 'kakao_${doc['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          name: placeName,
          category: placeCategory,
          lat: y,
          lon: x,
          address: address.isNotEmpty ? address : null,
          phone: phone?.isNotEmpty == true ? phone : null,
          distanceMeters: distance,
          source: PlaceSource.kakao,
          tags: {
            'category_group_code': category,
            'category_name': doc['category_name'] as String? ?? '',
          },
        );
      }).toList();

    } catch (e) {
      print('❌ 카카오맵 응답 파싱 오류: $e');
      return [];
    }
  }

  List<Place> _removeDuplicates(List<Place> places) {
    final seen = <String>{};
    return places.where((place) {
      final key = '${place.name}_${place.address ?? ''}';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  List<Place> _sortPlacesByDistance(List<Place> places, double centerLat, double centerLon) {
    places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return places;
  }
}
