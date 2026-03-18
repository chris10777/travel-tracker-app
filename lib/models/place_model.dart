import 'osm_place.dart';

enum PlaceCategory {
  restaurant,
  activity,
}

class Place {
  /// 🔑 Stabile ID (OSM)
  final String placeId;

  final String name;

  /// ⭐ Rating (OSM aktuell: nicht vorhanden)
  final double? rating;

  /// 👥 Anzahl Bewertungen (OSM aktuell: nicht vorhanden)
  final int? userRatingsTotal;

  /// 📍 Adresse (vereinheitlicht)
  final String address;

  /// 📍 Kurzadresse / Anzeige
  final String vicinity;

  /// 🏷️ Typen (z. B. restaurant / activity)
  final List<String> types;

  Place({
    required this.placeId,
    required this.name,
    this.rating,
    this.userRatingsTotal,
    required this.address,
    required this.vicinity,
    required this.types,
  });

  // ─────────────────────────────────────────────
  // 🌍 OSM → APP
  // ─────────────────────────────────────────────
  factory Place.fromOsm(OsmPlace osm) {
    final isFood = osm.category == 'food';

    return Place(
      placeId: osm.id,
      name: osm.name ?? '',
      rating: null,
      userRatingsTotal: null,
      address: '${osm.city}, ${osm.country}',
      vicinity: '${osm.city}, ${osm.country}',
      types: [isFood ? 'restaurant' : 'activity'],
    );
  }
}
