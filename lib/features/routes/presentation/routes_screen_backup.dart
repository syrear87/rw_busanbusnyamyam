import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/busan_bis_api.dart';
import '../../../../widgets/top_banner_ad_widget.dart';

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    return Scaffold(
      backgroundColor: AppColors.ivoryBase,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 배너 광고
            const TopBannerAdWidget(),
            
            // 메인 콘텐츠
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // 다른 곳 터치 시 포커싱 제거 및 키보드 숨김
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
              // 검색 필드
              TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '버스 번호 입력 (예: 50)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 19,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderSage),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accent, width: 2),
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.accent),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 19,
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 24),
              // 검색 결과
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
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
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? '버스 번호를 입력하면 검색 결과가 표시됩니다.'
                                  : '검색 결과가 없습니다.',
                              style: const TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 19,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              // 스크롤 시 포커싱 제거 및 키보드 숨김
                              if (notification is ScrollStartNotification) {
                                FocusScope.of(context).unfocus();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                              final route = _searchResults[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
                                ),
                                child: ListTile(
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
                                  onTap: () {
                                    // 노선 상세 페이지로 이동
                                    context.go(
                                      '/routes/${route.lineid}',
                                      extra: {
                                        'lineno': route.lineno,
                                        'bustype': route.bustype,
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
