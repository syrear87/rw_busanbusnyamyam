class Station {
  final String bstopid;
  final String bstopnm;
  final String arsno;
  final double lat;
  final double lng;

  const Station({
    required this.bstopid,
    required this.bstopnm,
    required this.arsno,
    required this.lat,
    required this.lng,
  });
}

class Arrival {
  final String lineid;
  final String lineno;
  final String? predict1;
  final String? predict2;

  const Arrival({
    required this.lineid,
    required this.lineno,
    this.predict1,
    this.predict2,
  });
}

class RouteInfo {
  final String lineid;
  final String lineno;

  const RouteInfo({required this.lineid, required this.lineno});
}

class RouteStop {
  final String bstopid;
  final String bstopnm;
  final String arsno;

  const RouteStop({
    required this.bstopid,
    required this.bstopnm,
    required this.arsno,
  });
}
