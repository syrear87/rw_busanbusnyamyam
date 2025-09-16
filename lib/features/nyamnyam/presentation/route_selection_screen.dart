import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/route_providers.dart';
import '../data/route_model.dart';
import '../data/nyam_query_state.dart';
import '../data/nyam_providers.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
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
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '노선 번호를 입력하세요 (예: 148, 100번, 부산대)',
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
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _normalizeSearchQuery(value.trim());
      });
    });
  }

  String _normalizeSearchQuery(String query) {
    // 한글/영문/숫자만 허용, 공백 trim
    return query.replaceAll(RegExp(r'[^가-힣a-zA-Z0-9\s]'), '').trim();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '노선 번호를 입력해보세요',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '148, 300, 50 등',
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

  Widget _buildSearchResults() {
    final routesAsync = ref.watch(routeSearchProvider(_searchQuery));

    return routesAsync.when(
      data: (routes) => routes.isEmpty
          ? _buildNoResults()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return _buildRouteCard(route);
              },
            ),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildRouteCard(BusRoute route) {
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
          onTap: () => _onRouteSelected(route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 노선 번호
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRouteColor(route.routeType),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      route.routeNumber,
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 노선 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.routeName,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        route.routeType,
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
      itemCount: 3,
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
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
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
            '다른 노선 번호를 입력해보세요',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            '검색 중 오류가 발생했습니다',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
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

  Color _getRouteColor(String routeType) {
    switch (routeType) {
      case '급행버스':
        return Colors.red;
      case '마을버스':
        return Colors.green;
      case '간선버스':
        return Colors.blue;
      default:
        return const Color(0xFF7BB074);
    }
  }

  void _onRouteSelected(BusRoute route) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RouteStopsScreen(route: route)),
    );
  }
}

// Route stops screen to show stops for a selected route
class RouteStopsScreen extends ConsumerWidget {
  final BusRoute route;

  const RouteStopsScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(routeStopsProvider(route.routeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC),
      appBar: AppBar(
        title: Text(
          '${route.routeNumber}번 정류장',
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
      body: stopsAsync.when(
        data: (stops) => stops.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stops.length,
                itemBuilder: (context, index) {
                  final stop = stops[index];
                  return _buildStopCard(context, ref, stop, index);
                },
              ),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    WidgetRef ref,
    RouteStop routeStop,
    int index,
  ) {
    final stop = routeStop.stop;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: routeStop.isKey
            ? Border.all(color: const Color(0xFF7BB074), width: 2)
            : null,
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
          onTap: () => _onStopSelected(context, ref, stop),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 순서 번호
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: routeStop.isKey
                        ? const Color(0xFF7BB074)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      routeStop.sequence.toString(),
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: routeStop.isKey ? Colors.white : Colors.black54,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stop.stopName,
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (routeStop.isKey)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7BB074),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '주요',
                                style: TextStyle(
                                  fontFamily: 'Dongle',
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ARS: ${stop.stopNumber}',
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

  void _onStopSelected(BuildContext context, WidgetRef ref, BusStop stop) {
    // 정류장 선택 시 SelectedStop 객체 생성
    final selectedStop = SelectedStop(
      id: stop.stopId,
      name: stop.stopName,
      lat: stop.lat,
      lon: stop.lon,
      seq: 0, // 정류장 순서는 별도로 관리
    );

    // nyamnyam 화면의 query provider에 정류장 설정
    ref.read(nyamQueryProvider.notifier).selectStop(selectedStop);

    // 바텀시트 닫기
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${stop.stopName} 정류장이 선택되었습니다',
          style: const TextStyle(fontFamily: 'Dongle', fontSize: 18),
        ),
        backgroundColor: const Color(0xFF7BB074),
      ),
    );
  }
}
