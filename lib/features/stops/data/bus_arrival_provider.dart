import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'bus_arrival_model.dart';
import '../../../../core/network/bis_api.dart';
import '../../../../core/network/bis_models.dart';

// 정류장별 도착 정보 provider
final busArrivalProvider = FutureProvider.family<List<BusArrival>, String>((
  ref,
  arsno,
) async {
  try {
    print('🚌 BIS API 호출 시작 - ARS번호: $arsno');

    // ARS번호가 비어있으면 빈 리스트 반환
    if (arsno.isEmpty) {
      print('⚠️ ARS번호가 비어있음, 빈 리스트 반환');
      return [];
    }

    // BIS API 호출
    final arrivals = await BisApi.fetchArrivalsByArsNo(arsno);

    print('📊 BIS API 응답 - 정류장 $arsno: ${arrivals.length}개 도착정보');

    for (int i = 0; i < arrivals.length; i++) {
      final arrival = arrivals[i];
      print('  [$i] 노선ID: ${arrival.lineid}, 노선번호: ${arrival.lineno}');
      print('      예상시간1: ${arrival.min1}, 예상시간2: ${arrival.min2}');
    }

    if (arrivals.isEmpty) {
      print('⚠️ API 데이터 없음, 빈 리스트 반환');
      return [];
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

          print(
            '🔄 변환: ${arrival.lineno} -> 시간: $parsedTime초, 메시지: $formattedMessage',
          );

          return BusArrival(
            routeId: arrival.lineid,
            routeName: arrival.lineno,
            arrivalTime: parsedTime,
            arrivalMessage: formattedMessage,
            isLowFloor: false, // BIS API에서 저상버스 정보가 없음
            stopName: '', // 정류장명은 별도로 가져와야 함
            arsno: arsno,
            routeColor: BusArrival.getRouteColor(arrival.lineno), // 버스 번호에 따른 색깔
          );
        }).toList();

    print('✅ 최종 변환 완료: ${convertedArrivals.length}개');
    return convertedArrivals;
  } catch (e) {
    print('❌ 도착정보 API 호출 실패, 빈 리스트 반환: $e');
    // API 호출 실패 시 빈 리스트 반환
    return [];
  }
});


// BIS API 도착시간 파싱 헬퍼
int _parseArrivalTime(String? predictTime) {
  if (predictTime == null || predictTime.isEmpty) return 0;

  // "곧 도착"인 경우
  if (predictTime == '곧 도착') return 0;

  // 숫자로 파싱 시도
  final timeStr = predictTime.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(timeStr) ?? 0;
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
