class BusArrival {
  final String routeId;
  final String routeName;
  final int arrivalTime; // 도착 예정 시간 (초)
  final String arrivalMessage; // "곧 도착", "2분 후" 등
  final bool isLowFloor; // 저상버스 여부
  final String stopName; // 정류장명
  final String arsno; // ARS 번호

  const BusArrival({
    required this.routeId,
    required this.routeName,
    required this.arrivalTime,
    required this.arrivalMessage,
    this.isLowFloor = false,
    required this.stopName,
    required this.arsno,
  });

  factory BusArrival.fromApiJson(Map<String, dynamic> json) {
    // API 응답에서 도착 시간 계산
    final arrivalTime = _parseArrivalTime(json);
    final arrivalMessage = _formatArrivalMessage(arrivalTime);

    return BusArrival(
      routeId: json['ROUTE_ID'] ?? json['routeId'] ?? '',
      routeName: json['ROUTE_NAME'] ?? json['routeName'] ?? '',
      arrivalTime: arrivalTime,
      arrivalMessage: arrivalMessage,
      isLowFloor: (json['LOW_PLATE_YN'] ?? json['lowPlateYn'] ?? 'N') == 'Y',
      stopName: json['STOP_NAME'] ?? json['stopName'] ?? '',
      arsno: json['ARS_NO'] ?? json['arsno'] ?? '',
    );
  }

  // API 응답에서 도착 시간 파싱
  static int _parseArrivalTime(Map<String, dynamic> json) {
    final arrivalTime = json['ARRIVAL_TIME'] ?? json['arrivalTime'];
    if (arrivalTime == null) return 0;

    // "곧 도착"인 경우
    if (arrivalTime == '곧 도착') return 0;

    // 숫자로 파싱 시도
    final timeStr = arrivalTime.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(timeStr) ?? 0;
  }

  // 도착 시간을 메시지로 포맷
  static String _formatArrivalMessage(int arrivalTime) {
    if (arrivalTime == 0) return '곧 도착';
    if (arrivalTime < 60) return '${arrivalTime}초 후';
    if (arrivalTime < 3600) return '${(arrivalTime / 60).round()}분 후';
    return '${(arrivalTime / 3600).round()}시간 후';
  }
}
