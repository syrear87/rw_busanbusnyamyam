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
  LatLngBounds? _currentMapBounds;
  int _selectedRadius = 100; // 기본값 100m
  String? _selectedStopId; // 선택된 정류장 ID
  final ScrollController _listScrollController = ScrollController(); // 리스트 스크롤 컨트롤러

  @override
  void initState() {
    super.initState();
    // "내 주변" 탭이 기본 선택되므로 위치 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocationPermission();
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    print('🚀 StopsScreen: 위치 권한 확인 및 요청 시작');
    try {
      // 새로운 권한 요청 로직 사용
      await ref.read(locationController.notifier).requestLocationPermission();
    } catch (e) {
      print('🚀 StopsScreen: 위치 권한 요청 중 오류: $e');
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    _listScrollController.dispose();
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

  void _scrollToSelectedStop(String stopId, List<({Stop s, int m})> stops) {
    final index = stops.indexWhere((item) => item.s.id == stopId);
    if (index != -1 && _listScrollController.hasClients) {
      print('🎯 스크롤 대상: 인덱스 $index, 정류장: ${stops[index].s.name}');
      
      // 선택된 아이템이 리스트 최상단에 정확히 위치하도록 스크롤
      const double cardMargin = 8.0; // Card margin bottom
      const double listTileHeight = 72.0; // ListTile 기본 높이
      const double totalItemHeight = listTileHeight + cardMargin;
      
      // 선택된 아이템이 리스트 최상단에 오도록 스크롤
      final double targetOffset = index * totalItemHeight;
      
      print('🎯 스크롤 오프셋: $targetOffset (인덱스: $index × 높이: $totalItemHeight)');
      
      // 즉시 이동 후 부드러운 애니메이션
      _listScrollController.jumpTo(targetOffset);
      
      // 부드러운 스크롤 효과를 위한 미세 조정
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_listScrollController.hasClients) {
          _listScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      });
    }
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
      body: SafeArea(
        child: _buildNearbyTab(),
      ),
    );
  }

  Widget _buildNearbyTab() {
    final locationAsync = ref.watch(locationController);
    final nearbyStops = ref.watch(nearbyStopsProvider); // 지도용 (500m)
    final nearbyStopsList = ref.watch(nearbyStopsListProvider); // 리스트용 (100m)

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
              // 지도 (500m 범위)
              Expanded(flex: 1, child: _buildGoogleMap(position, nearbyStops)),
              // 새로고침 버튼 영역 (드롭다운 + 새로고침)
              Container(
                height: 50,
                color: AppColors.background,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 왼쪽: 반경 선택 드롭다운
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: DropdownButton<int>(
                        value: _selectedRadius,
                        underline: Container(),
                        items: [100, 200, 300, 500, 1000].map((int radius) {
                          return DropdownMenuItem<int>(
                            value: radius,
                            child: Text(
                              radius >= 1000 ? '${radius ~/ 1000}km' : '${radius}m',
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 24,
                                color: AppColors.accent,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            print('📍 드롭다운 선택: ${newValue}m');
                            setState(() {
                              _selectedRadius = newValue;
                            });
                            // Provider 업데이트
                            ref.read(selectedRadiusProvider.notifier).state = newValue;
                            print('📍 Provider 업데이트 완료: ${newValue}m');
                            
                            // 반경 변경 시 모든 버스 도착 정보 API 재호출
                            final nearbyStopsList = ref.read(nearbyStopsListProvider);
                            for (final stop in nearbyStopsList) {
                              ref.invalidate(busArrivalProvider(stop.s.arsno));
                            }
                            print('🔄 반경 변경으로 인한 API 재호출: ${nearbyStopsList.length}개 정류장');
                          }
                        },
                      ),
                    ),
                    // 오른쪽: 새로고침 버튼
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        onPressed: () {
                          // 현재 반경 내 정류장들의 API 데이터 새로고침
                          final nearbyStopsList = ref.read(nearbyStopsListProvider);
                          for (final stop in nearbyStopsList) {
                            ref.invalidate(busArrivalProvider(stop.s.arsno));
                          }
                          print('🔄 새로고침 버튼으로 API 재호출: ${nearbyStopsList.length}개 정류장');
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 가까운 정류장 목록 (100m 범위)
              Expanded(flex: 1, child: _buildNearbyStopsList(nearbyStopsList)),
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
    // 선택된 반경에 맞는 정류장만 필터링
    final selectedRadiusStops = nearbyStops.where((item) => item.m <= _selectedRadius).toList();
    
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
      markers: _buildMarkers(selectedRadiusStops),
      circles: _buildRadiusCircle(position),
    );
  }

  Set<Marker> _buildMarkers(List<({Stop s, int m})> nearbyStops) {
    print('🗺️ 지도 마커 생성: ${nearbyStops.length}개 정류장 (반경: ${_selectedRadius}m)');
    return nearbyStops.map((item) {
      return Marker(
        markerId: MarkerId(item.s.id),
        position: LatLng(item.s.lat, item.s.lng),
        infoWindow: const InfoWindow(), // 빈 정보창
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // 작은 빨간 마커
        onTap: () {
          print('🎯 마커 선택: ${item.s.name} (거리: ${item.m}m)');
          // 반경 내 정류장만 선택 처리 (이미 필터링된 정류장만 포함됨)
          setState(() {
            _selectedStopId = item.s.id;
          });
          // 해당 정류장 셀로 스크롤 (리스트용 데이터 사용)
          final listStops = ref.read(nearbyStopsListProvider);
          _scrollToSelectedStop(item.s.id, listStops);
        },
      );
    }).toSet();
  }

  Set<Circle> _buildRadiusCircle(Position position) {
    final selectedRadius = ref.watch(selectedRadiusProvider);
    
    return {
      Circle(
        circleId: const CircleId('radius_circle'),
        center: LatLng(position.latitude, position.longitude),
        radius: selectedRadius.toDouble(),
        fillColor: AppColors.accent.withOpacity(0.1),
        strokeColor: AppColors.accent,
        strokeWidth: 2,
      ),
    };
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
      controller: _listScrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: nearestStops.length,
      itemBuilder: (context, index) {
        final item = nearestStops[index];
        final isSelected = _selectedStopId == item.s.id;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFFFFB6C1) : AppColors.accent, // 선택시 핑크, 미선택시 테마컬러
              width: isSelected ? 3 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              context.go('/stops/${item.s.id}', extra: {'name': item.s.name});
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 왼쪽: 정류장 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.s.name,
                          style: const TextStyle(fontFamily: 'Dongle', fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.m} m',
                          style: const TextStyle(fontFamily: 'Dongle', fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  // 오른쪽: 버스 정보 (세로 배치)
                  _buildArrivalInfo(item.s.arsno),
                ],
              ),
            ),
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
              fontSize: 18,
              color: Colors.grey,
            ),
          );
        }

        // 모든 도착 정보 표시
        final displayArrivals = arrivals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: displayArrivals.asMap().entries.map((entry) {
            final index = entry.key;
            final arrival = entry.value;
            
            return Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                  decoration: BoxDecoration(
                    color: arrival.routeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                      child: Text(
                        arrival.routeName,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      arrival.arrivalMessage,
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 18,
                        color: AppColors.text,
                      ),
                    ),
                    if (arrival.isLowFloor) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.accessible,
                        size: 18,
                        color: AppColors.accent,
                      ),
                    ],
                  ],
                ),
                if (index < displayArrivals.length - 1)
                  const SizedBox(height: 4), // 버스 정보 사이 간격
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Text(
        '도착 정보 로딩 중...',
        style: TextStyle(
          fontFamily: 'Dongle',
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
      error: (error, stack) => const Text(
        '도착 정보 오류',
        style: TextStyle(fontFamily: 'Dongle', fontSize: 18, color: Colors.red),
      ),
    );
  }

  Widget _buildLocationErrorCard() {
    return FutureBuilder<PermissionStatus>(
      future: ref.read(locationController.notifier).getPermissionStatus(),
      builder: (context, snapshot) {
        final permissionStatus = snapshot.data;
        
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
                  const SizedBox(height: 8),
                  Text(
                    _getPermissionDescription(permissionStatus),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      // 권한 요청 버튼 (denied 상태일 때만)
                      if (permissionStatus == PermissionStatus.denied) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              print('🚀 사용자가 권한 요청 버튼 클릭');
                              await ref.read(locationController.notifier).requestLocationPermission();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              '위치 권한 허용',
                              style: TextStyle(fontFamily: 'Dongle', fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // 설정으로 이동 버튼 (항상 표시)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            print('🚀 사용자가 설정 열기 버튼 클릭');
                            await openAppSettings();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            foregroundColor: AppColors.accent,
                          ),
                          child: const Text(
                            '설정에서 권한 허용',
                            style: TextStyle(fontFamily: 'Dongle', fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 새로고침 버튼
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            print('🚀 사용자가 새로고침 버튼 클릭');
                            await ref.read(locationController.notifier).requestLocationPermission();
                          },
                          child: const Text(
                            '새로고침',
                            style: TextStyle(
                              fontFamily: 'Dongle', 
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
      },
    );
  }

  String _getPermissionDescription(PermissionStatus? status) {
    switch (status) {
      case PermissionStatus.denied:
        return '위치 권한을 허용해주세요\n가까운 정류장을 찾을 수 있습니다';
      case PermissionStatus.permanentlyDenied:
        return '설정 > 개인정보 보호 및 보안 > 위치 서비스에서\n"부산버스 냠냠" 앱의 위치 권한을 허용해주세요';
      case PermissionStatus.granted:
        return '위치 권한이 허용되었습니다';
      default:
        return '가까운 정류장을 찾기 위해\n위치 정보가 필요합니다';
    }
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
            onTap: () {
              context.go('/stops/${stop.id}', extra: {'name': stop.name});
            },
          ),
        );
      },
    );
  }
}
