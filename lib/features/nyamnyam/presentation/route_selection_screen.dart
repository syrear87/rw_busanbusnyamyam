import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/busan_bis_api.dart';
import '../data/route_providers.dart';
import '../data/route_model.dart' hide RouteStop;
import '../data/nyam_query_state.dart';
import '../data/nyam_providers.dart';
import '../data/busan_stops_service.dart';

class RouteSelectionScreen extends ConsumerStatefulWidget {
  const RouteSelectionScreen({super.key});

  @override
  ConsumerState<RouteSelectionScreen> createState() =>
      _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends ConsumerState<RouteSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;
  List<RouteMeta> _searchResults = [];
  List<RouteMeta> _allRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 부산시 모든 버스 노선 로드
  Future<void> _loadAllRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final routes = await BisApi.getAllRoutes();
      setState(() {
        _allRoutes = routes;
        _isLoading = false;
      });
      print('✅ 노선 목록 로드 완료: ${routes.length}개');
    } catch (e) {
      print('❌ 노선 목록 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // 먼저 캐시된 데이터에서 검색
    final cachedResults = _allRoutes.where((route) {
      return route.lineno.contains(query);
    }).toList();

    setState(() {
      _searchResults = cachedResults;
    });

    // 캐시된 결과가 적으면 실시간 API 검색도 수행
    if (cachedResults.length < 5 && query.length >= 2) {
      _performRealTimeSearch(query);
    }
  }

  Future<void> _performRealTimeSearch(String query) async {
    try {
      final realTimeResults = await BisApi.searchRoutesByNumber(query);

      // 실시간 검색 결과와 캐시 결과를 합치고 중복 제거
      final Set<String> existingLineIds = _searchResults.map((r) => r.lineid).toSet();
      final newResults = realTimeResults.where((route) => !existingLineIds.contains(route.lineid)).toList();

      setState(() {
        _searchResults = [..._searchResults, ...newResults];
      });

      if (newResults.isNotEmpty) {
        print('✅ 실시간 검색으로 ${newResults.length}개 추가 노선 발견');
      }
    } catch (e) {
      print('⚠️ 실시간 검색 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '정류장 선택',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 검색바
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '버스 번호 입력 (예: 50)',
                hintStyle: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 16,
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7BB074)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7BB074)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF7BB074),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),

          // 검색 결과
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF7BB074)),
                        SizedBox(height: 16),
                        Text(
                          '버스 노선 목록을 불러오는 중...',
                          style: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 19,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : _searchController.text.isEmpty
                    ? _buildEmptyState()
                    : _searchResults.isEmpty
                        ? _buildNoResults()
                        : _buildNewSearchResults(),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '버스 번호를 입력해보세요',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '148, 50, 100 등',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewSearchResults() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 스크롤 시 포커싱 제거 및 키보드 숨김
        if (notification is ScrollStartNotification) {
          FocusScope.of(context).unfocus();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final route = _searchResults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF7BB074).withOpacity(0.3)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BB074),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                '${route.bustype} ${route.lineno}번',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${route.startpoint ?? '-'} ↔ ${route.endpoint ?? '-'}',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              onTap: () => _onRouteSelectedNew(route),
            ),
          );
        },
      ),
    );
  }

  void _onRouteSelectedNew(RouteMeta route) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RouteStopsScreenNew(route: route)),
    );
  }



  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '다른 버스 번호를 입력해보세요',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

}


// 새로운 Route stops screen - BisApi의 RouteMeta를 사용
class RouteStopsScreenNew extends ConsumerWidget {
  final RouteMeta route;

  const RouteStopsScreenNew({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC),
      appBar: AppBar(
        title: Text(
          '${route.lineno}번 정류장',
          style: const TextStyle(
            fontFamily: 'Dongle',
            fontSize: 28,
            color: Color(0xFF7BB074),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<RouteStop>>(
        future: BisApi.routeStops(route.lineid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final stops = snapshot.data ?? [];
          if (stops.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              return _buildStopCard(context, ref, stop, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    WidgetRef ref,
    RouteStop routeStop,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onStopSelectedNew(context, ref, routeStop),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 순서 번호
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BB074),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      routeStop.index.toString(),
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 정류장 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeStop.nodenm,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (routeStop.arsno != null)
                        Text(
                          'ARS: ${routeStop.arsno}',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                // 화살표
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF7BB074),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bus_alert, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '정류장 정보가 없습니다',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            '정류장 조회 중 오류가 발생했습니다',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 24,
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
        ],
      ),
    );
  }

  void _onStopSelectedNew(BuildContext context, WidgetRef ref, RouteStop routeStop) async {
    print('🚏 정류장 선택: ${routeStop.nodenm}');

    // 좌표 설정 (BIS API에서 가져온 좌표 우선 사용, 없으면 로컬 JSON에서 조회)
    double lat = routeStop.lat;
    double lng = routeStop.lng;

    if (lat == 0.0 && lng == 0.0) {
      // 로컬 JSON 파일로 좌표 조회
      final coordinates = await BusanStopsService.instance.getStopCoordinates(routeStop.nodeid);

      if (coordinates != null) {
        lat = coordinates.$1;
        lng = coordinates.$2;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '정류장 좌표 정보를 찾을 수 없습니다. 다른 정류장을 선택해주세요.',
              style: const TextStyle(fontFamily: 'Dongle', fontSize: 18),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // RouteStop을 SelectedStop으로 변환
    final selectedStop = SelectedStop(
      id: routeStop.nodeid,
      name: routeStop.nodenm,
      lat: lat,
      lon: lng,
      seq: routeStop.index,
    );


    // nyamnyam 화면의 query provider에 정류장 설정
    ref.read(nyamQueryProvider.notifier).selectStop(selectedStop);

    // 모든 네비게이션 스택 팝 (바텀시트와 정류장 상세 화면 모두 닫기)
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${routeStop.nodenm} 정류장 주변 ${ref.read(nyamQueryProvider).radius}m에서 음식점/카페를 검색 중...',
                style: const TextStyle(fontFamily: 'Dongle', fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF7BB074),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
