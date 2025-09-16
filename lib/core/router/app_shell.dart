import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _previousIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int newIndex = 0;
    switch (location) {
      case '/home':
        newIndex = 0;
        break;
      case '/stops':
        newIndex = 1;
        break;
      case '/routes':
        newIndex = 2;
        break;
      case '/nyamnyam':
        newIndex = 3;
        break;
      case '/settings':
        newIndex = 4;
        break;
    }

    // 탭 인덱스가 변경되었을 때 애니메이션 실행
    if (newIndex != _currentIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
      
      // 슬라이드 방향 결정 (인덱스가 작아지면 왼쪽으로, 커지면 오른쪽으로)
      final slideDirection = _currentIndex < _previousIndex ? -1.0 : 1.0;
      
      _slideAnimation = Tween<Offset>(
        begin: Offset(slideDirection, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      _animationController.forward(from: 0);
    }

    return Scaffold(
      body: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
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
