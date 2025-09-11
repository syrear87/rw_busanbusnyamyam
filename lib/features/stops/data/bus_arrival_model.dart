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
  final DateTime createdAt; // 생성 시간 (카운트다운 계산용)
  final String? station1; // 몇 정거장 전 정보

  BusArrival({
    required this.routeId,
    required this.routeName,
    required this.arrivalTime,
    required this.arrivalMessage,
    this.isLowFloor = false,
    required this.stopName,
    required this.arsno,
    required this.routeColor,
    this.station1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  // 현재 남은 시간 계산 (실시간 카운트다운)
  int get remainingTime {
    if (arrivalTime == 0) return 0; // "곧 도착"인 경우
    
    final now = DateTime.now();
    final elapsed = now.difference(createdAt).inSeconds;
    final remaining = arrivalTime - elapsed;
    
    return remaining > 0 ? remaining : 0;
  }

  // 현재 남은 시간을 메시지로 포맷 (새로운 형식: "2분 [4전]")
  String get currentArrivalMessage {
    final remaining = remainingTime;
    final stationInfo = (station1 != null && station1!.isNotEmpty && station1 != 'null') ? station1! : '0';
    
    if (remaining == 0) return '곧도착 [$stationInfo전]';
    if (remaining < 60) return '${remaining}초 [$stationInfo전]';
    if (remaining < 3600) return '${(remaining / 60).round()}분 [$stationInfo전]';
    return '${(remaining / 3600).round()}시간 [$stationInfo전]';
  }

  // 버스가 도착했는지 확인 (0초 이하)
  bool get hasArrived => remainingTime <= 0;

  factory BusArrival.fromApiJson(Map<String, dynamic> json) {
    // API 응답에서 도착 시간 계산
    final arrivalTime = _parseArrivalTime(json);
    final arrivalMessage = _formatArrivalMessage(arrivalTime);

    final routeName = json['ROUTE_NAME'] ?? json['routeName'] ?? '';
    final busType = json['BUSTYPE'] ?? json['bustype'] ?? '';
    final station1 = (json['STATION1'] ?? json['station1'] ?? '').toString();
    final station1Value = station1.isEmpty ? null : station1;
    
    return BusArrival(
      routeId: json['ROUTE_ID'] ?? json['routeId'] ?? '',
      routeName: routeName,
      arrivalTime: arrivalTime,
      arrivalMessage: arrivalMessage,
      isLowFloor: (json['LOW_PLATE_YN'] ?? json['lowPlateYn'] ?? 'N') == 'Y',
      stopName: json['STOP_NAME'] ?? json['stopName'] ?? '',
      arsno: json['ARS_NO'] ?? json['arsno'] ?? '',
      routeColor: BusArrival.getRouteColor(routeName, busType),
      station1: station1Value,
      createdAt: DateTime.now(), // 현재 시간으로 설정
    );
  }

  // API 응답에서 도착 시간 파싱 (BIS API의 min1은 항상 분 단위)
  static int _parseArrivalTime(Map<String, dynamic> json) {
    final arrivalTime = json['ARRIVAL_TIME'] ?? json['arrivalTime'];
    if (arrivalTime == null) return 0;

    // "곧 도착"인 경우
    if (arrivalTime == '곧 도착') return 0;

    // 숫자로 파싱 시도 (BIS API의 min1은 분 단위)
    final timeStr = arrivalTime.toString().replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(timeStr) ?? 0;
    
    // 분을 초로 변환
    return minutes * 60;
  }

  // 도착 시간을 메시지로 포맷
  static String _formatArrivalMessage(int arrivalTime) {
    if (arrivalTime == 0) return '곧 도착';
    if (arrivalTime < 60) return '${arrivalTime}초 후';
    if (arrivalTime < 3600) return '${(arrivalTime / 60).round()}분 후';
    return '${(arrivalTime / 3600).round()}시간 후';
  }

  // 버스 타입에 따른 색깔 매핑
  static Color getRouteColor(String routeName, String busType) {
    // 빈 문자열이나 null 체크
    if (routeName.isEmpty) return const Color(0xFF7BB074); // 앱 포인트 컬러 폴백
    
    // 심야 버스 체크 (노선명에 "심야" 포함)
    if (routeName.contains('심야')) {
      return const Color(0xFFFF6B35); // 찐한 주황색
    }
    
    // 버스 타입에 따른 색상 적용
    switch (busType) {
      case '일반버스':
        return const Color(0xFF2D6CDF); // 파란색 계열
      case '급행버스':
      case '좌석버스':
      case '좌석·급행버스':
        return const Color(0xFF7B1FA2); // 자주/바이올렛 계열
      case '마을버스':
        return const Color(0xFF2E7D32); // 초록색 계열
      default:
        return const Color(0xFF7BB074); // 앱 포인트 컬러 (그 외 모든 타입)
    }
  }
}
