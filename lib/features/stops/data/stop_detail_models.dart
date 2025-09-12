class StopMeta {
  final String bstopid;
  final String bstopnm;
  final String arsno;
  final double lat;
  final double lng;

  const StopMeta({
    required this.bstopid,
    required this.bstopnm,
    required this.arsno,
    required this.lat,
    required this.lng,
  });

  factory StopMeta.fromJson(Map<String, dynamic> json) => StopMeta(
    bstopid: json['bstopid'] as String,
    bstopnm: json['bstopnm'] as String,
    arsno: json['arsno'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'bstopid': bstopid,
    'bstopnm': bstopnm,
    'arsno': arsno,
    'lat': lat,
    'lng': lng,
  };
}

class ArrivalItem {
  final String lineid;
  final String lineno;
  final String nodenm;
  final String min1;
  final String station1;
  final String min2;
  final String station2;
  final String? bustype;
  final String? lowplate1; // "1" for low-floor

  const ArrivalItem({
    required this.lineid,
    required this.lineno,
    required this.nodenm,
    required this.min1,
    required this.station1,
    required this.min2,
    required this.station2,
    this.bustype,
    this.lowplate1,
  });

  factory ArrivalItem.fromJson(Map<String, dynamic> json) => ArrivalItem(
    lineid: json['lineid'] as String,
    lineno: json['lineno'] as String,
    nodenm: json['nodenm'] as String,
    min1: json['min1'] as String,
    station1: json['station1'] as String,
    min2: json['min2'] as String,
    station2: json['station2'] as String,
    bustype: json['bustype'] as String?,
    lowplate1: json['lowplate1'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'lineid': lineid,
    'lineno': lineno,
    'nodenm': nodenm,
    'min1': min1,
    'station1': station1,
    'min2': min2,
    'station2': station2,
    'bustype': bustype,
    'lowplate1': lowplate1,
  };
}

enum ArrivalSort { imminent, line }
