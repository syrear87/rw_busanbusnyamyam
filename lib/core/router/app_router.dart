import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/stops/presentation/stops_screen.dart';
import '../../features/stops/presentation/stop_detail_screen.dart';
import '../../features/routes/presentation/routes_screen.dart';
import '../../features/nyamnyam/presentation/nyamnyam_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
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
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final stopId = state.pathParameters['id']!;
                  return StopDetailScreen(stopId: stopId);
                },
              ),
            ],
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
    ],
  );
});
