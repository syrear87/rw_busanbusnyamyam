import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/busan_bis_api.dart';
import '../../../../data/route_traffic.dart';
import '../../stops/data/stop_detail_providers.dart';

class RouteDetailScreen extends ConsumerStatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> {
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;
  List<int> _trafficColors = []; // 구간별 트래픽 색상 (-1=grey, 0=green, 1=amber, 2=red)
  List<RouteStop> _routeStops = []; // 정류장 목록 캐시
  bool _isLoadingStops = false;
  RouteMeta? _routeMeta; // 노선 상세 정보 캐시 (새로고침 안함)
  bool _isLoadingRouteMeta = false;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }
  
  void _loadInitialData() async {
    final routerState = GoRouterState.of(context);
    final lineid = routerState.pathParameters['lineid']!;
    final extra = routerState.extra as Map<String, dynamic>?;
    final lineno = extra?['lineno'] as String? ?? '';
    
    // 1. 노선 상세 정보 먼저 로드
    _loadRouteMeta(lineid, lineno);
    
    // 2. 정류장 목록 로드
    _loadRouteStops(lineid);
  }
  
  void _loadRouteMeta(String lineid, String lineno) async {
    try {
      print('📋 노선 상세 정보 로드 시작');
      setState(() {
        _isLoadingRouteMeta = true;
      });
      
      final routeMeta = await BisApi.routeInfo(lineid, lineno: lineno);
      
      if (mounted) {
        setState(() {
          _routeMeta = routeMeta;
          _isLoadingRouteMeta = false;
        });
        print('✅ 노선 상세 정보 로드 완료');
      }
    } catch (e) {
      print('💥 노선 상세 정보 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoadingRouteMeta = false;
        });
      }
    }
  }
  
  void _loadRouteStops(String lineid) async {
    try {
      print('📋 정류장 목록 로드 시작');
      setState(() {
        _isLoadingStops = true;
      });
      
      final stops = await BisApi.routeStops(lineid);
      
      if (mounted) {
        setState(() {
          _routeStops = stops;
          _isLoadingStops = false;
          // 차량 위치 기반으로 트래픽 색상 설정
          _trafficColors = _generateTrafficColorsFromVehiclePositions(stops);
        });
        print('✅ 정류장 목록 로드 완료: ${stops.length}개 정류장 (초기 녹색)');
        
        // 3. Plan A: 차량 위치 기반 트래픽 색상 업데이트 (1콜/10초)
        _updateTrafficColorsInBackground(lineid);
      }
    } catch (e) {
      print('💥 정류장 목록 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoadingStops = false;
        });
      }
    }
  }
  
  void _updateTrafficColorsInBackground(String lineid) async {
    try {
      print('🚦 Plan A: 백그라운드 트래픽 색상 업데이트 시작');
      final colors = await RouteTraffic.estimateFromVehiclePositions(lineid, _routeStops);
      
      if (mounted) {
        setState(() {
          _trafficColors = colors;
        });
        print('✅ Plan A: 백그라운드 트래픽 색상 업데이트 완료: ${colors.length}개 구간');
      }
    } catch (e) {
      print('💥 Plan A: 백그라운드 트래픽 색상 업데이트 실패: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        print('🔄 10초 자동 갱신 실행');
        setState(() {
          _lastRefreshTime = DateTime.now();
        });
        // Plan A: 트래픽 색상 갱신 (1콜/10초)
        _updateTrafficColors();
      }
    });
  }
  
  void _updateTrafficColors() async {
    final routerState = GoRouterState.of(context);
    final lineid = routerState.pathParameters['lineid']!;
    
    // 정류장 목록이 없으면 갱신하지 않음
    if (_routeStops.isEmpty) {
      print('⚠️ 정류장 목록이 없어서 트래픽 색상 갱신 건너뜀');
      return;
    }
    
    // Plan A: 백그라운드에서 트래픽 색상 업데이트 (1콜/10초)
    _updateTrafficColorsInBackground(lineid);
  }

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final lineid = routerState.pathParameters['lineid']!;
    final extra = routerState.extra as Map<String, dynamic>?;
    final lineno = extra?['lineno'] as String? ?? '';
    final bustype = extra?['bustype'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/routes'),
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$lineno번 노선',
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 24,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_lastRefreshTime != null)
              Text(
                '마지막 갱신: ${_formatTime(_lastRefreshTime!)}',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('🔄 수동 갱신 실행');
              setState(() {
                _lastRefreshTime = DateTime.now();
              });
              _updateTrafficColors(); // Plan A: 1콜/10초
            },
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            tooltip: '새로고침',
          ),
        ],
        backgroundColor: const Color(0xFFF0DFCC),
        elevation: 0,
        foregroundColor: AppColors.accent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 노선 상세 정보 (API 호출 결과)
            _buildRouteDetails(lineid, lineno),
            const SizedBox(height: 16),
            
            // 정류장 목록
            _buildRouteStopsList(lineid, lineno, bustype),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteStopsList(String lineid, String lineno, String bustype) {
    // 초기 로딩 중이면 로딩 상태 표시
    if (_isLoadingStops && _routeStops.isEmpty) {
      return _buildStopsLoadingState();
    }
    
    // 정류장 목록이 없으면 빈 상태 표시
    if (_routeStops.isEmpty) {
      return _buildStopsEmptyState();
    }
    
    // 캐시된 정류장 목록 사용
    return _buildStopsList(_routeStops, lineno, bustype);
  }

  Widget _buildStopsLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text(
                '정류장 정보를 불러오는 중...',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopsErrorState(String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              '정류장 정보를 불러올 수 없습니다',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopsEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            '정류장 정보가 없습니다',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopsList(List<RouteStop> stops, String lineno, String bustype) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정류장 목록 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BusColorMapper.getRouteColor(lineno, bustype),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '정류장 목록',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 18,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 정류장 리스트
            ...stops.asMap().entries.map((entry) {
              final index = entry.key;
              final stop = entry.value;
              final isLast = index == stops.length - 1;
              final hasBus = stop.carno != null && stop.carno!.isNotEmpty;
              
              return _buildStopItem(stop, index, isLast, hasBus);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStopItem(RouteStop stop, int index, bool isLast, bool hasBus) {
    // 트래픽 상태별 색상 (구간별로 다르게 설정)
    final trafficColor = _getTrafficColor(index);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 세로 라인과 정류장 인덱스
        Column(
          children: [
            // 정류장 인덱스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: trafficColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 세로 라인
            if (!isLast)
              Container(
                width: 3,
                height: 60,
                color: trafficColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // 정류장 정보
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: hasBus ? AppColors.accent : Colors.grey.withOpacity(0.3),
                width: hasBus ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.nodenm,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (stop.arsno != null && stop.arsno!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ARS: ${stop.arsno}',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // 버스 위치 표시
                if (hasBus) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stop.carno!,
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTrafficColor(int index) {
    // 실제 트래픽 색상 사용
    if (index >= _trafficColors.length) {
      return const Color(0xFFBDBDBD); // 회색 (기본값)
    }
    
    final colorCode = _trafficColors[index];
    switch (colorCode) {
      case TrafficColors.green:
        return const Color(0xFF43A047); // 초록
      case TrafficColors.amber:
        return const Color(0xFFFB8C00); // 주황
      case TrafficColors.red:
        return const Color(0xFFE53935); // 빨강
      case TrafficColors.grey:
      default:
        return const Color(0xFFBDBDBD); // 회색
    }
  }


  Widget _buildRouteDetails(String lineid, String lineno) {
    // 로딩 중이면 로딩 카드 표시
    if (_isLoadingRouteMeta) {
      return _buildLoadingCard();
    }
    
    // 노선 상세 정보가 없으면 에러 카드 표시
    if (_routeMeta == null) {
      return _buildErrorCard('노선 정보를 불러올 수 없습니다');
    }
    
    // 캐시된 노선 상세 정보 사용
    return _buildRouteMetaCard(_routeMeta!);
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              '노선 정보를 불러올 수 없습니다',
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteMetaCard(RouteMeta routeMeta) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚌 노선 상세 정보',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 18,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 기점/종점 정보
            if (routeMeta.startpoint != null || routeMeta.endpoint != null) ...[
              _buildInfoRow('기점/종점', '${routeMeta.startpoint ?? '-'} ↔ ${routeMeta.endpoint ?? '-'}'),
              const SizedBox(height: 8),
            ],
            
            // 첫차/막차 정보
            if (routeMeta.firsttime != null || routeMeta.endtime != null) ...[
              _buildInfoRow('첫차/막차', '${routeMeta.firsttime ?? '-'} / ${routeMeta.endtime ?? '-'}'),
              const SizedBox(height: 8),
            ],
            
            // 배차 정보
            if (routeMeta.headway != null) ...[
              _buildInfoRow('배차간격', '${routeMeta.headway}분'),
              const SizedBox(height: 8),
            ],
            
            // 상세 배차 정보
            if (routeMeta.headwaynorm != null || routeMeta.headwaypeak != null || routeMeta.headwayholi != null) ...[
              _buildInfoRow('상세 배차', '평일: ${routeMeta.headwaynorm ?? '-'}분, 출퇴근: ${routeMeta.headwaypeak ?? '-'}분, 휴일: ${routeMeta.headwayholi ?? '-'}분'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
  
  /// 차량 위치 기반으로 트래픽 색상 생성 (API 호출 없이)
  List<int> _generateTrafficColorsFromVehiclePositions(List<RouteStop> stops) {
    final colors = <int>[];
    final vehiclePositions = <int>[];
    
    // 차량이 있는 정류장 인덱스 수집
    for (int i = 0; i < stops.length; i++) {
      if (stops[i].carno != null && stops[i].carno!.isNotEmpty) {
        vehiclePositions.add(i);
      }
    }
    
    print('🚌 차량 위치: ${vehiclePositions.length}개 정류장에 차량 있음');
    
    // 구간별 색상 결정
    for (int i = 0; i < stops.length - 1; i++) {
      // 현재 구간에 차량이 있으면 주황색 (혼잡)
      if (vehiclePositions.contains(i) || vehiclePositions.contains(i + 1)) {
        colors.add(TrafficColors.amber);
      } else {
        // 차량이 없으면 녹색 (원활)
        colors.add(TrafficColors.green);
      }
    }
    
    return colors;
  }
}
