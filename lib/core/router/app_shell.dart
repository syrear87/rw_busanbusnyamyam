import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    switch (location) {
      case '/home':
        currentIndex = 0;
        break;
      case '/stops':
        currentIndex = 1;
        break;
      case '/routes':
        currentIndex = 2;
        break;
      case '/nyamnyam':
        currentIndex = 3;
        break;
      case '/settings':
        currentIndex = 4;
        break;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/stops');
              break;
            case 2:
              context.go('/routes');
              break;
            case 3:
              context.go('/nyamnyam');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_filled),
            selectedIcon: Icon(Icons.directions_bus_filled),
            label: '정류장',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route),
            selectedIcon: Icon(Icons.alt_route),
            label: '노선',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            selectedIcon: Icon(Icons.restaurant),
            label: '냠냠',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
