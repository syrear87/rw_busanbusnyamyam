import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bus_arrival_model.dart';
import '../../../../core/network/bis_api.dart';
import '../../../../core/network/bis_models.dart';

// 정류장별 도착 정보 StateNotifier
class BusArrivalNotifier extends StateNotifier<AsyncValue<List<BusArrival>>> {
  BusArrivalNotifier(this.arsno) : super(const AsyncValue.loading()) {
    _loadArrivals();
  }

  final String arsno;

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

      // BIS Arrival을 BusArrival로 변환
      final convertedArrivals = arrivals
          .map(
            (arrival) => BusArrival(
              arsno: arsno,
              bstopid: '', // ARS 기반 호출이므로 bstopid는 비어있음
              nodenm: arrival.nodenm,
              gpsx: 0.0, // ARS 기반 호출이므로 좌표는 비어있음
              gpsy: 0.0,
              lineno: arrival.lineno,
              lineid: arrival.lineid,
              bstopidx: 0, // ARS 기반 호출이므로 순번은 비어있음
              bustype: arrival.bustype,
              carno1: '', // BIS API에서 차량번호를 제공하지 않음
              carno2: '',
              min1: arrival.min1,
              min2: arrival.min2,
              station1: arrival.station1,
              station2: arrival.station2,
              lowplate1: '', // BIS API에서 저상버스 정보를 제공하지 않음
              lowplate2: '',
              seat1: '', // BIS API에서 좌석 정보를 제공하지 않음
              seat2: '',
            ),
          )
          .toList();

      print('✅ 최종 변환 완료: ${convertedArrivals.length}개');
      state = AsyncValue.data(convertedArrivals);
    } catch (e) {
      print('❌ 도착정보 API 호출 실패, 빈 리스트 반환: $e');
      // API 호출 실패 시 빈 리스트 반환
      state = const AsyncValue.data([]);
    }
  }

  // 수동으로 새로고침
  Future<void> refresh() async {
    await _loadArrivals();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// 정류장별 도착 정보 provider
final busArrivalProvider =
    StateNotifierProvider.family<
      BusArrivalNotifier,
      AsyncValue<List<BusArrival>>,
      String
    >((ref, arsno) => BusArrivalNotifier(arsno));
