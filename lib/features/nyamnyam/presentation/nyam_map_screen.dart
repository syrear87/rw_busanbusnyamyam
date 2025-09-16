import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/nyam_providers.dart';
import '../data/nyam_query_state.dart';
import '../data/location_provider.dart';
import '../../stops/data/location_provider.dart' as stops_location;
import 'nyam_map_with_list.dart';
import 'route_selection_screen.dart';

class NyamMapScreen extends ConsumerStatefulWidget {
  const NyamMapScreen({super.key});

  @override
  ConsumerState<NyamMapScreen> createState() => _NyamMapScreenState();
}

class _NyamMapScreenState extends ConsumerState<NyamMapScreen> {
  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 위치 권한 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    print('🚀 NyamMapScreen: 위치 권한 확인 및 요청 시작');
    try {
      // 정류장 탭과 동일한 location controller 사용
      await ref.read(stops_location.locationController.notifier).requestLocationPermission();
    } catch (e) {
      print('🚀 NyamMapScreen: 위치 권한 요청 중 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(nyamQueryProvider);
    final location = ref.watch(locationProvider);
    final stopsLocation = ref.watch(stops_location.locationController);
    final places = ref.watch(placesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC),
      body: Stack(
        children: [
          // GoogleMap (전면)
          MapWithListView(
            query: query,
            location: location,
            stopsLocation: stopsLocation,
            places: places,
            onMapControllerCreated: (controller) {
              // Map controller is handled in MapWithListView
            },
          ),

          // 상단 HUD: SafeArea(top:true) + Align(topRight) + Padding(8) + 작은 Pill 버튼들
          SafeArea(
            top: true,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRadiusPillButton(context, query),
                    const SizedBox(height: 8),
                    _buildCategoryPillButton(context, query),
                    const SizedBox(height: 8),
                    _buildStopPillButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusPillButton(BuildContext context, NyamQueryState query) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                '반경 선택',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 20,
                  color: Color(0xFF7BB074),
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [200, 400, 700].map((int radius) {
                return SimpleDialogOption(
                  onPressed: () {
                    ref.read(nyamQueryProvider.notifier).updateRadius(radius);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '${radius}m',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 18,
                      color: query.radius == radius
                          ? const Color(0xFF7BB074)
                          : Colors.black87,
                      fontWeight: query.radius == radius
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            const Icon(Icons.location_on, color: Color(0xFF7BB074), size: 16),
            const SizedBox(width: 4),
            Text(
              '${query.radius}m',
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: Color(0xFF7BB074),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPillButton(BuildContext context, NyamQueryState query) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                '카테고리 선택',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 20,
                  color: Color(0xFF7BB074),
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    ref.read(nyamQueryProvider.notifier).updateCategory(QueryCategory.all);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '전체',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 18,
                      color: query.category == QueryCategory.all
                          ? const Color(0xFF7BB074)
                          : Colors.black87,
                      fontWeight: query.category == QueryCategory.all
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    ref.read(nyamQueryProvider.notifier).updateCategory(QueryCategory.restaurant);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '음식점',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 18,
                      color: query.category == QueryCategory.restaurant
                          ? const Color(0xFF7BB074)
                          : Colors.black87,
                      fontWeight: query.category == QueryCategory.restaurant
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    ref.read(nyamQueryProvider.notifier).updateCategory(QueryCategory.cafe);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '카페',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 18,
                      color: query.category == QueryCategory.cafe
                          ? const Color(0xFF7BB074)
                          : Colors.black87,
                      fontWeight: query.category == QueryCategory.cafe
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Icon(
              query.category == QueryCategory.restaurant
                  ? Icons.restaurant
                  : query.category == QueryCategory.cafe
                  ? Icons.local_cafe
                  : Icons.category,
              color: const Color(0xFF7BB074),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              query.category == QueryCategory.all
                  ? '전체'
                  : query.category == QueryCategory.restaurant
                  ? '음식점'
                  : '카페',
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: Color(0xFF7BB074),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopPillButton(BuildContext context) {
    final query = ref.watch(nyamQueryProvider);
    final hasSelectedStop = query.selectedStop != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = (screenWidth * 0.6).clamp(48.0, 280.0);

        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: 48, maxWidth: maxWidth),
          child: FittedBox(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const RouteSelectionScreen(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white, // 항상 흰색 배경 유지
                  borderRadius: BorderRadius.circular(20),
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
                    const Icon(
                      Icons.directions_bus, // 항상 버스 아이콘 유지
                      color: Color(0xFF7BB074),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasSelectedStop
                          ? (query.selectedStop!.name.length > 10
                              ? '${query.selectedStop!.name.substring(0, 10)}...'
                              : query.selectedStop!.name)
                          : '정류장',
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 16,
                        color: Color(0xFF7BB074),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
