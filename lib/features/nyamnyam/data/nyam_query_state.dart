import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'place_model.dart';

enum QueryCategory { all, restaurant, cafe }

class SelectedStop {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final int seq;
  final String? direction;

  const SelectedStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.seq,
    this.direction,
  });
}

class NyamQueryState {
  final double centerLat;
  final double centerLon;
  final int radius; // 200, 400, 700
  final QueryCategory category;
  final SelectedStop? selectedStop;

  const NyamQueryState({
    required this.centerLat,
    required this.centerLon,
    this.radius = 400,
    this.category = QueryCategory.all,
    this.selectedStop,
  });

  NyamQueryState copyWith({
    double? centerLat,
    double? centerLon,
    int? radius,
    QueryCategory? category,
    SelectedStop? selectedStop,
  }) {
    return NyamQueryState(
      centerLat: centerLat ?? this.centerLat,
      centerLon: centerLon ?? this.centerLon,
      radius: radius ?? this.radius,
      category: category ?? this.category,
      selectedStop: selectedStop ?? this.selectedStop,
    );
  }

  List<PlaceCategory> get placeCategories {
    switch (category) {
      case QueryCategory.all:
        return [PlaceCategory.restaurant, PlaceCategory.cafe];
      case QueryCategory.restaurant:
        return [PlaceCategory.restaurant];
      case QueryCategory.cafe:
        return [PlaceCategory.cafe];
    }
  }

  PlaceSearchParams toSearchParams() {
    return PlaceSearchParams(
      centerLat: centerLat,
      centerLon: centerLon,
      radiusMeters: radius,
      categories: placeCategories,
      limit: 50,
      sort: PlaceSort.distance, // Always sort by distance
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NyamQueryState &&
        other.centerLat == centerLat &&
        other.centerLon == centerLon &&
        other.radius == radius &&
        other.category == category &&
        other.selectedStop == selectedStop;
  }

  @override
  int get hashCode {
    return Object.hash(centerLat, centerLon, radius, category, selectedStop);
  }
}

class NyamQueryNotifier extends StateNotifier<NyamQueryState> {
  NyamQueryNotifier()
    : super(
        const NyamQueryState(
          centerLat: 35.1796, // Default to Busan City Hall (fallback)
          centerLon: 129.0756,
        ),
      );

  void updateCenter(double lat, double lon) {
    state = state.copyWith(centerLat: lat, centerLon: lon);
  }

  void updateRadius(int radius) {
    state = state.copyWith(radius: radius);
  }

  void updateCategory(QueryCategory category) {
    state = state.copyWith(category: category);
  }

  void updateFromLocation(double lat, double lon) {
    state = state.copyWith(
      centerLat: lat,
      centerLon: lon,
      selectedStop: null, // 내 위치로 변경 시 정류장 선택 해제
    );
  }

  void updateFromMapCenter(double lat, double lon) {
    state = state.copyWith(centerLat: lat, centerLon: lon);
  }

  void selectStop(SelectedStop stop) {
    print('🚏 정류장 선택: ${stop.name} (${stop.lat}, ${stop.lon})');

    state = state.copyWith(
      selectedStop: stop,
      centerLat: stop.lat,
      centerLon: stop.lon,
    );
  }

  void clearSelectedStop() {
    state = state.copyWith(selectedStop: null);
  }
}
