import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../stops/data/stop_detail_providers.dart';
import '../../stops/data/stops_provider.dart';
import '../../stops/data/stop_model.dart';
import '../../stops/data/bus_arrival_provider.dart';
import '../../stops/data/bus_arrival_model.dart';
import '../../routes/presentation/route_detail_screen.dart';
import '../../../../data/busan_bis_api.dart';

// 노선 정보를 위한 Provider
final routeInfoProvider = FutureProvider.family<RouteMeta?, String>((ref, lineid) {
  return BisApi.routeInfo(lineid);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  Timer? _refreshTimer;
  Timer? _countdownTimer; // 카운트다운 타이머
  AnimationController? _refreshAnimationController; // 새로고침 애니메이션 컨트롤러
  int _countdownSeconds = 30; // 30초 카운트다운

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _refreshAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    _refreshAnimationController?.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    // 카운트다운 타이머 시작
    _startCountdownTimer();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        print('🔄 홈 탭 30초 자동 갱신 실행');
        
        // 새로고침 애니메이션 시작
        _refreshAnimationController?.repeat();
        // 애니메이션 2초 후 정지
        Timer(const Duration(seconds: 2), () {
          _refreshAnimationController?.stop();
          _refreshAnimationController?.reset();
        });
        
        // 카운트다운 리셋
        _countdownSeconds = 30;
      }
    });
  }
  
  // 카운트다운 타이머 시작
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdownSeconds--;
        });

        if (_countdownSeconds <= 0) {
          _countdownSeconds = 30; // 리셋
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryBase, // 스크린 배경색
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 즐겨찾기 정류장 섹션
              _buildFavoriteStopsSection(),
              const SizedBox(height: 24),
              
              // 즐겨찾기 노선 섹션
              _buildFavoriteRoutesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 즐겨찾기 정류장 섹션
  Widget _buildFavoriteStopsSection() {
    final favoriteStops = ref.watch(favoriteStopsProvider);
    final allStops = ref.watch(stopsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 즐겨찾는 정류장 헤더 + 컨트롤 영역
        Row(
          children: [
            const Text(
              '⭐ 즐겨찾는 정류장',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 23,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // 컨트롤 영역 (남은시간 + 새로고침 애니메이션)
            _buildControlArea(),
          ],
        ),
        const SizedBox(height: 16),
        
        allStops.when(
          data: (stops) {
            final favoriteStopList = stops
                .where((stop) => favoriteStops.contains(stop.id))
                .toList();

            if (favoriteStopList.isEmpty) {
              return _buildEmptyState(
                '즐겨찾는 정류장이 없습니다',
                '정류장 탭에서 별 아이콘을 눌러 즐겨찾기에 추가해보세요',
                Icons.star_border,
              );
            }

            return Column(
              children: favoriteStopList
                  .map((stop) => _buildStopCard(stop))
                  .toList(),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState('정류장 정보를 불러올 수 없습니다'),
        ),
      ],
    );
  }

  // 즐겨찾기 노선 섹션
  Widget _buildFavoriteRoutesSection() {
    final favoriteRoutes = ref.watch(favoriteRoutesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚌 즐겨찾는 노선',
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 20,
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (favoriteRoutes.isEmpty)
          _buildEmptyState(
            '즐겨찾는 노선이 없습니다',
            '노선 상세페이지에서 별 아이콘을 눌러 즐겨찾기에 추가해보세요',
            Icons.directions_bus,
          )
        else
          Column(
            children: favoriteRoutes
                .map((lineid) => _buildRouteCard(lineid))
                .toList(),
          ),
      ],
    );
  }

  // 정류장 카드
  Widget _buildStopCard(Stop stop) {
    // 도착 정보 가져오기 (ARS 번호가 있을 때만)
    final arrivalsAsync = stop.arsno.isNotEmpty 
        ? ref.watch(busArrivalProvider(stop.arsno))
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accent),
      ),
      child: InkWell(
        onTap: () {
          context.go(
            '/stops/${stop.id}',
            extra: {
              'name': stop.name,
              'arsno': stop.arsno,
              'lat': stop.lat,
              'lng': stop.lng,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 정류장 기본 정보
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 19,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (stop.arsno.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'ARS: ${stop.arsno}',
                            style: const TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(favoriteStopsProvider.notifier)
                          .toggleFavorite(stop.id);
                    },
                    icon: const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              
              // 도착 정보
              if (arrivalsAsync != null) ...[
                const SizedBox(height: 12),
                arrivalsAsync.when(
                  data: (arrivals) {
                    if (arrivals.isEmpty) {
                      return const Text(
                        '도착 정보 없음',
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                      );
                    }
                    
                    // 최대 3개까지만 표시
                    final displayArrivals = arrivals.take(3).toList();
                    
                    return Column(
                      children: displayArrivals.map((arrival) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: BusColorMapper.getRouteColor(
                                  arrival.lineno,
                                  arrival.bustype,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                arrival.lineno,
                                style: const TextStyle(
                                  fontFamily: 'Dongle',
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  arrival.min1.isNotEmpty 
                                      ? '${arrival.min1}분 후 · ${arrival.station1}정류장 전'
                                      : '도착정보 없음',
                                  style: const TextStyle(
                                    fontFamily: 'Dongle',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // 저상 버스 표시 (실제 저상 버스 유무 판단)
                              if (arrival.lowplate1 == '1') ...[
                                const SizedBox(width: 4),
                                Image.asset(
                                  'assets/images/low_floor_bus.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Text(
                    '도착 정보 로딩 중...',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                  ),
                  error: (error, _) => const Text(
                    '도착 정보 오류',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 17,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 노선 카드
  Widget _buildRouteCard(String lineid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accent),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final routeInfoAsync = ref.watch(routeInfoProvider(lineid));
          
          return routeInfoAsync.when(
            data: (routeMeta) {
              final busNumber = routeMeta?.lineno ?? lineid;
              
              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${busNumber}번 노선',
                  style: const TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 19,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (routeMeta?.startpoint != null || routeMeta?.endpoint != null) ...[
                      Text(
                        '${routeMeta?.startpoint ?? '-'} ↔ ${routeMeta?.endpoint ?? '-'}',
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    Text(
                      '노선 ID: $lineid',
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    ref
                        .read(favoriteRoutesProvider.notifier)
                        .toggleFavorite(lineid);
                  },
                  icon: const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
                onTap: () {
                  context.go(
                    '/routes/$lineid',
                    extra: {
                      'lineno': busNumber,
                      'bustype': '',
                    },
                  );
                },
              );
            },
            loading: () => ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                '노선 정보 로딩 중...',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 19,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '노선 ID: $lineid',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
            error: (error, stackTrace) => ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                '노선 정보 오류',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 19,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '노선 ID: $lineid',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 컨트롤 영역 (남은시간 + 새로고침 애니메이션)
  Widget _buildControlArea() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 남은시간 표시 (0:30 형식)
        Text(
          '0:${_countdownSeconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontFamily: 'Dongle',
            fontSize: 19,
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        // 새로고침 아이콘 (애니메이션)
        AnimatedBuilder(
          animation:
              _refreshAnimationController ?? const AlwaysStoppedAnimation(0),
          builder: (context, child) {
            final animationValue = _refreshAnimationController?.value ?? 0;
            return Transform.rotate(
              angle: animationValue * 2 * 3.14159,
              child: Icon(Icons.refresh, color: AppColors.accent, size: 20),
            );
          },
        ),
      ],
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 19,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  // 로딩 상태 위젯
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              '로딩 중...',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 19,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 에러 상태 위젯
  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 19,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
