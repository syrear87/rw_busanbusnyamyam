import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationState {
  final double? lat;
  final double? lon;
  final LocationPermission permission;
  final bool serviceEnabled;
  final String? error;
  final DateTime? lastUpdated;

  const LocationState({
    this.lat,
    this.lon,
    required this.permission,
    required this.serviceEnabled,
    this.error,
    this.lastUpdated,
  });

  LocationState copyWith({
    double? lat,
    double? lon,
    LocationPermission? permission,
    bool? serviceEnabled,
    String? error,
    DateTime? lastUpdated,
  }) {
    return LocationState(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      permission: permission ?? this.permission,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasValidLocation => lat != null && lon != null;
  bool get hasPermission =>
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
  bool get canUseLocation =>
      hasPermission && serviceEnabled && hasValidLocation;
}

class LocationNotifier extends StateNotifier<LocationState> {
  static const String _keyLastLat = 'last_lat';
  static const String _keyLastLon = 'last_lon';
  static const double _defaultLat = 35.1796; // Busan City Hall
  static const double _defaultLon = 129.0756;

  LocationNotifier()
    : super(
        const LocationState(
          permission: LocationPermission.denied,
          serviceEnabled: false,
        ),
      ) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Check service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      state = state.copyWith(
        serviceEnabled: serviceEnabled,
        permission: permission,
      );

      // Load last known location from preferences
      await _loadLastKnownLocation();

      // Try to get current location if possible
      if (serviceEnabled && state.hasPermission) {
        await _getCurrentLocation();
      }

      dev.log(
        'Location initialized: service=$serviceEnabled, permission=$permission',
      );
    } catch (e) {
      dev.log('Location initialization error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      state = state.copyWith(permission: permission, error: null);

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(error: '위치 권한이 거부되었습니다. 지도 중심 기준으로 검색합니다.');
        dev.log('Location permission denied');
      } else {
        await _getCurrentLocation();
      }
    } catch (e) {
      dev.log('Permission request error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Try getLastKnownPosition first (faster)
      Position? position = await Geolocator.getLastKnownPosition();

      // If no last known position, get current position with timeout
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      }

      final now = DateTime.now();

      state = state.copyWith(
        lat: position.latitude,
        lon: position.longitude,
        lastUpdated: now,
        error: null,
      );

      // Save to preferences for future use
      await _saveLastKnownLocation(position.latitude, position.longitude);

      dev.log('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      dev.log('Get current location error: $e');

      // Use last known location if available
      if (!state.hasValidLocation) {
        await _loadLastKnownLocation();
      }

      // If still no location, use default
      if (!state.hasValidLocation) {
        state = state.copyWith(
          lat: _defaultLat,
          lon: _defaultLon,
          error: '현재 위치를 가져올 수 없어 기본 위치를 사용합니다.',
        );
      } else {
        state = state.copyWith(error: '현재 위치를 가져올 수 없어 마지막 위치를 사용합니다.');
      }
    }
  }

  Future<void> _loadLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLat = prefs.getDouble(_keyLastLat);
      final lastLon = prefs.getDouble(_keyLastLon);

      if (lastLat != null && lastLon != null) {
        state = state.copyWith(lat: lastLat, lon: lastLon);
        dev.log('Loaded last known location: $lastLat, $lastLon');
      }
    } catch (e) {
      dev.log('Load last location error: $e');
    }
  }

  Future<void> _saveLastKnownLocation(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyLastLat, lat);
      await prefs.setDouble(_keyLastLon, lon);
    } catch (e) {
      dev.log('Save last location error: $e');
    }
  }

  Future<void> refresh() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    state = state.copyWith(serviceEnabled: serviceEnabled, error: null);

    if (serviceEnabled && state.hasPermission) {
      await _getCurrentLocation();
    } else if (!state.hasPermission) {
      await requestPermission();
    } else {
      state = state.copyWith(error: '위치 서비스가 비활성화되어 있습니다.');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);
