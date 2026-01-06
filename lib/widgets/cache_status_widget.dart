import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/cache/cache_providers.dart';

/// 캐시 상태 표시 위젯
class CacheStatusWidget extends ConsumerWidget {
  const CacheStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStatusAsync = ref.watch(cacheStatusProvider);

    return cacheStatusAsync.when(
      data: (status) => _buildStatusCard(context, status),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => _buildErrorCard(context, error),
    );
  }

  Widget _buildStatusCard(BuildContext context, CacheStatus status) {
    final isOffline = !status.isOnline;
    final hasData = status.hasOfflineData;
    final totalItems = status.totalCachedItems;
    final expiredItems = status.expiredItems;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isOffline ? Icons.cloud_off : Icons.cloud,
                  color: isOffline ? Colors.orange : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOffline ? '오프라인 모드' : '온라인 모드',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isOffline ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasData) ...[
              Text(
                '캐시된 데이터: $totalItems개',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (expiredItems > 0)
                Text(
                  '만료된 데이터: $expiredItems개',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              Text(
                '마지막 업데이트: ${_formatDateTime(status.lastUpdate)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              Text(
                '캐시된 데이터 없음',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '캐시 상태 조회 실패: $error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}

/// 캐시 정리 버튼 위젯
class CacheCleanupWidget extends ConsumerWidget {
  const CacheCleanupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await ref.read(cacheCleanupProvider.future);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('캐시가 정리되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('캐시 정리 실패: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.cleaning_services),
      label: const Text('캐시 정리'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

