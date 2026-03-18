import '../models/city_model.dart';
import '../models/osm_place.dart';
import '../models/saved_place_model.dart';

class PlacesQueryService {
  static bool _matchesCategory(
    String osmCategory,
    PlaceCategory category,
  ) {
    if (category == PlaceCategory.restaurant) {
      return osmCategory == 'food';
    }
    if (category == PlaceCategory.activity) {
      return osmCategory == 'activity';
    }
    return false;
  }

  static List<OsmPlace> query({
    required List<OsmPlace> allPlaces,
    required City city,
    required PlaceCategory category,
  }) {
    return allPlaces.where((place) {
      return _matchesCategory(place.category, category);
    }).toList();
  }
}
