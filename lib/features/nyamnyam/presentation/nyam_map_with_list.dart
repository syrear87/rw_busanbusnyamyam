import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/nyam_providers.dart';
import '../data/nyam_query_state.dart';
import '../data/location_provider.dart';
import '../../stops/data/location_provider.dart' as stops_location;
import '../data/place_model.dart';

// 지도와 리스트를 결합한 위젯
class MapWithListView extends ConsumerStatefulWidget {
  final NyamQueryState query;
  final LocationState location;
  final AsyncValue<Position?> stopsLocation;
  final AsyncValue<List<Place>> places;
  final Function(GoogleMapController) onMapControllerCreated;

  const MapWithListView({
    super.key,
    required this.query,
    required this.location,
    required this.stopsLocation,
    required this.places,
    required this.onMapControllerCreated,
  });

  @override
  ConsumerState<MapWithListView> createState() => _MapWithListViewState();
}

class _MapWithListViewState extends ConsumerState<MapWithListView> {
  int? selectedPlaceIndex;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    // 실시간으로 상태를 읽어옴
    final currentQuery = ref.watch(nyamQueryProvider);
    final currentLocation = ref.watch(locationProvider);
    final currentStopsLocation = ref.watch(stops_location.locationController);
    final currentPlaces = ref.watch(placesProvider);

    // 정류장 탭의 위치 정보 사용
    final position = currentStopsLocation.maybeWhen(
      data: (pos) => pos,
      orElse: () => null,
    );

    // 디버그 로그 추가
    print('🗺️ Map build - Stops Location: ${position?.latitude}, ${position?.longitude}');
    print('🗺️ Map build - Query center: ${currentQuery.centerLat}, ${currentQuery.centerLon}');
    print('🗺️ Map build - Has valid stops location: ${position != null}');

    // 쿼리 변경 감지하여 맵 이동
    ref.listen(nyamQueryProvider, (previous, next) {
      if (previous != null &&
          _mapController != null &&
          (previous.centerLat != next.centerLat || previous.centerLon != next.centerLon)) {
        _animateToLocation(next.centerLat, next.centerLon);
      }
    });

    // 정류장 탭 위치 변경 감지하여 맵 이동 (첫 진입시 위치 로드될 때)
    ref.listen(stops_location.locationController, (previous, next) {
      if (_mapController != null) {
        final currentPos = next.maybeWhen(data: (pos) => pos, orElse: () => null);
        final prevPos = previous?.maybeWhen(data: (pos) => pos, orElse: () => null);
        
        if (currentPos != null && prevPos == null) {
          print('🗺️ 첫 위치 로드 완료, 지도 이동: ${currentPos.latitude}, ${currentPos.longitude}');
          _animateToLocation(currentPos.latitude, currentPos.longitude);
        }
      }
    });

    // 정류장 탭 위치 정보가 로드될 때까지 로딩 표시
    if (currentStopsLocation.isLoading) {
      return _buildLocationLoadingScreen();
    }

    return Stack(
      children: [
        // 지도 - 리스트 영역을 제외한 상단 영역
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 300, // 리스트 높이만큼 하단 여백
          child: _buildMap(currentQuery, currentLocation, currentPlaces),
        ),

        // 하단 Attribution (필수) - 지도 영역 내 하단
        Positioned(
          bottom: 320, // 리스트 높이 + 여백
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '© OpenStreetMap contributors',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        // 위치 로딩 인디케이터
        if (!currentLocation.hasValidLocation && 
            currentLocation.hasPermission && 
            currentLocation.serviceEnabled &&
            currentLocation.error == null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildLocationLoadingIndicator(),
          ),

        // 에러 스낵바
        if (currentLocation.error != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildErrorSnackBar(currentLocation.error!),
          ),

        // 하단 고정 리스트
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 리스트 내용 (고정 높이, 헤더 없이 바로 시작)
                Expanded(
                  child: currentPlaces.when(
                    data: (places) => places.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 16), // 상단 여백만 추가
                            itemCount: places.length,
                            itemBuilder: (context, index) {
                              final place = places[index];
                              final isSelected = selectedPlaceIndex == index;

                              return PlaceListItem(
                                place: place,
                                isSelected: isSelected,
                                onTap: () => _onPlaceSelected(index, place),
                              );
                            },
                          ),
                    loading: () => _buildLoadingState(),
                    error: (error, stack) =>
                        _buildErrorState(error.toString()),
                  ),
                ),

                // 하단 SafeArea (메인 탭바와의 여백)
                SafeArea(
                  top: false,
                  child: Container(height: 8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(
    NyamQueryState query,
    LocationState location,
    AsyncValue<List<Place>> places,
  ) {
    // 정류장 탭의 위치 정보 가져오기
    final currentStopsLocation = ref.watch(stops_location.locationController);
    final position = currentStopsLocation.maybeWhen(
      data: (pos) => pos,
      orElse: () => null,
    );

    final center = LatLng(query.centerLat, query.centerLon);
    final Set<Marker> markers = {};
    final Set<Circle> circles = {};

    // Add center marker (정류장 또는 기준 위치)
    markers.add(
      Marker(
        markerId: const MarkerId('center'),
        position: center,
        icon: query.selectedStop != null
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: query.selectedStop?.name ?? '기준 위치',
          snippet: query.selectedStop != null ? '선택된 정류장' : null,
        ),
      ),
    );

    // Add place markers
    places.whenData((placeList) {
      for (int index = 0; index < placeList.length; index++) {
        final place = placeList[index];

        markers.add(
          Marker(
            markerId: MarkerId('place_$index'),
            position: LatLng(place.lat, place.lon),
            icon: place.category == PlaceCategory.restaurant
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  )
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: '${place.distanceMeters}m · ${place.category.value}',
            ),
            onTap: () => _onMarkerTapped(index, place),
          ),
        );
      }
    });

    // Add radius circle
    circles.add(
      Circle(
        circleId: const CircleId('radius'),
        center: center,
        radius: query.radius.toDouble(),
        fillColor: const Color(0xFF7BB074).withOpacity(0.1),
        strokeColor: const Color(0xFF7BB074),
        strokeWidth: 2,
      ),
    );

    // 초기 카메라 위치 결정: 정류장 탭 위치 > 쿼리 중심 > 부산시청 기본값
    LatLng initialPosition;
    if (position != null) {
      initialPosition = LatLng(position.latitude, position.longitude);
    } else {
      initialPosition = LatLng(query.centerLat, query.centerLon);
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        widget.onMapControllerCreated(controller);

        // 정류장 탭 위치로 카메라 이동
        if (position != null) {
          _animateToLocation(position.latitude, position.longitude);
        }
      },
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 15.0,
      ),
      markers: markers,
      circles: circles,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      onCameraMove: (CameraPosition position) {
        ref
            .read(nyamQueryProvider.notifier)
            .updateFromMapCenter(
              position.target.latitude,
              position.target.longitude,
            );
      },
    );
  }

  void _animateToLocation(double lat, double lon) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lon), zoom: 15.0),
      ),
    );
  }

  void _onMarkerTapped(int index, Place place) {
    setState(() {
      selectedPlaceIndex = index;
    });

    // 지도 카메라를 선택된 장소로 이동 (선택 마커 scale 애니메이션)
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(place.lat, place.lon), zoom: 16.0),
      ),
    );
  }

  void _onPlaceSelected(int index, Place place) {
    setState(() {
      selectedPlaceIndex = index;
    });

    // 지도 카메라를 선택된 장소로 이동
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(place.lat, place.lon), zoom: 16.0),
      ),
    );
  }


  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '반경을 늘려보세요',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            '오류가 발생했습니다',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 20,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontFamily: 'Dongle',
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(placesProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7BB074),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              '재시도',
              style: TextStyle(fontFamily: 'Dongle', fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationLoadingScreen() {
    return Container(
      color: const Color(0xFFF0DFCC),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BB074)),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '현재 위치를 찾는 중...',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 24,
                color: Color(0xFF7BB074),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '잠시만 기다려주세요',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BB074)),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '현재 위치를 찾는 중...',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 16,
              color: Color(0xFF7BB074),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSnackBar(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(locationProvider.notifier).clearError(),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// 장소 리스트 아이템
class PlaceListItem extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback onTap;

  const PlaceListItem({
    super.key,
    required this.place,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final walkTime = (place.distanceMeters / 70).ceil();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF7BB074).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: const Color(0xFF7BB074), width: 2)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF7BB074).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 카테고리 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: place.category == PlaceCategory.restaurant
                        ? Colors.orange
                        : Colors.brown,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    place.category == PlaceCategory.restaurant
                        ? Icons.restaurant
                        : Icons.local_cafe,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // 장소 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF7BB074)
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${place.distanceMeters}m · 도보 ${walkTime}분',
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (place.address != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          place.address!,
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // 소스 배지와 화살표
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7BB074).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.source.value,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 12,
                          color: Color(0xFF7BB074),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right,
                      color: isSelected ? const Color(0xFF7BB074) : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
