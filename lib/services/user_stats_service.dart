import '../models/city_model.dart';
import '../models/saved_place_model.dart';

class UserStats {
  final int totalVisited;
  final int restaurantsVisited;
  final int activitiesVisited;
  final int citiesVisited;
  final double averageRating;

  const UserStats({
    required this.totalVisited,
    required this.restaurantsVisited,
    required this.activitiesVisited,
    required this.citiesVisited,
    required this.averageRating,
  });
}

class UserStatsService {
  static UserStats calculate({
    required List<City> cities,
    required Map<String, List<SavedPlace>> savedPlacesByCity,
  }) {
    int restaurants = 0;
    int activities = 0;
    double ratingSum = 0;
    int ratingCount = 0;

    final visitedCities = <String>{};

    for (final city in cities) {
      final places = savedPlacesByCity[city.id] ?? [];

      final visited = places.where((p) => p.visited).toList();
      if (visited.isNotEmpty) {
        visitedCities.add(city.id);
      }

      for (final place in visited) {
        if (place.category == PlaceCategory.restaurant) {
          restaurants++;
        } else if (place.category == PlaceCategory.activity) {
          activities++;
        }

        if (place.rating > 0) {
          ratingSum += place.rating;
          ratingCount++;
        }
      }
    }

    return UserStats(
      totalVisited: restaurants + activities,
      restaurantsVisited: restaurants,
      activitiesVisited: activities,
      citiesVisited: visitedCities.length,
      averageRating:
          ratingCount == 0 ? 0 : ratingSum / ratingCount,
    );
  }
}
