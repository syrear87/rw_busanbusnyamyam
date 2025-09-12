import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/stops/presentation/stops_screen.dart';
import '../../features/stops/presentation/stop_detail_screen.dart';
import '../../features/routes/presentation/routes_screen.dart';
import '../../features/routes/presentation/route_detail_screen.dart';
import '../../features/nyamnyam/presentation/nyamnyam_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/webview/presentation/webview_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/stops',
            builder: (context, state) => const StopsScreen(),
          ),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const RoutesScreen(),
          ),
          GoRoute(
            path: '/nyamnyam',
            builder: (context, state) => const NyamNyamScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // 정류장 상세 페이지 (Shell 밖에 배치하여 하단 탭바 숨김)
      GoRoute(
        path: '/stops/:id',
        builder: (context, state) => const StopDetailScreen(),
      ),
      // 노선 상세 페이지 (Shell 밖에 배치하여 하단 탭바 숨김)
      GoRoute(
        path: '/routes/:lineid',
        builder: (context, state) => const RouteDetailScreen(),
      ),
      // 웹뷰 페이지 (Shell 밖에 배치하여 독립적인 화면으로 표시)
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WebViewScreen(
            url: extra?['url'] as String? ?? '',
            title: extra?['title'] as String? ?? '웹페이지',
            returnPath: extra?['returnPath'] as String?,
          );
        },
      ),
    ],
  );
});
