class BusArrival {
  final String arsno; // ARS 번호(대중콜 안내번호)
  final String bstopid; // 정류장 ID(내부식별자)
  final String nodenm; // 정류장 명
  final double gpsx; // 경도
  final double gpsy; // 위도
  final String lineno; // 노선 번호(표시용)
  final String lineid; // 노선 ID(내부식별자)
  final int bstopidx; // 해당 노선에서 이 정류장의 순번
  final String bustype; // 버스 유형
  final String carno1; // 1번째 도착 예정 차량 번호
  final String carno2; // 2번째 도착 예정 차량 번호
  final String min1; // 1번째 도착까지 남은 시간(분)
  final String min2; // 2번째 도착까지 남은 시간(분)
  final String station1; // 1번째 도착 차량의 남은 정류장 수
  final String station2; // 2번째 도착 차량의 남은 정류장 수
  final String lowplate1; // 1번째 저상버스 여부
  final String lowplate2; // 2번째 저상버스 여부
  final String seat1; // 1번째 잔여좌석 수
  final String seat2; // 2번째 잔여좌석 수

  BusArrival({
    required this.arsno,
    required this.bstopid,
    required this.nodenm,
    required this.gpsx,
    required this.gpsy,
    required this.lineno,
    required this.lineid,
    required this.bstopidx,
    required this.bustype,
    required this.carno1,
    required this.carno2,
    required this.min1,
    required this.min2,
    required this.station1,
    required this.station2,
    required this.lowplate1,
    required this.lowplate2,
    required this.seat1,
    required this.seat2,
  });

  // min1에서 숫자만 추출 (예: "7초 후분" -> "7")
  String get min1Number {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(min1);
    return match?.group(0) ?? min1;
  }

  // min2에서 숫자만 추출
  String get min2Number {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(min2);
    return match?.group(0) ?? min2;
  }

  factory BusArrival.fromApiJson(Map<String, dynamic> json) {
    return BusArrival(
      arsno: json['ARS_NO'] ?? json['arsno'] ?? '',
      bstopid: json['BSTOP_ID'] ?? json['bstopid'] ?? '',
      nodenm: json['NODENM'] ?? json['nodenm'] ?? '',
      gpsx:
          double.tryParse((json['GPSX'] ?? json['gpsx'] ?? '0').toString()) ??
          0.0,
      gpsy:
          double.tryParse((json['GPSY'] ?? json['gpsy'] ?? '0').toString()) ??
          0.0,
      lineno: json['LINENO'] ?? json['lineno'] ?? '',
      lineid: json['LINE_ID'] ?? json['lineid'] ?? '',
      bstopidx:
          int.tryParse(
            (json['BSTOP_IDX'] ?? json['bstopidx'] ?? '0').toString(),
          ) ??
          0,
      bustype: json['BUSTYPE'] ?? json['bustype'] ?? '',
      carno1: json['CARNO1'] ?? json['carno1'] ?? '',
      carno2: json['CARNO2'] ?? json['carno2'] ?? '',
      min1: json['MIN1'] ?? json['min1'] ?? '',
      min2: json['MIN2'] ?? json['min2'] ?? '',
      station1: json['STATION1'] ?? json['station1'] ?? '',
      station2: json['STATION2'] ?? json['station2'] ?? '',
      lowplate1: json['LOWPLATE1'] ?? json['lowplate1'] ?? '',
      lowplate2: json['LOWPLATE2'] ?? json['lowplate2'] ?? '',
      seat1: json['SEAT1'] ?? json['seat1'] ?? '',
      seat2: json['SEAT2'] ?? json['seat2'] ?? '',
    );
  }
}
