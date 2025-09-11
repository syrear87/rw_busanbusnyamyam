import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends StateNotifier<AsyncValue<Position?>> {
  LocationController() : super(const AsyncValue.loading());

  Future<void> requestOnce() async {
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        state = const AsyncValue.data(null);
        return;
      }

      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        state = const AsyncValue.data(null);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = AsyncValue.data(pos);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() => requestOnce();
}

final locationController =
    StateNotifierProvider<LocationController, AsyncValue<Position?>>(
      (_) => LocationController(),
    );
