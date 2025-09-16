import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import 'place_model.dart';

class PlaceCache {
  static const String _keyPrefix = 'nyam_cache_';
  static const int _ttlMinutes = 10;

  final Map<String, _CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Result<List<Place>>?> get(PlaceSearchParams params) async {
    final key = params.cacheKey;
    final now = DateTime.now();

    // Check memory cache first
    final memEntry = _memoryCache[key];
    if (memEntry != null && now.difference(memEntry.timestamp).inMinutes < _ttlMinutes) {
      dev.log('Cache HIT (memory): $key');
      return Success(memEntry.places, isFromCache: true);
    }

    // Check SharedPreferences
    await _ensurePrefs();
    final prefKey = '$_keyPrefix$key';
    final cachedJson = _prefs!.getString(prefKey);

    if (cachedJson != null) {
      try {
        final data = json.decode(cachedJson) as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

        if (now.difference(timestamp).inMinutes < _ttlMinutes) {
          final places = (data['places'] as List<dynamic>)
              .map((p) => Place.fromJson(p))
              .toList();

          // Update memory cache
          _memoryCache[key] = _CacheEntry(places, timestamp);

          dev.log('Cache HIT (disk): $key');
          return Success(places, isFromCache: true);
        } else {
          // Remove expired entry
          _prefs!.remove(prefKey);
        }
      } catch (e) {
        dev.log('Cache parse error: $e');
        _prefs!.remove(prefKey);
      }
    }

    dev.log('Cache MISS: $key');
    return null;
  }

  Future<void> set(PlaceSearchParams params, List<Place> places) async {
    final key = params.cacheKey;
    final now = DateTime.now();

    // Update memory cache
    _memoryCache[key] = _CacheEntry(places, now);

    // Update SharedPreferences
    await _ensurePrefs();
    final prefKey = '$_keyPrefix$key';
    final data = {
      'timestamp': now.millisecondsSinceEpoch,
      'places': places.map((p) => p.toJson()).toList(),
    };

    await _prefs!.setString(prefKey, json.encode(data));
    dev.log('Cache SET: $key (${places.length} places)');
  }

  Future<Result<List<Place>>?> getLastSuccess() async {
    await _ensurePrefs();
    final keys = _prefs!.getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();

    if (keys.isEmpty) return null;

    // Find most recent cache entry
    String? latestKey;
    DateTime? latestTime;

    for (final key in keys) {
      try {
        final data = json.decode(_prefs!.getString(key)!) as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

        if (latestTime == null || timestamp.isAfter(latestTime)) {
          latestTime = timestamp;
          latestKey = key;
        }
      } catch (e) {
        _prefs!.remove(key);
      }
    }

    if (latestKey != null) {
      try {
        final data = json.decode(_prefs!.getString(latestKey)!) as Map<String, dynamic>;
        final places = (data['places'] as List<dynamic>)
            .map((p) => Place.fromJson(p))
            .toList();

        dev.log('Cache FALLBACK: $latestKey (${places.length} places)');
        return Success(places, isFromCache: true);
      } catch (e) {
        _prefs!.remove(latestKey);
      }
    }

    return null;
  }

  void clearMemory() {
    _memoryCache.clear();
    dev.log('Memory cache cleared');
  }

  Future<void> clearAll() async {
    clearMemory();
    await _ensurePrefs();
    final keys = _prefs!.getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();

    for (final key in keys) {
      await _prefs!.remove(key);
    }
    dev.log('All cache cleared');
  }
}

class _CacheEntry {
  final List<Place> places;
  final DateTime timestamp;

  _CacheEntry(this.places, this.timestamp);
}