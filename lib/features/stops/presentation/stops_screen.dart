import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/stop_model.dart';
import '../data/stops_provider.dart';
import '../data/location_provider.dart';
import '../data/bus_arrival_provider.dart';
import '../data/bus_arrival_model.dart';

class StopsScreen extends ConsumerStatefulWidget {
  const StopsScreen({super.key});

  @override
  ConsumerState<StopsScreen> createState() => _StopsScreenState();
}

class _StopsScreenState extends ConsumerState<StopsScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  BitmapDescriptor? _customMarkerIcon;
  LatLngBounds? _currentMapBounds;

  @override
  void initState() {
    super.initState();
    // 커스텀 마커 아이콘 로드
    _loadCustomMarkerIcon();
    // "내 주변" 탭이 기본 선택되므로 위치 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationController.notifier).requestOnce();
    });
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(64, 64)),
        'assets/images/bus_stop.png',
      );
      print('커스텀 마커 아이콘 로드 성공 (64x64)');
      // 마커 아이콘 로드 후 UI 업데이트
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('커스텀 마커 아이콘 로드 실패: $e');
      _customMarkerIcon = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _moveCameraToUserLocation(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
        ),
      ),
    );
  }

  Future<void> _updateMapCenter() async {
    if (_mapController != null) {
      try {
        final bounds = await _mapController!.getVisibleRegion();
        _currentMapBounds = bounds;

        // 지도 중심 위치 계산
        final centerLat =
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
        final centerLng =
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
        final center = LatLng(centerLat, centerLng);

        // Provider에 지도 중심 위치 업데이트
        ref.read(mapCenterProvider.notifier).state = center;

        print('지도 중심 업데이트: $centerLat, $centerLng');
      } catch (e) {
        print('지도 중심 업데이트 실패: $e');
      }
    }
  }

  bool _isStopInBounds(Stop stop) {
    if (_currentMapBounds == null) return true;

    final lat = stop.lat;
    final lng = stop.lng;
    final bounds = _currentMapBounds!;

    return lat >= bounds.southwest.latitude &&
        lat <= bounds.northeast.latitude &&
        lng >= bounds.southwest.longitude &&
        lng <= bounds.northeast.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('정류장'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.accent,
        titleTextStyle: const TextStyle(
          fontFamily: 'Dongle',
          fontSize: 28,
          color: AppColors.accent,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 기능 구현
            },
          ),
        ],
      ),
      body: _buildNearbyTab(),
    );
  }

  Widget _buildNearbyTab() {
    final locationAsync = ref.watch(locationController);
    final nearbyStops = ref.watch(nearbyStopsProvider);

    return locationAsync.when(
      data: (position) {
        if (position == null) {
          return _buildLocationErrorCard();
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(locationController.notifier).refresh(),
          color: AppColors.accent,
          child: Column(
            children: [
              // 지도
              Expanded(flex: 1, child: _buildGoogleMap(position, nearbyStops)),
              // 가까운 정류장 목록
              Expanded(flex: 1, child: _buildNearbyStopsList(nearbyStops)),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, _) => _buildLocationErrorCard(),
    );
  }

  Widget _buildGoogleMap(
    Position position,
    List<({Stop s, int m})> nearbyStops,
  ) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _moveCameraToUserLocation(position);
      },
      onCameraMove: (CameraPosition cameraPosition) {
        // 지도 이동 중에는 업데이트하지 않음
      },
      onCameraIdle: () {
        // 지도 이동이 끝났을 때 중심 위치 업데이트
        _updateMapCenter();
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      markers: _buildMarkers(nearbyStops),
    );
  }

  Set<Marker> _buildMarkers(List<({Stop s, int m})> nearbyStops) {
    print(
      '마커 빌드 중: ${nearbyStops.length}개 정류장, 커스텀 아이콘: ${_customMarkerIcon != null}',
    );

    return nearbyStops.map((item) {
      return Marker(
        markerId: MarkerId(item.s.id),
        position: LatLng(item.s.lat, item.s.lng),
        infoWindow: InfoWindow(title: item.s.name),
        icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(100),
        onTap: () {
          context.go('/stops/${item.s.id}', extra: {'name': item.s.name});
        },
      );
    }).toSet();
  }

  Widget _buildNearbyStopsList(List<({Stop s, int m})> nearestStops) {
    if (nearestStops.isEmpty) {
      return const Center(
        child: Text(
          '주변에 정류장이 없습니다',
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 18,
            color: AppColors.accent,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nearestStops.length,
      itemBuilder: (context, index) {
        final item = nearestStops[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              item.s.name,
              style: const TextStyle(fontFamily: 'Dongle', fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.m} m',
                  style: const TextStyle(fontFamily: 'Dongle', fontSize: 14),
                ),
                const SizedBox(height: 4),
                _buildArrivalInfo(item.s.arsno),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.accent),
            onTap: () {
              context.go('/stops/${item.s.id}', extra: {'name': item.s.name});
            },
          ),
        );
      },
    );
  }

  Widget _buildArrivalInfo(String arsno) {
    final arrivalsAsync = ref.watch(busArrivalProvider(arsno));

    return arrivalsAsync.when(
      data: (arrivals) {
        if (arrivals.isEmpty) {
          return const Text(
            '도착 정보 없음',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 12,
              color: Colors.grey,
            ),
          );
        }

        // 최대 2개의 도착 정보만 표시
        final displayArrivals = arrivals.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: displayArrivals.map((arrival) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    arrival.routeName,
                    style: const TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  arrival.arrivalMessage,
                  style: const TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                ),
                if (arrival.isLowFloor) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.accessible,
                    size: 12,
                    color: AppColors.accent,
                  ),
                ],
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Text(
        '도착 정보 로딩 중...',
        style: TextStyle(
          fontFamily: 'Dongle',
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      error: (error, stack) => const Text(
        '도착 정보 오류',
        style: TextStyle(fontFamily: 'Dongle', fontSize: 12, color: Colors.red),
      ),
    );
  }

  Widget _buildLocationErrorCard() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text(
                '위치 권한이 필요합니다',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          ref.read(locationController.notifier).requestOnce(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        '권한 요청',
                        style: TextStyle(fontFamily: 'Dongle', fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => openAppSettings(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent),
                        foregroundColor: AppColors.accent,
                      ),
                      child: const Text(
                        '설정 열기',
                        style: TextStyle(fontFamily: 'Dongle', fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // 검색 입력
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '정류장명 또는 ID 검색',
              hintStyle: TextStyle(fontFamily: 'Dongle', fontSize: 16),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.accent),
            ),
            style: const TextStyle(fontFamily: 'Dongle', fontSize: 16),
            onChanged: (value) {
              // 300ms 디바운스
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_searchController.text == value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                }
              });
            },
          ),
        ),
        // 검색 결과
        Expanded(child: _buildSearchResults()),
      ],
    );
  }

  Widget _buildSearchResults() {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.isEmpty) {
      return const Center(
        child: Text(
          '검색어를 입력해주세요',
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 18,
            color: AppColors.accent,
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          '"$query"에 대한 검색 결과가 없습니다',
          style: const TextStyle(
            fontFamily: 'Dongle',
            fontSize: 18,
            color: AppColors.accent,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final stop = searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              stop.name,
              style: const TextStyle(fontFamily: 'Dongle', fontSize: 18),
            ),
            subtitle: Text(
              'ID: ${stop.id} | ARS: ${stop.arsno}',
              style: const TextStyle(fontFamily: 'Dongle', fontSize: 14),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.accent),
            onTap: () {
              context.go('/stops/${stop.id}', extra: {'name': stop.name});
            },
          ),
        );
      },
    );
  }
}
