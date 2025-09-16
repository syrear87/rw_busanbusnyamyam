class BusRoute {
  final String routeId;
  final String routeNumber;
  final String routeName;
  final String routeType; // 일반버스, 급행버스, 마을버스 등
  final String? description;

  const BusRoute({
    required this.routeId,
    required this.routeNumber,
    required this.routeName,
    required this.routeType,
    this.description,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      routeId: json['lineid'] ?? '',
      routeNumber: json['lineno'] ?? '',
      routeName: json['linenm'] ?? '',
      routeType: json['bustype'] ?? '일반버스',
      description: json['description'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusRoute &&
        other.routeId == routeId &&
        other.routeNumber == routeNumber;
  }

  @override
  int get hashCode => Object.hash(routeId, routeNumber);

  @override
  String toString() {
    return 'BusRoute{routeId: $routeId, routeNumber: $routeNumber, routeName: $routeName, routeType: $routeType}';
  }
}

class BusStop {
  final String stopId;
  final String stopNumber;
  final String stopName;
  final double lat;
  final double lon;
  final String? address;

  const BusStop({
    required this.stopId,
    required this.stopNumber,
    required this.stopName,
    required this.lat,
    required this.lon,
    this.address,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      stopId: json['bstopid'] ?? '',
      stopNumber: json['arsno'] ?? '',
      stopName: json['bstopnm'] ?? '',
      lat: double.tryParse(json['gpsy']?.toString() ?? '0') ?? 0.0,
      lon: double.tryParse(json['gpsx']?.toString() ?? '0') ?? 0.0,
      address: json['address'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusStop &&
        other.stopId == stopId &&
        other.stopNumber == stopNumber;
  }

  @override
  int get hashCode => Object.hash(stopId, stopNumber);

  @override
  String toString() {
    return 'BusStop{stopId: $stopId, stopNumber: $stopNumber, stopName: $stopName}';
  }
}

class RouteStop {
  final BusStop stop;
  final int sequence;
  final bool isKey; // 주요 정류장 여부

  const RouteStop({
    required this.stop,
    required this.sequence,
    this.isKey = false,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      stop: BusStop.fromJson(json),
      sequence: int.tryParse(json['bstopidx']?.toString() ?? '0') ?? 0,
      isKey: json['iskey'] == '1' || json['iskey'] == true,
    );
  }

  @override
  String toString() {
    return 'RouteStop{stop: ${stop.stopName}, sequence: $sequence, isKey: $isKey}';
  }
}