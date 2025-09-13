import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _StopsScreenState extends ConsumerState<StopsScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLngBounds? _currentMapBounds;
  int _selectedRadius = 300; // 기본값 300m
  String? _selectedStopId; // 선택된 정류장 ID
  final ScrollController _listScrollController =
      ScrollController(); // 리스트 스크롤 컨트롤러
  Timer? _uiUpdateTimer; // UI 업데이트용 타이머
  AnimationController? _refreshAnimationController; // 새로고침 애니메이션 컨트롤러

  // 새로고침 버튼 쿨다운 관련
  bool _isRefreshCooldown = false; // 쿨다운 상태
  int _refreshCooldownSeconds = 0; // 남은 쿨다운 시간 (초)
  Timer? _refreshCooldownTimer; // 쿨다운 타이머
  DateTime? _cooldownStartTime; // 쿨다운 시작 시간

  // 자동 새로고침 관련
  Timer? _autoRefreshTimer; // 자동 새로고침 타이머
  bool _isAutoRefreshing = false; // 자동 새로고침 중인지
  bool _isTabActive = true; // 탭이 활성화되어 있는지
  int _autoRefreshCountdown = 60; // 다음 새로고침까지 남은 시간 (초)
  Timer? _countdownTimer; // 카운트다운 타이머

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화
    _refreshAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    // "내 주변" 탭이 기본 선택되므로 위치 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocationPermission();
      // 상세페이지에서 돌아온 경우 지도 다시 활성화
      _checkForMapReactivation();
    });

    // 10초마다 UI 업데이트 (카운트다운 표시용) - 성능 최적화
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          // setState를 호출하여 UI 리빌드 (카운트다운 업데이트)
        });
      }
    });

    // 쿨다운 상태 복원
    _restoreCooldownState();

    // 자동 새로고침 타이머 시작
    _startAutoRefreshTimer();

    // 앱 생명주기 observer 등록
    WidgetsBinding.instance.addObserver(this);
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

  // 새로고침 쿨다운 시작 (2분 = 120초)
  void _startRefreshCooldown() {
    _isRefreshCooldown = true;
    _refreshCooldownSeconds = 120; // 2분
    _cooldownStartTime = DateTime.now();

    // 쿨다운 상태 저장
    _saveCooldownState();

    _refreshCooldownTimer?.cancel();
    _refreshCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_refreshCooldownSeconds > 0) {
        setState(() {
          _refreshCooldownSeconds--;
        });
        // 쿨다운 상태 업데이트 저장
        _saveCooldownState();
      } else {
        setState(() {
          _isRefreshCooldown = false;
          _refreshCooldownSeconds = 0;
          _cooldownStartTime = null;
        });
        // 쿨다운 완료 시 저장된 상태 삭제
        _clearCooldownState();
        timer.cancel();
      }
    });
  }

  // 남은 쿨다운 시간을 분:초 형식으로 포맷
  String _formatCooldownTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}분 ${remainingSeconds}초 후';
  }

  // 자동 새로고침 카운트다운 시간을 포맷
  String _formatAutoRefreshCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 쿨다운 상태를 SharedPreferences에 저장
  void _saveCooldownState() {
    if (_cooldownStartTime != null) {
      final prefs = SharedPreferences.getInstance();
      prefs.then((prefs) {
        prefs.setInt(
          'refresh_cooldown_start',
          _cooldownStartTime!.millisecondsSinceEpoch,
        );
        prefs.setInt('refresh_cooldown_duration', 120); // 2분
      });
    }
  }

  // 저장된 쿨다운 상태 복원
  void _restoreCooldownState() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      final startTimeMs = prefs.getInt('refresh_cooldown_start');
      final duration = prefs.getInt('refresh_cooldown_duration') ?? 120;

      if (startTimeMs != null) {
        final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
        final now = DateTime.now();
        final elapsed = now.difference(startTime).inSeconds;
        final remaining = duration - elapsed;

        if (remaining > 0) {
          // 아직 쿨다운이 남아있음
          setState(() {
            _isRefreshCooldown = true;
            _refreshCooldownSeconds = remaining;
            _cooldownStartTime = startTime;
          });

          // 타이머 재시작
          _refreshCooldownTimer?.cancel();
          _refreshCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
            timer,
          ) {
            if (_refreshCooldownSeconds > 0) {
              setState(() {
                _refreshCooldownSeconds--;
              });
              _saveCooldownState();
            } else {
              setState(() {
                _isRefreshCooldown = false;
                _refreshCooldownSeconds = 0;
                _cooldownStartTime = null;
              });
              _clearCooldownState();
              timer.cancel();
            }
          });
        } else {
          // 쿨다운이 이미 완료됨
          _clearCooldownState();
        }
      }
    });
  }

  // 저장된 쿨다운 상태 삭제
  void _clearCooldownState() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      prefs.remove('refresh_cooldown_start');
      prefs.remove('refresh_cooldown_duration');
    });
  }

  // 자동 새로고침 타이머 시작 (1분 = 60초)
  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();

    // 카운트다운 타이머 시작 (1초마다)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTabActive && !_isAutoRefreshing) {
        setState(() {
          _autoRefreshCountdown--;
        });

        if (_autoRefreshCountdown <= 0) {
          _performAutoRefresh();
        }
      }
    });

    // 자동 새로고침 타이머 시작 (2분마다) - 성능 최적화
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 120), (timer) {
      if (_isTabActive && !_isAutoRefreshing) {
        _performAutoRefresh();
      }
    });
  }

  // 자동 새로고침 실행
  Future<void> _performAutoRefresh() async {
    if (_isAutoRefreshing) return;

    setState(() {
      _isAutoRefreshing = true;
    });

    // 새로고침 애니메이션 시작
    _refreshAnimationController?.repeat();

    try {
      // 현재 반경 내 정류장들의 API 데이터 새로고침
      final nearbyStopsList = ref.read(nearbyStopsListProvider);
      for (final stop in nearbyStopsList) {
        await ref.read(busArrivalProvider(stop.s.arsno).notifier).refresh();
      }
      print('🔄 자동 새로고침 완료: ${nearbyStopsList.length}개 정류장');
    } catch (e) {
      print('❌ 자동 새로고침 실패: $e');
    } finally {
      // 새로고침 애니메이션 정지
      _refreshAnimationController?.stop();
      _refreshAnimationController?.reset();

      setState(() {
        _isAutoRefreshing = false;
        _autoRefreshCountdown = 60; // 카운트다운 리셋
      });
    }
  }

  // 탭 활성화 상태 변경
  void _setTabActive(bool isActive) {
    if (_isTabActive != isActive) {
      setState(() {
        _isTabActive = isActive;
      });

      if (isActive) {
        // 탭이 활성화되면 자동 새로고침 타이머 재시작
        setState(() {
          _autoRefreshCountdown = 60; // 카운트다운 리셋
        });
        _startAutoRefreshTimer();
      } else {
        // 탭이 비활성화되면 타이머 정지
        _autoRefreshTimer?.cancel();
        _countdownTimer?.cancel();
      }
    }
  }

  // 앱 생명주기 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아옴 (상세페이지에서 뒤로가기 포함)
        _setTabActive(true);
        // 자동 새로고침 타이머 재시작
        _startAutoRefreshTimer();
        print('🗺️ 지도 다시 활성화: 앱 포그라운드 복귀');
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // 앱이 백그라운드로 가거나 비활성화됨
        _setTabActive(false);
        // 지도 컨트롤러 정리
        _mapController?.dispose();
        _mapController = null;
        print('🗺️ 지도 정지: 앱 백그라운드 이동');
        break;
      case AppLifecycleState.hidden:
        // 앱이 숨겨짐
        _setTabActive(false);
        // 지도 컨트롤러 정리
        _mapController?.dispose();
        _mapController = null;
        print('🗺️ 지도 정지: 앱 숨김');
        break;
    }
  }

  // 상세페이지로 이동할 때 지도 정지 및 API 타이머 중지
  void _pauseMapForNavigation() {
    _setTabActive(false);
    _mapController?.dispose();
    _mapController = null;

    // API 타이머들 중지
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();
    print('⏸️ 정류장 상세 진입: API 타이머 중지');
  }

  // 상세페이지에서 돌아온 경우 지도 다시 활성화
  void _checkForMapReactivation() {
    // GoRouter 상태에서 reactivate_map 플래그 확인
    final routerState = GoRouterState.of(context);
    final extra = routerState.extra as Map<String, dynamic>?;

    if (extra?['reactivate_map'] == true) {
      // 지도 다시 활성화
      _setTabActive(true);
      // 자동 새로고침 타이머 재시작
      _startAutoRefreshTimer();
    }
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _refreshCooldownTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();
    _searchController.dispose();
    _listScrollController.dispose();
    _refreshAnimationController?.dispose();
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
    // 상세페이지에서 돌아온 경우 지도 다시 활성화 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMapReactivation();
      // 상세페이지에서 돌아온 경우 지도 강제 활성화
      if (!_isTabActive) {
        _setTabActive(true);
        _startAutoRefreshTimer();
        print('🗺️ 지도 강제 활성화: 정류장 목록 화면 진입');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildNearbyTab()),
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
                        items: [100, 200, 300, 500].map((int radius) {
                          return DropdownMenuItem<int>(
                            value: radius,
                            child: Text(
                              radius >= 1000
                                  ? '${radius ~/ 1000}km'
                                  : '${radius}m',
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 27,
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
                            ref.read(selectedRadiusProvider.notifier).state =
                                newValue;
                            print('📍 Provider 업데이트 완료: ${newValue}m');

                            // 반경 변경 시 모든 버스 도착 정보 API 재호출
                            final nearbyStopsList = ref.read(
                              nearbyStopsListProvider,
                            );
                            for (final stop in nearbyStopsList) {
                              ref
                                  .read(
                                    busArrivalProvider(stop.s.arsno).notifier,
                                  )
                                  .refresh();
                            }
                            print(
                              '🔄 반경 변경으로 인한 API 재호출: ${nearbyStopsList.length}개 정류장',
                            );
                          }
                        },
                      ),
                    ),
                    // 오른쪽: 새로고침 버튼
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 자동 새로고침 카운트다운 표시
                          if (!_isAutoRefreshing) ...[
                            Text(
                              _formatAutoRefreshCountdown(
                                _autoRefreshCountdown,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 19,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          // 새로고침 버튼 (자동 새로고침 중일 때는 비활성화)
                          IconButton(
                            onPressed: null, // 수동 새로고침 비활성화
                            icon: _refreshAnimationController != null
                                ? AnimatedBuilder(
                                    animation: _refreshAnimationController!,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle:
                                            _refreshAnimationController!.value *
                                            2.0 *
                                            3.14159,
                                        child: Icon(
                                          Icons.refresh,
                                          color: AppColors.accent,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.refresh,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                          ),
                        ],
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
    // 탭이 비활성화되면 지도 대신 플레이스홀더 표시
    if (!_isTabActive) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Text(
            '지도 일시정지',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 21,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // 선택된 반경에 맞는 정류장만 필터링
    final selectedRadiusStops = nearbyStops
        .where((item) => item.m <= _selectedRadius)
        .toList();

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
      myLocationEnabled: false, // 위치 서비스 완전 비활성화
      myLocationButtonEnabled: false, // 위치 버튼 완전 비활성화
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      // 성능 최적화 설정
      mapType: MapType.normal,
      buildingsEnabled: false, // 3D 건물 비활성화
      trafficEnabled: false, // 교통 정보 비활성화
      markers: _buildMarkers(selectedRadiusStops),
      circles: _buildRadiusCircle(position),
    );
  }

  Set<Marker> _buildMarkers(List<({Stop s, int m})> nearbyStops) {
    // 성능 최적화: 마커 수를 10개로 제한
    final limitedStops = nearbyStops.take(10).toList();

    return limitedStops.map((item) {
      return Marker(
        markerId: MarkerId(item.s.id),
        position: LatLng(item.s.lat, item.s.lng),
        infoWindow: const InfoWindow(), // 빈 정보창
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ), // 작은 빨간 마커
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
            fontSize: 21,
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
              color: isSelected
                  ? const Color(0xFFFF8A65)
                  : AppColors.accent, // 선택시 진한 파스텔 코랄, 미선택시 테마컬러
              width: isSelected ? 3 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              // 상세페이지로 이동하기 전에 지도 정지
              _pauseMapForNavigation();
              context.go(
                '/stops/${item.s.id}',
                extra: {
                  'name': item.s.name,
                  'arsno': item.s.arsno,
                  'lat': item.s.lat,
                  'lng': item.s.lng,
                  'bstopid': item.s.id,
                  'distance': item.m, // 거리 정보 추가
                },
              );
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
                          '${item.s.name} (${item.s.id})',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 27,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.m} m',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 21,
                          ),
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
              fontSize: 21,
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
                        color: _getRouteColor(arrival.lineno, arrival.bustype),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        arrival.lineno,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatArrivalMessage(arrival.min1),
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 21,
                        color: AppColors.text,
                      ),
                    ),
                    if (arrival.lowplate1 == '1') ...[
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/low_floor_bus.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
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
                            fontSize: 21,
          color: Colors.grey,
        ),
      ),
      error: (error, stack) => const Text(
        '도착 정보 오류',
        style: TextStyle(fontFamily: 'Dongle', fontSize: 21, color: Colors.red),
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
                  const Icon(
                    Icons.location_off,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '위치 권한이 필요합니다',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 23,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPermissionDescription(permissionStatus),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 19,
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
                              await ref
                                  .read(locationController.notifier)
                                  .requestLocationPermission();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              '위치 권한 허용',
                              style: TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 19,
                              ),
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
                            style: TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 19,
                            ),
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
                            await ref
                                .read(locationController.notifier)
                                .requestLocationPermission();
                          },
                          child: const Text(
                            '새로고침',
                            style: TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 17,
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
              hintStyle: TextStyle(fontFamily: 'Dongle', fontSize: 19),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.accent),
            ),
            style: const TextStyle(fontFamily: 'Dongle', fontSize: 19),
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
            fontSize: 21,
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
            fontSize: 21,
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
              style: const TextStyle(fontFamily: 'Dongle', fontSize: 21),
            ),
            subtitle: Text(
              'ID: ${stop.id} | ARS: ${stop.arsno}',
              style: const TextStyle(fontFamily: 'Dongle', fontSize: 17),
            ),
            onTap: () {
              // 상세페이지로 이동하기 전에 지도 정지
              _pauseMapForNavigation();
              context.go(
                '/stops/${stop.id}',
                extra: {
                  'name': stop.name,
                  'arsno': stop.arsno,
                  'lat': stop.lat,
                  'lng': stop.lng,
                  'bstopid': stop.id,
                  'distance': 0, // 검색 결과는 거리 정보 없음
                },
              );
            },
          ),
        );
      },
    );
  }

  // 버스 타입에 따른 색깔 매핑
  Color _getRouteColor(String routeName, String busType) {
    // 빈 문자열이나 null 체크
    if (routeName.isEmpty) return const Color(0xFF7BB074); // 진한 민트 폴백

    // 심야 버스 체크 (노선명에 "심야" 포함)
    if (routeName.contains('심야')) {
      return const Color(0xFFFF8A65); // 진한 코랄/피치
    }

    // 버스 타입에 따른 색상 적용 (조금 더 진한 파스텔 톤)
    switch (busType) {
      case '일반버스':
        return const Color(0xFF64B5F6); // 진한 파스텔 블루
      case '급행버스':
      case '좌석버스':
      case '좌석·급행버스':
        return const Color(0xFFBA68C8); // 진한 파스텔 퍼플
      case '마을버스':
        return const Color(0xFF81C784); // 진한 파스텔 그린
      default:
        return const Color(0xFF7BB074); // 진한 민트 (그 외 모든 타입)
    }
  }

  // 도착시간을 메시지로 포맷
  String _formatArrivalMessage(String min1) {
    if (min1.isEmpty) return '도착정보 없음';

    // "곧 도착"인 경우
    if (min1 == '곧 도착') return '곧 도착';

    // 숫자만 추출
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(min1);
    final timeStr = match?.group(0) ?? min1;
    final time = int.tryParse(timeStr);

    if (time == null) return min1; // 원본 반환

    if (time == 0) return '곧 도착';
    return '${time}분 후';
  }
}
