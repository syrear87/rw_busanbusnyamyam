import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends StateNotifier<AsyncValue<Position?>> {
  LocationController() : super(const AsyncValue.loading());

  /// 위치 권한을 처음부터 요청하는 메서드
  Future<void> requestLocationPermission() async {
    try {
      print('🚀 위치 권한 요청 시작');
      
      // 1. 위치 서비스 활성화 확인
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      print('🚀 위치 서비스 활성화: $serviceOn');
      
      if (!serviceOn) {
        print('🚀 위치 서비스가 비활성화됨 - 설정 열기');
        await Geolocator.openLocationSettings();
        state = const AsyncValue.data(null);
        return;
      }

      // 2. 권한 요청
      print('🚀 권한 요청 중...');
      final st = await Permission.locationWhenInUse.request();
      print('🚀 권한 요청 결과: $st');

      if (st.isGranted) {
        print('🚀 권한 허용됨 - 위치 정보 가져오기');
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('🚀 위치 정보 획득 성공: ${pos.latitude}, ${pos.longitude}');
        state = AsyncValue.data(pos);
      } else if (st.isPermanentlyDenied) {
        print('🚀 권한이 영구적으로 거부됨 - 설정 열기');
        await openAppSettings();
        state = const AsyncValue.data(null);
      } else {
        print('🚀 권한 거부됨');
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      print('🚀 위치 권한 요청 오류: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 현재 위치 정보 가져오기
  Future<void> _getCurrentLocation() async {
    try {
      print('🚀 위치 정보 가져오기 시작');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      print('🚀 위치 정보 획득 성공: ${position.latitude}, ${position.longitude}');
      state = AsyncValue.data(position);
    } catch (e) {
      print('🚀 위치 정보 가져오기 실패: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 권한 상태만 확인
  Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.locationWhenInUse.status;
  }

  /// 설정 페이지로 이동
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// 새로고침 (권한 재요청)
  Future<void> refresh() => requestLocationPermission();
}

final locationController =
    StateNotifierProvider<LocationController, AsyncValue<Position?>>(
      (_) => LocationController(),
    );
