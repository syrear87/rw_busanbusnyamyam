import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizeOption {
  defaultSize, // 기본
  plus3, // +3 (약 1.15배)
  plus5, // +5 (약 1.3배)
}

extension FontSizeOptionExtension on FontSizeOption {
  double get textScaleFactor {
    switch (this) {
      case FontSizeOption.defaultSize:
        return 1.0;
      case FontSizeOption.plus3:
        return 1.15; // +3 정도의 느낌
      case FontSizeOption.plus5:
        return 1.3; // +5 정도의 느낌
    }
  }

  String get label {
    switch (this) {
      case FontSizeOption.defaultSize:
        return '기본';
      case FontSizeOption.plus3:
        return '+3';
      case FontSizeOption.plus5:
        return '+5';
    }
  }
}

class FontSizeNotifier extends StateNotifier<FontSizeOption> {
  FontSizeNotifier() : super(FontSizeOption.defaultSize) {
    _loadFontSize();
  }

  static const _key = 'font_size_option';

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    if (index >= 0 && index < FontSizeOption.values.length) {
      state = FontSizeOption.values[index];
    }
  }

  Future<void> setFontSize(FontSizeOption option) async {
    state = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, option.index);
  }
}

final fontSizeProvider =
    StateNotifierProvider<FontSizeNotifier, FontSizeOption>((ref) {
      return FontSizeNotifier();
    });
