import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bus_arrival_model.dart';
import '../../../../core/network/bis_api.dart';
import '../../../../core/network/bis_models.dart';

// 정류장별 도착 정보 StateNotifier
class BusArrivalNotifier extends StateNotifier<AsyncValue<List<BusArrival>>> {
  BusArrivalNotifier(this.arsno) : super(const AsyncValue.loading()) {
    _loadArrivals();
    _startCountdownTimer();
  }

  final String arsno;
  Timer? _countdownTimer;

  // API에서 도착 정보 로드
  Future<void> _loadArrivals() async {
    try {
      print('🚌 BIS API 호출 시작 - ARS번호: $arsno');

      // ARS번호가 비어있으면 빈 리스트 반환
      if (arsno.isEmpty) {
        print('⚠️ ARS번호가 비어있음, 빈 리스트 반환');
        state = const AsyncValue.data([]);
        return;
      }

      // BIS API 호출
      final arrivals = await BisApi.fetchArrivalsByArsNo(arsno);

      print('📊 BIS API 응답 - 정류장 $arsno: ${arrivals.length}개 도착정보');

      for (int i = 0; i < arrivals.length; i++) {
        final arrival = arrivals[i];
        print('  [$i] 노선ID: ${arrival.lineid}, 노선번호: ${arrival.lineno}');
        print('      버스타입: ${arrival.bustype}');
        print('      예상시간1: ${arrival.min1}, 예상시간2: ${arrival.min2}');
      }

      if (arrivals.isEmpty) {
        print('⚠️ API 데이터 없음, 빈 리스트 반환');
        state = const AsyncValue.data([]);
        return;
      }

      // BIS Arrival을 BusArrival로 변환 (도착 정보가 있는 것만)
      final convertedArrivals = arrivals
          .where((arrival) {
            final parsedTime = _parseArrivalTime(arrival.min1);
            final formattedMessage = _formatArrivalMessage(arrival.min1);
            // 도착 정보가 있는 버스만 포함 (빈 메시지가 아닌 것)
            return formattedMessage.isNotEmpty;
          })
          .map((arrival) {
            final parsedTime = _parseArrivalTime(arrival.min1);
            final formattedMessage = _formatArrivalMessage(arrival.min1);

            return BusArrival(
              routeId: arrival.lineid,
              routeName: arrival.lineno,
              arrivalTime: parsedTime,
              arrivalMessage: formattedMessage,
              isLowFloor: false, // BIS API에서 저상버스 정보가 없음
              stopName: '', // 정류장명은 별도로 가져와야 함
              arsno: arsno,
              routeColor: BusArrival.getRouteColor(arrival.lineno, arrival.bustype), // 버스 번호와 타입에 따른 색깔
              station1: arrival.station1.isEmpty ? null : arrival.station1, // 몇 정거장 전 정보
              createdAt: DateTime.now(), // 현재 시간으로 설정
            );
          }).toList();

      print('✅ 최종 변환 완료: ${convertedArrivals.length}개');
      state = AsyncValue.data(convertedArrivals);
    } catch (e) {
      print('❌ 도착정보 API 호출 실패, 빈 리스트 반환: $e');
      // API 호출 실패 시 빈 리스트 반환
      state = const AsyncValue.data([]);
    }
  }

  // 1초마다 카운트다운 업데이트
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  // 카운트다운 업데이트 및 도착한 버스 제거
  void _updateCountdown() {
    state.whenData((arrivals) {
      if (arrivals.isEmpty) return;

      // 도착하지 않은 버스만 필터링
      final remainingArrivals = arrivals.where((arrival) => !arrival.hasArrived).toList();
      
      // 리스트가 변경되었으면 상태 업데이트
      if (remainingArrivals.length != arrivals.length) {
        print('🚌 도착한 버스 제거: ${arrivals.length - remainingArrivals.length}개');
        state = AsyncValue.data(remainingArrivals);
      }
    });
  }

  // 수동으로 새로고침
  Future<void> refresh() async {
    await _loadArrivals();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

// 정류장별 도착 정보 provider
final busArrivalProvider = StateNotifierProvider.family<BusArrivalNotifier, AsyncValue<List<BusArrival>>, String>(
  (ref, arsno) => BusArrivalNotifier(arsno),
);


// BIS API 도착시간 파싱 헬퍼 (BIS API의 min1은 항상 분 단위)
int _parseArrivalTime(String? predictTime) {
  if (predictTime == null || predictTime.isEmpty) return 0;

  // "곧 도착"인 경우
  if (predictTime == '곧 도착') return 0;

  // 숫자로 파싱 시도 (BIS API의 min1은 분 단위)
  final timeStr = predictTime.replaceAll(RegExp(r'[^0-9]'), '');
  final minutes = int.tryParse(timeStr) ?? 0;
  
  // 분을 초로 변환
  return minutes * 60;
}

// 도착시간을 메시지로 포맷
String _formatArrivalMessage(String? predictTime) {
  if (predictTime == null || predictTime.isEmpty) return '';

  // "곧 도착"인 경우
  if (predictTime == '곧 도착') return '곧 도착';

  // 숫자 추출
  final timeStr = predictTime.replaceAll(RegExp(r'[^0-9]'), '');
  final time = int.tryParse(timeStr);

  if (time == null) return predictTime; // 원본 반환

  if (time < 60) return '${time}초 후';
  if (time < 3600) return '${(time / 60).round()}분 후';
  return '${(time / 3600).round()}시간 후';
}
