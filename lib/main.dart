import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/admob_service.dart';
import 'core/cache/cache_service.dart';
import 'features/settings/data/font_size_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMob 초기화
  await AdMobService.initialize();

  // 캐시 서비스 초기화
  await CacheService().initialize();

  runApp(const ProviderScope(child: BusanBusNyamNyamApp()));
}

class BusanBusNyamNyamApp extends ConsumerWidget {
  const BusanBusNyamNyamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // 강제 라이트 유지
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        final fontSizeOption = ref.watch(fontSizeProvider);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontSizeOption.textScaleFactor),
          ),
          child: child!,
        );
      },
    );
  }
}
