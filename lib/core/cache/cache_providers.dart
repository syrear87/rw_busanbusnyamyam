import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'cache_service.dart';
import 'cache_models.dart';

/// 캐시 서비스 Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// 캐시 상태 Provider
final cacheStatusProvider = FutureProvider<CacheStatus>((ref) async {
  final cacheService = ref.read(cacheServiceProvider);
  return await cacheService.getCacheStatus();
});

/// 오프라인 모드 Provider
final offlineModeProvider = Provider<bool>((ref) {
  final cacheService = ref.read(cacheServiceProvider);
  return cacheService.isOfflineMode;
});

/// 캐시 정리 Provider
final cacheCleanupProvider = FutureProvider<void>((ref) async {
  final cacheService = ref.read(cacheServiceProvider);
  await cacheService.clearCache();
});

/// 캐시 서비스 초기화 Provider
final cacheInitializationProvider = FutureProvider<void>((ref) async {
  final cacheService = ref.read(cacheServiceProvider);
  await cacheService.initialize();
});

