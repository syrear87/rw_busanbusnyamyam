import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/stop_detail_models.dart';
import '../data/stop_detail_providers.dart';
import '../data/bus_arrival_model.dart';
import '../data/bus_arrival_provider.dart';

class StopDetailScreen extends ConsumerStatefulWidget {
  const StopDetailScreen({super.key});

  @override
  ConsumerState<StopDetailScreen> createState() => _StopDetailScreenState();
}

class _StopDetailScreenState extends ConsumerState<StopDetailScreen>
    with TickerProviderStateMixin {
  Timer? _refreshTimer; // 30초 후 API 호출용 타이머
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

    // 정류장 상세페이지 진입 로그 (한 번만 출력)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routerState = GoRouterState.of(context);
      final bstopid = routerState.pathParameters['id']!;
      final extra = routerState.extra as Map<String, dynamic>?;

      // 정류장 탭에서 가져온 데이터 확인
      final stopFromTabs = ref.read(stopDetailFromTabsProvider(bstopid));
      if (stopFromTabs != null) {
        print(
          '📍 정류장 상세 진입: 정류장 탭 데이터 활용 - ${stopFromTabs.s.name} (거리: ${stopFromTabs.m}m)',
        );
        // 30초 후 API 호출하여 최신화
        _startRefreshTimer(bstopid);
        // 카운트다운 타이머 시작
        _startCountdownTimer();
      } else {
        final name = extra?['name'] as String? ?? '알 수 없는 정류장';
        print('📍 정류장 상세 진입: extra 데이터 사용 - $name');
      }
    });
  }

  // 30초 후 API 호출 타이머 시작
  void _startRefreshTimer(String bstopid) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        // 정류장 탭 데이터가 있으면 해당 ARS 번호로 API 호출
        final stopFromTabs = ref.read(stopDetailFromTabsProvider(bstopid));
        if (stopFromTabs?.s.arsno.isNotEmpty == true) {
          ref.invalidate(busArrivalProvider(stopFromTabs!.s.arsno));
          // 새로고침 애니메이션 시작
          _refreshAnimationController?.repeat();
          // 애니메이션 2초 후 정지
          Timer(const Duration(seconds: 2), () {
            _refreshAnimationController?.stop();
            _refreshAnimationController?.reset();
          });
        }
        // 카운트다운 리셋
        _countdownSeconds = 30;

        // 다음 30초 타이머 시작
        _startRefreshTimer(bstopid);
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
  void dispose() {
    // 타이머 정리
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    // 애니메이션 컨트롤러 정리
    _refreshAnimationController?.dispose();
    // 상세 페이지가 dispose될 때 지도를 다시 활성화
    // 이는 뒤로가기나 다른 화면으로 이동할 때 호출됨
    _reactivateMapOnExit();
    super.dispose();
  }

  // 상세페이지에서 나갈 때 지도 다시 활성화
  void _reactivateMapOnExit() {
    // 뒤로가기로 나갈 때 지도가 다시 활성화되도록 플래그 설정
    // 이는 StopsScreen에서 감지하여 지도를 다시 활성화함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 정류장 목록으로 돌아갔으므로 지도 다시 활성화
      // 이는 StopsScreen의 _checkForMapReactivation에서 감지됨
    });
  }

  @override
  Widget build(BuildContext context) {
    // GoRouter 상태에서 정류장 정보 추출
    final routerState = GoRouterState.of(context);
    final bstopid = routerState.pathParameters['id']!;
    final extra = routerState.extra as Map<String, dynamic>?;

    // 정류장 탭에서 가져온 데이터 우선 사용
    final stopFromTabs = ref.watch(stopDetailFromTabsProvider(bstopid));
    final stopMeta = StopMeta(
      bstopid: bstopid,
      bstopnm:
          stopFromTabs?.s.name ?? (extra?['name'] as String? ?? '알 수 없는 정류장'),
      arsno: stopFromTabs?.s.arsno ?? (extra?['arsno'] as String? ?? ''),
      lat: stopFromTabs?.s.lat ?? (extra?['lat'] as double? ?? 0.0),
      lng: stopFromTabs?.s.lng ?? (extra?['lng'] as double? ?? 0.0),
    );

    // 추가 정보 추출 (정류장 탭에서 가져온 거리 정보 우선 사용)
    final distance = stopFromTabs?.m ?? (extra?['distance'] as int? ?? 0);

    final favoriteStops = ref.watch(favoriteStopsProvider);
    final isFavorite = favoriteStops.contains(stopMeta.bstopid);
    final arrivalSort = ref.watch(arrivalSortProvider);

    // 정류장 탭에서 가져온 버스 도착 정보 (우선 사용)
    final busArrivalsFromTabs = ref.watch(
      stopDetailBusArrivalsFromTabsProvider(bstopid),
    );

    // API 호출은 필요할 때만 (정류장 탭에 데이터가 없을 때)
    final arrivalsAsync = busArrivalsFromTabs != null
        ? AsyncValue<List<ArrivalItem>>.data([]) // 정류장 탭에 데이터가 있으면 API 호출 안함
        : ref.watch(stopArrivalsProvider(stopMeta));

    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC), // 테마 배경색
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/stops');
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        title: Text(
          stopMeta.bstopnm,
          style: const TextStyle(
            fontFamily: 'Dongle',
            fontSize: 27,
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF0DFCC), // 테마 배경색과 통일
        elevation: 0,
        foregroundColor: AppColors.accent,
        actions: [
          // 즐겨찾기 버튼만 유지
          IconButton(
            onPressed: () {
              ref
                  .read(favoriteStopsProvider.notifier)
                  .toggleFavorite(stopMeta.bstopid);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite ? '즐겨찾기에서 해제됨' : '즐겨찾기에 추가됨',
                    style: const TextStyle(fontFamily: 'Dongle'),
                  ),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : AppColors.accent,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정류장 정보 카드
            _buildInfoCard(context, stopMeta, distance),
            const SizedBox(height: 16),

            // 컨트롤 영역 (남은시간 + 새로고침 애니메이션)
            _buildControlArea(),
            const SizedBox(height: 16),

            // 도착 정보 리스트
            _buildArrivalsList(arrivalsAsync, busArrivalsFromTabs, arrivalSort),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, StopMeta stopMeta, int distance) {
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
            // 정류장 기본 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📍 정류장 정보',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 21,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (distance > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${distance}m',
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 17,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 정류장 상세 정보
            _buildInfoRow('정류장명', stopMeta.bstopnm),
            _buildInfoRow('정류장 ID', stopMeta.bstopid),
            if (stopMeta.arsno.isNotEmpty)
              _buildInfoRow('ARS 번호', stopMeta.arsno),
            const SizedBox(height: 16),

            // 푸터 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // 현재 정류장 상세페이지 경로를 returnPath로 전달
                    final routerState = GoRouterState.of(context);
                    final currentPath = routerState.uri.toString();

                    context.go(
                      '/webview',
                      extra: {
                        'url':
                            'https://www.data.go.kr/data/15092750/openapi.do',
                        'title': '부산버스정보시스템 API',
                        'returnPath': currentPath,
                      },
                    );
                  },
                  child: const Text(
                    '데이터 출처: 부산버스정보시스템(OpenAPI)',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final ticker = ref.watch(autoRefreshTickerProvider);
                    return ticker.when(
                      data: (time) => Text(
                        '마지막 업데이트 ${time.toString().substring(11, 19)}',
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      loading: () => const Text(
                        '업데이트 중...',
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      error: (_, __) => const Text(
                        '업데이트 실패',
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 정보 행을 생성하는 헬퍼 메서드
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
                fontSize: 19,
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
                fontSize: 19,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalsList(
    AsyncValue<List<ArrivalItem>> arrivalsAsync,
    AsyncValue<List<BusArrival>>? busArrivalsFromTabs,
    ArrivalSort sort,
  ) {
    // 정류장 탭에 데이터가 있으면 우선 사용
    if (busArrivalsFromTabs != null) {
      return busArrivalsFromTabs.when(
        data: (busArrivals) {
          if (busArrivals.isEmpty) {
            return _buildEmptyState();
          }

          // BusArrival을 ArrivalItem으로 변환
          final arrivals = busArrivals
              .map(
                (bus) => ArrivalItem(
                  lineid: bus.lineid,
                  lineno: bus.lineno,
                  nodenm: bus.nodenm,
                  min1: bus.min1Number, // 숫자만 추출
                  station1: bus.station1,
                  min2: bus.min2Number, // 두 번째 도착 정보도 사용
                  station2: bus.station2,
                  bustype: bus.bustype,
                  lowplate1: bus.lowplate1,
                ),
              )
              .toList();

          // 정렬 적용
          final sortedArrivals = _sortArrivals(arrivals, sort);

          return Column(
            children: sortedArrivals
                .map((arrival) => _buildArrivalCard(arrival))
                .toList(),
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState(),
      );
    }

    // 정류장 탭에 데이터가 없으면 API 호출 결과 사용
    return arrivalsAsync.when(
      data: (arrivals) {
        if (arrivals.isEmpty) {
          return _buildEmptyState();
        }

        // 정렬 적용
        final sortedArrivals = _sortArrivals(arrivals, sort);

        return Column(
          children: sortedArrivals
              .map((arrival) => _buildArrivalCard(arrival))
              .toList(),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(),
    );
  }

  List<ArrivalItem> _sortArrivals(
    List<ArrivalItem> arrivals,
    ArrivalSort sort,
  ) {
    final sorted = List<ArrivalItem>.from(arrivals);

    switch (sort) {
      case ArrivalSort.imminent:
        sorted.sort((a, b) {
          final aTime = int.tryParse(a.min1) ?? 999;
          final bTime = int.tryParse(b.min1) ?? 999;
          return aTime.compareTo(bTime);
        });
        break;
      case ArrivalSort.line:
        sorted.sort((a, b) => a.lineno.compareTo(b.lineno));
        break;
    }

    return sorted;
  }

  Widget _buildArrivalCard(ArrivalItem arrival) {
    final routeColor = BusColorMapper.getRouteColor(
      arrival.lineno,
      arrival.bustype,
    );
    final isLowFloor = arrival.lowplate1 == '1';

    return GestureDetector(
      onTap: () {
        // 버스 카드 클릭 시 노선 상세 페이지로 이동
        context.go(
          '/routes/${arrival.lineid}',
          extra: {
            'lineno': arrival.lineno,
            'bustype': arrival.bustype ?? '',
          },
        );
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 버스 번호 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: routeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  arrival.lineno,
                  style: const TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 도착 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (arrival.min1.isEmpty && arrival.min2.isEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '도착정보 없음',
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 19,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLowFloor) ...[
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/low_floor_bus.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      // 첫 번째 도착 정보
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              arrival.min1.isNotEmpty
                                  ? '${arrival.min1}분 후 · ${arrival.station1}정류장 전'
                                  : '도착정보 없음',
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 19,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLowFloor) ...[
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/low_floor_bus.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ],
                      ),
                      // 두 번째 도착 정보
                      if (arrival.min2.isNotEmpty &&
                          arrival.station2.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '다음 ${arrival.min2}분 후 · ${arrival.station2}정류장 전',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(children: List.generate(3, (index) => _buildSkeletonCard()));
  }

  Widget _buildSkeletonCard() {
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
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 스켈레톤 배지 (개선된 디자인)
            Container(
              width: 70,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            // 스켈레톤 텍스트 (개선된 레이아웃)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 도착 시간과 정류장 정보를 하나의 텍스트로 (실제와 동일)
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // 저상버스 아이콘 스켈레톤 (실제와 동일한 위치)
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 두 번째 도착 정보 스켈레톤 (작은 텍스트)
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            // 스켈레톤 화살표
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Text(
          '현재 도착 정보가 없습니다',
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'BIS 응답 지연. 잠시 후 다시 시도해 주세요',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 19,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 컨트롤 영역 (남은시간 + 새로고침 애니메이션)
  Widget _buildControlArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
      ),
    );
  }
}
