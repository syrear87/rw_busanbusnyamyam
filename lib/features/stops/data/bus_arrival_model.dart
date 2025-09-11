import 'package:flutter/material.dart';

class BusArrival {
  final String routeId;
  final String routeName;
  final int arrivalTime; // 도착 예정 시간 (초)
  final String arrivalMessage; // "곧 도착", "2분 후" 등
  final bool isLowFloor; // 저상버스 여부
  final String stopName; // 정류장명
  final String arsno; // ARS 번호
  final Color routeColor; // 버스 노선 색깔

  const BusArrival({
    required this.routeId,
    required this.routeName,
    required this.arrivalTime,
    required this.arrivalMessage,
    this.isLowFloor = false,
    required this.stopName,
    required this.arsno,
    required this.routeColor,
  });

  factory BusArrival.fromApiJson(Map<String, dynamic> json) {
    // API 응답에서 도착 시간 계산
    final arrivalTime = _parseArrivalTime(json);
    final arrivalMessage = _formatArrivalMessage(arrivalTime);

    final routeName = json['ROUTE_NAME'] ?? json['routeName'] ?? '';
    
    return BusArrival(
      routeId: json['ROUTE_ID'] ?? json['routeId'] ?? '',
      routeName: routeName,
      arrivalTime: arrivalTime,
      arrivalMessage: arrivalMessage,
      isLowFloor: (json['LOW_PLATE_YN'] ?? json['lowPlateYn'] ?? 'N') == 'Y',
      stopName: json['STOP_NAME'] ?? json['stopName'] ?? '',
      arsno: json['ARS_NO'] ?? json['arsno'] ?? '',
      routeColor: BusArrival.getRouteColor(routeName),
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

  // 버스 번호에 따른 색깔 매핑 (부산 버스 기준)
  static Color getRouteColor(String routeName) {
    // 빈 문자열이나 null 체크
    if (routeName.isEmpty) return Colors.grey;
    
    // 버스 번호에서 숫자만 추출
    final numberMatch = RegExp(r'\d+').firstMatch(routeName);
    if (numberMatch == null) return Colors.grey;
    
    final number = int.tryParse(numberMatch.group(0) ?? '0') ?? 0;
    
    // 부산 버스 색깔 체계 (일반적인 기준)
    if (number >= 1 && number <= 99) {
      return Colors.blue; // 시내버스 (1-99번)
    } else if (number >= 100 && number <= 199) {
      return Colors.red; // 간선버스 (100-199번)
    } else if (number >= 200 && number <= 299) {
      return Colors.green; // 지선버스 (200-299번)
    } else if (number >= 300 && number <= 399) {
      return Colors.orange; // 순환버스 (300-399번)
    } else if (number >= 1000 && number <= 1999) {
      return Colors.purple; // 광역버스 (1000-1999번)
    } else if (number >= 2000 && number <= 2999) {
      return Colors.teal; // 마을버스 (2000-2999번)
    } else {
      return Colors.grey; // 기타
    }
  }
}
