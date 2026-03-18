import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city_model.dart';
import '../models/saved_place_model.dart';
import '../providers/city_provider.dart';
import '../screens/activities_screen.dart';
import '../screens/restaurants_screen.dart';
import '../widgets/visited_places_bottom_sheet.dart'; // 👈 NEU

class CityCard extends StatelessWidget {
final City city;

const CityCard({
super.key,
required this.city,
});

@override
Widget build(BuildContext context) {
final provider = context.watch<CityProvider>();

final activitiesVisited = provider.visitedCount(
  cityId: city.id,
  category: PlaceCategory.activity,
);

final restaurantsVisited = provider.visitedCount(
  cityId: city.id,
  category: PlaceCategory.restaurant,
);

return Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          city.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            /// ACTIVITIES
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivitiesScreen(city: city),
                    ),
                  );
                },
                child: Text('$activitiesVisited Activities'),
              ),
            ),

            const SizedBox(width: 12),

            /// RESTAURANTS (MIT BADGE + BOTTOM SHEET)
            Expanded(
              child: Stack(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => VisitedPlacesBottomSheet(
                          cityId: city.id,
                          category: PlaceCategory.restaurant,
                        ),
                      );
                    },
                    child: const Text('Restaurants'),
                  ),

                  if (restaurantsVisited > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          restaurantsVisited.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

}
}
