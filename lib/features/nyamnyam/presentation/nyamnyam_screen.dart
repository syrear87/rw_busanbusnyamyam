import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/nyam_providers.dart';
import '../data/place_model.dart';

class NyamNyamScreen extends ConsumerWidget {
  const NyamNyamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStopName = ref.watch(selectedStopNameProvider);
    final category = ref.watch(categoryProvider);
    final radius = ref.watch(radiusProvider);
    final placeResults = ref.watch(placeResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0DFCC),
      appBar: AppBar(
        title: const Text(
          '냠냠',
          style: TextStyle(
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 정류장 선택 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7BB074), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF7BB074),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedStopName,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          color: Color(0xFF7BB074),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF7BB074),
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 카테고리 선택
              Row(
                children: [
                  Expanded(
                    child: _CategoryChip(
                      label: '🍚 맛집',
                      isSelected: category == 'FD6',
                      onTap: () => ref.read(categoryProvider.notifier).state = 'FD6',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CategoryChip(
                      label: '☕ 카페',
                      isSelected: category == 'CE7',
                      onTap: () => ref.read(categoryProvider.notifier).state = 'CE7',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 반경 선택
              Row(
                children: [
                  _RadiusChip(
                    label: '200m',
                    isSelected: radius == 200,
                    onTap: () => ref.read(radiusProvider.notifier).state = 200,
                  ),
                  const SizedBox(width: 8),
                  _RadiusChip(
                    label: '400m',
                    isSelected: radius == 400,
                    onTap: () => ref.read(radiusProvider.notifier).state = 400,
                  ),
                  const SizedBox(width: 8),
                  _RadiusChip(
                    label: '700m',
                    isSelected: radius == 700,
                    onTap: () => ref.read(radiusProvider.notifier).state = 700,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 결과 리스트
              Expanded(
                child: placeResults.when(
                  data: (places) => places.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = places[index];
                            return _PlaceCard(place: place);
                          },
                        ),
                  loading: () => _LoadingState(),
                  error: (error, stack) => _ErrorState(error: error.toString()),
                ),
              ),
              
              // 하단 정보
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  '데이터 출처: 카카오맵 장소검색(준비 중)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 16,
                    color: Colors.grey,
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7BB074) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF7BB074),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 20,
            color: isSelected ? Colors.white : const Color(0xFF7BB074),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadiusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7BB074) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7BB074),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Dongle',
            fontSize: 18,
            color: isSelected ? Colors.white : const Color(0xFF7BB074),
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final distance = place.distanceM ?? 0;
    final walkTime = (distance / 70).ceil();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchUrl(place.url),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${distance}m · 도보 ${walkTime}분',
                        style: const TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      if (place.address != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          place.address!,
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
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
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            '오류가 발생했습니다',
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
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
