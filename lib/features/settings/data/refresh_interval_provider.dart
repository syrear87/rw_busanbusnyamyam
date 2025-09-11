import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RefreshInterval {
  fifteenSeconds('15초', 15),
  thirtySeconds('30초', 30),
  oneMinute('1분', 60);

  const RefreshInterval(this.displayName, this.seconds);

  final String displayName;
  final int seconds;
}

class RefreshIntervalNotifier extends StateNotifier<RefreshInterval> {
  RefreshIntervalNotifier() : super(RefreshInterval.thirtySeconds) {
    _loadFromPrefs();
  }

  static const String _key = 'refresh_interval';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 1; // 기본값: 30초
    state = RefreshInterval.values[index];
  }

  Future<void> setInterval(RefreshInterval interval) async {
    state = interval;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, interval.index);
  }
}

final refreshIntervalProvider =
    StateNotifierProvider<RefreshIntervalNotifier, RefreshInterval>(
      (ref) => RefreshIntervalNotifier(),
    );
