import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/city_provider.dart';
import '../models/saved_place_model.dart';

class VisitedPlacesBottomSheet extends StatelessWidget {
  final String cityId;
  final PlaceCategory category;

  const VisitedPlacesBottomSheet({
    super.key,
    required this.cityId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CityProvider>();

    final places = provider.getVisitedPlaces(
      cityId: cityId,
      category: category,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category == PlaceCategory.restaurant
                  ? 'Visited Restaurants'
                  : 'Visited Activities',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (places.isEmpty)
              const Text('Noch keine besucht.')
            else
              ...places.map(
                (place) => ListTile(
                  title: Text(place.name),
                  subtitle: Text(
                    '⭐ ${place.rating} (${place.userRatingsTotal})',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      provider.togglePlaceVisited(
                        cityId: cityId,
                        placeId: place.placeId,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
