import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/stop_model.dart';
import '../data/stops_provider.dart';

class StopDetailScreen extends ConsumerWidget {
  final String stopId;
  final String? stopName;

  const StopDetailScreen({super.key, required this.stopId, this.stopName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(stopsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(stopName ?? stopId),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.accent,
        titleTextStyle: const TextStyle(
          fontFamily: 'Dongle',
          fontSize: 28,
          color: AppColors.accent,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 새로고침 기능 (향후 구현)
            },
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
        ],
      ),
      body: stopsAsync.when(
        data: (stops) {
          final stop = stops.firstWhere(
            (s) => s.id == stopId,
            orElse: () => Stop(
              id: stopId,
              name: stopName ?? '알 수 없는 정류장',
              arsno: '',
              lat: 0,
              lng: 0,
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 정류장 정보 카드
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${stop.id}',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 16,
                            color: AppColors.text,
                          ),
                        ),
                        if (stop.arsno.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ARS: ${stop.arsno}',
                            style: const TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '위치: ${stop.lat.toStringAsFixed(6)}, ${stop.lng.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 14,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 실시간 도착 정보 섹션
                const Text(
                  '실시간 도착 (준비중)',
                  style: TextStyle(
                    fontFamily: 'Dongle',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),

                // 도착 정보 카드 (플레이스홀더)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPlaceholderArrivalRow('100번', '5분 후', '저상버스'),
                        const Divider(color: AppColors.accent),
                        _buildPlaceholderArrivalRow('200번', '8분 후', '일반버스'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 지도에서 보기 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // 지도에서 보기 기능 (향후 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '지도에서 보기 기능은 준비중입니다',
                            style: TextStyle(fontFamily: 'Dongle'),
                          ),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '지도에서 보기',
                      style: TextStyle(fontFamily: 'Dongle', fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Text(
                '정류장 정보를 불러올 수 없습니다',
                style: const TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(stopsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '다시 시도',
                  style: TextStyle(fontFamily: 'Dongle', fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderArrivalRow(String route, String time, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              route,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              time,
              style: const TextStyle(
                fontFamily: 'Dongle',
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            type,
            style: const TextStyle(
              fontFamily: 'Dongle',
              fontSize: 14,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
