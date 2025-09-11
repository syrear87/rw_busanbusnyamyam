class Stop {
  final String id;
  final String name;
  final String arsno;
  final double lat;
  final double lng;

  const Stop({
    required this.id,
    required this.name,
    required this.arsno,
    required this.lat,
    required this.lng,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
    id: json['id'] as String,
    name: json['name'] as String,
    arsno: (json['arsno'] ?? '') as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arsno': arsno,
    'lat': lat,
    'lng': lng,
  };
}
