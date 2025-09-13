class Place {
  final String id;
  final String name;              // place_name
  final String url;               // place_url
  final String category;          // 'FD6' or 'CE7'
  final double lat;               // y
  final double lng;               // x
  final int? distanceM;           // distance (string meters → int)
  final String? address;          // road_address_name | address_name
  
  const Place({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.lat,
    required this.lng,
    this.distanceM,
    this.address,
  });
}

