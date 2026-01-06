import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bus_arrival_model.dart';
import '../../../../core/network/bis_api.dart';
import '../../../../core/network/bis_models.dart';
import '../../../../core/cache/cache_service.dart';

// 정류장별 도착 정보 StateNotifier
class BusArrivalNotifier extends StateNotifier<AsyncValue<List<BusArrival>>> {
  BusArrivalNotifier(this.arsno) : super(const AsyncValue.loading()) {
    _loadArrivals();
  }

  final String arsno;

  // 캐시 서비스 인스턴스
  final CacheService _cacheService = CacheService();

  // API에서 도착 정보 로드 (캐시 우선)
  Future<void> _loadArrivals() async {
    try {
      print('🚌 도착 정보 조회 시작 (캐시 우선) - ARS번호: $arsno');

      // ARS번호가 비어있으면 빈 리스트 반환
      if (arsno.isEmpty) {
        print('⚠️ ARS번호가 비어있음, 빈 리스트 반환');
        state = const AsyncValue.data([]);
        return;
      }

      // 캐시 서비스를 통한 도착 정보 조회 (캐시 우선, API 백업)
      final arrivals = await _cacheService.getArrivals(arsno);

      print('📊 도착 정보 조회 완료 - 정류장 $arsno: ${arrivals.length}개 도착정보');

      for (int i = 0; i < arrivals.length; i++) {
        final arrival = arrivals[i];
        print('  [$i] 노선ID: ${arrival.lineid}, 노선번호: ${arrival.lineno}');
        print('      버스타입: ${arrival.bustype}');
        print('      예상시간1: ${arrival.min1}, 예상시간2: ${arrival.min2}');
      }

      if (arrivals.isEmpty) {
        print('⚠️ 도착 정보 없음, 빈 리스트 반환');
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
      print('❌ 도착정보 조회 실패, 빈 리스트 반환: $e');
      // 조회 실패 시 빈 리스트 반환
      state = const AsyncValue.data([]);
    }
  }

  // 수동으로 새로고침 (캐시 우선)
  Future<void> refresh() async {
    await _loadArrivals();
  }

  // 강제 새로고침 (API만 호출)
  Future<void> forceRefresh() async {
    try {
      print('🔄 도착 정보 강제 새로고침 - ARS번호: $arsno');

      if (arsno.isEmpty) {
        print('⚠️ ARS번호가 비어있음, 빈 리스트 반환');
        state = const AsyncValue.data([]);
        return;
      }

      // 강제 새로고침 (캐시 무시하고 API만 호출)
      final arrivals = await _cacheService.refreshArrivals(arsno);

      print('📊 강제 새로고침 완료 - 정류장 $arsno: ${arrivals.length}개 도착정보');

      if (arrivals.isEmpty) {
        print('⚠️ 도착 정보 없음, 빈 리스트 반환');
        state = const AsyncValue.data([]);
        return;
      }

      // BIS Arrival을 BusArrival로 변환
      final convertedArrivals = arrivals
          .map(
            (arrival) => BusArrival(
              arsno: arsno,
              bstopid: '',
              nodenm: arrival.nodenm,
              gpsx: 0.0,
              gpsy: 0.0,
              lineno: arrival.lineno,
              lineid: arrival.lineid,
              bstopidx: 0,
              bustype: arrival.bustype,
              carno1: '',
              carno2: '',
              min1: arrival.min1,
              min2: arrival.min2,
              station1: arrival.station1,
              station2: arrival.station2,
              lowplate1: '',
              lowplate2: '',
              seat1: '',
              seat2: '',
            ),
          )
          .toList();

      print('✅ 강제 새로고침 완료: ${convertedArrivals.length}개');
      state = AsyncValue.data(convertedArrivals);
    } catch (e) {
      print('❌ 강제 새로고침 실패: $e');
      // 강제 새로고침 실패 시 기존 데이터 유지
    }
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
