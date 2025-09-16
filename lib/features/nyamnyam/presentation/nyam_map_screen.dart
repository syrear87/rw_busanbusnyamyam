import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/nyam_providers.dart';
import '../data/nyam_query_state.dart';
import '../data/location_provider.dart';
import 'nyam_map_with_list.dart';
import 'route_selection_screen.dart';

class NyamMapScreen extends ConsumerStatefulWidget {
  const NyamMapScreen({super.key});

  @override
  ConsumerState<NyamMapScreen> createState() => _NyamMapScreenState();
}

class _NyamMapScreenState extends ConsumerState<NyamMapScreen> {
  @override
  Widget build(BuildContext context) {
    final query = ref.watch(nyamQueryProvider);
    final location = ref.watch(locationProvider);
    final places = ref.watch(placesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC),
      body: Stack(
        children: [
          // GoogleMap (전면)
          MapWithListView(
            query: query,
            location: location,
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
    return Container(
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
          const SizedBox(width: 4),
          PopupMenuButton<int>(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF7BB074),
              size: 16,
            ),
            onSelected: (int radius) {
              ref.read(nyamQueryProvider.notifier).updateRadius(radius);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                value: 200,
                child: Text(
                  '200m',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
                    color: query.radius == 200
                        ? const Color(0xFF7BB074)
                        : Colors.black87,
                    fontWeight: query.radius == 200
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem<int>(
                value: 400,
                child: Text(
                  '400m',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
                    color: query.radius == 400
                        ? const Color(0xFF7BB074)
                        : Colors.black87,
                    fontWeight: query.radius == 400
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem<int>(
                value: 700,
                child: Text(
                  '700m',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
                    color: query.radius == 700
                        ? const Color(0xFF7BB074)
                        : Colors.black87,
                    fontWeight: query.radius == 700
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPillButton(BuildContext context, NyamQueryState query) {
    return Container(
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
          const SizedBox(width: 4),
          PopupMenuButton<QueryCategory>(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF7BB074),
              size: 16,
            ),
            onSelected: (QueryCategory category) {
              ref.read(nyamQueryProvider.notifier).updateCategory(category);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<QueryCategory>(
                value: QueryCategory.all,
                child: Text(
                  '전체',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
                    color: query.category == QueryCategory.all
                        ? const Color(0xFF7BB074)
                        : Colors.black87,
                    fontWeight: query.category == QueryCategory.all
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem<QueryCategory>(
                value: QueryCategory.restaurant,
                child: Text(
                  '음식점',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
                    color: query.category == QueryCategory.restaurant
                        ? const Color(0xFF7BB074)
                        : Colors.black87,
                    fontWeight: query.category == QueryCategory.restaurant
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem<QueryCategory>(
                value: QueryCategory.cafe,
                child: Text(
                  '카페',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStopPillButton(BuildContext context) {
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
                    const Icon(
                      Icons.directions_bus,
                      color: Color(0xFF7BB074),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '정류장',
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
