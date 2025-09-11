class Station {
  final String bstopid, bstopnm, arsno;
  final double lat, lng;
  const Station({required this.bstopid, required this.bstopnm, required this.arsno, required this.lat, required this.lng});
}

class Arrival {
  final String lineid, lineno, nodenm;
  final String min1, station1, min2, station2; // strings as-is
  final String bustype; // 버스 타입 (일반버스, 급행버스 등)
  const Arrival({required this.lineid, required this.lineno, required this.nodenm, required this.min1, required this.station1, required this.min2, required this.station2, required this.bustype});
}

class RouteInfo {
  final String lineid;
  final String lineno;

  const RouteInfo({required this.lineid, required this.lineno});
}

class RouteStop {
  final String bstopid, bstopnm, arsno, lineno;
  const RouteStop({required this.bstopid, required this.bstopnm, required this.arsno, required this.lineno});
}
