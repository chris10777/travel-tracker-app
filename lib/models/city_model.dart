import 'saved_place_model.dart';

/// ─────────────────────────────────────────────— 📸 Foto-Modell
/// ─────────────────────────────────────────────
class Photo {
  final String path;
  final String? url;
  final bool isPublic;

  Photo({
    required this.path,
    this.url,
    this.isPublic = true,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      path: json['path'] as String,
      url: json['url'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'url': url,
      'isPublic': isPublic,
    };
  }
}

/// ─────────────────────────────────────────────
/// ⭐ Detailliertes Stadt-Rating
/// ─────────────────────────────────────────────
class CityDetailedRating {
  double flair;
  double food;
  double culture;
  double safety;
  double nature;
  String? favoritePlace;

  CityDetailedRating({
    required this.flair,
    required this.food,
    required this.culture,
    required this.safety,
    required this.nature,
    this.favoritePlace,
  });

  double get average =>
      (flair + food + culture + safety + nature) / 5;

  factory CityDetailedRating.fromJson(Map<String, dynamic> json) {
    return CityDetailedRating(
      flair: (json['flair'] as num?)?.toDouble() ?? 5,
      food: (json['food'] as num?)?.toDouble() ?? 5,
      culture: (json['culture'] as num?)?.toDouble() ?? 5,
      safety: (json['safety'] as num?)?.toDouble() ?? 5,
      nature: (json['nature'] as num?)?.toDouble() ?? 5,
      favoritePlace: json['favoritePlace'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flair': flair,
      'food': food,
      'culture': culture,
      'safety': safety,
      'nature': nature,
      'favoritePlace': favoritePlace,
    };
  }
}

/// ─────────────────────────────────────────────
/// 🏙️ City Model (STABILE ID + SOFT DELETE)
/// ─────────────────────────────────────────────
class City {
  final String id;

  String name;
  String country;
  String countryCode;
  int population;

  double rating;
  CityDetailedRating detailedRating;
  List<Photo> photos;

  List<SavedPlace> places;

  bool visited;

  double latitude;
  double longitude;

  DateTime updatedAt;
  DateTime? deletedAt;

  City({
    String? id,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.population,
    required this.rating,
    required this.detailedRating,
    required this.photos,
    List<SavedPlace>? places,
    required this.latitude,
    required this.longitude,
    this.visited = true,
    DateTime? updatedAt,
    this.deletedAt,
  })  : id = id ??
            '${name}_${countryCode}_${DateTime.now().millisecondsSinceEpoch}',
        places = places ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  City copyWith({
    String? name,
    String? country,
    String? countryCode,
    int? population,
    double? rating,
    CityDetailedRating? detailedRating,
    List<Photo>? photos,
    List<SavedPlace>? places,
    bool? visited,
    double? latitude,
    double? longitude,
    DateTime? deletedAt,
  }) {
    return City(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      population: population ?? this.population,
      rating: rating ?? this.rating,
      detailedRating: detailedRating ?? this.detailedRating,
      photos: photos ?? this.photos,
      places: places ?? this.places,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visited: visited ?? this.visited,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      population: json['population'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      detailedRating:
          CityDetailedRating.fromJson(json['detailedRating'] ?? {}),
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((p) => Photo.fromJson(p))
          .toList(),
      places: (json['places'] as List<dynamic>? ?? [])
          .map((p) => SavedPlace.fromJson(p))
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      visited: json['visited'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'countryCode': countryCode,
      'population': population,
      'rating': rating,
      'detailedRating': detailedRating.toJson(),
      'photos': photos.map((p) => p.toJson()).toList(),
      'places': places.map((p) => p.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'visited': visited,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
