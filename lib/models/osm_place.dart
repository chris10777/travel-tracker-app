class OsmPlace {
  final String id;
  final String name;
  final String category;
  final double lat;
  final double lon;
  final String city;
  final String country;

  OsmPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lon,
    required this.city,
    required this.country,
  });

  factory OsmPlace.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) {
        return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    return OsmPlace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      lat: parseDouble(json['lat']),
      lon: parseDouble(json['lon']),
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
    );
  }
}