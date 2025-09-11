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

    // ARS번호가 비어있으면 목업 데이터 반환
    if (arsno.isEmpty) {
      print('⚠️ ARS번호가 비어있음, 목업 데이터 사용');
      return _getMockArrivals(arsno);
    }

    // BIS API 호출
    final arrivals = await BisApi.fetchArrivalsByArsNo(arsno);

    print('📊 BIS API 응답 - 정류장 $arsno: ${arrivals.length}개 도착정보');

    for (int i = 0; i < arrivals.length; i++) {
      final arrival = arrivals[i];
      print('  [$i] 노선ID: ${arrival.lineid}, 노선번호: ${arrival.lineno}');
      print('      예상시간1: ${arrival.predict1}, 예상시간2: ${arrival.predict2}');
    }

    if (arrivals.isEmpty) {
      print('⚠️ API 데이터 없음, 목업 데이터 사용');
      return _getMockArrivals(arsno);
    }

    // BIS Arrival을 BusArrival로 변환
    final convertedArrivals = arrivals.map((arrival) {
      final parsedTime = _parseArrivalTime(arrival.predict1);
      final formattedMessage = _formatArrivalMessage(arrival.predict1);

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
      );
    }).toList();

    print('✅ 최종 변환 완료: ${convertedArrivals.length}개');
    return convertedArrivals;
  } catch (e) {
    print('❌ 도착정보 API 호출 실패, 목업 데이터 사용: $e');
    // API 호출 실패 시 목업 데이터 반환
    return _getMockArrivals(arsno);
  }
});

// 목업 도착 정보 생성
List<BusArrival> _getMockArrivals(String arsno) {
  // 정류장별로 다른 목업 데이터 반환
  final mockData = {
    '1001': [
      BusArrival(
        routeId: '1001',
        routeName: '1001번',
        arrivalTime: 120,
        arrivalMessage: '2분 후',
        isLowFloor: true,
        stopName: '부산역',
        arsno: '1001',
      ),
      BusArrival(
        routeId: '1002',
        routeName: '1002번',
        arrivalTime: 300,
        arrivalMessage: '5분 후',
        isLowFloor: false,
        stopName: '부산역',
        arsno: '1001',
      ),
    ],
    '1002': [
      BusArrival(
        routeId: '2001',
        routeName: '2001번',
        arrivalTime: 60,
        arrivalMessage: '1분 후',
        isLowFloor: true,
        stopName: '서면역',
        arsno: '1002',
      ),
      BusArrival(
        routeId: '2002',
        routeName: '2002번',
        arrivalTime: 180,
        arrivalMessage: '3분 후',
        isLowFloor: false,
        stopName: '서면역',
        arsno: '1002',
      ),
    ],
  };

  return mockData[arsno] ??
      [
        BusArrival(
          routeId: '9999',
          routeName: '9999번',
          arrivalTime: 240,
          arrivalMessage: '4분 후',
          isLowFloor: false,
          stopName: '기본정류장',
          arsno: arsno,
        ),
      ];
}

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
  if (predictTime == null || predictTime.isEmpty) return '정보 없음';

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
