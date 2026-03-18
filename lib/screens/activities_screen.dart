import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city_model.dart';
import '../models/saved_place_model.dart';
import '../providers/city_provider.dart';
import '../providers/global_places_provider.dart';
import '../services/places_query_service.dart';
import '../widgets/base_place_card.dart';

class ActivitiesScreen extends StatefulWidget {
  final City city;

  const ActivitiesScreen({
    super.key,
    required this.city,
  });

  @override
  State<ActivitiesScreen> createState() =>
      _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalPlacesProvider.instance
          .loadForCity(widget.city.name.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cityProvider = context.watch<CityProvider>();
    final globalPlaces =
        context.watch<GlobalPlacesProvider>().places;

    final activities = PlacesQueryService.query(
      allPlaces: globalPlaces,
      city: widget.city,
      category: PlaceCategory.activity,
    );

    final saved =
        cityProvider.getActivitiesForCity(widget.city.id);

    final visible = activities.where((p) {
      if (searchQuery.isEmpty) return true;
      return p.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  setState(() => searchQuery = v),
            ),
          ),

          // 📋 List
          Expanded(
            child: visible.isEmpty
                ? const Center(
                    child: Text(
                      'No activities found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12),
                    children: visible.map((place) {
                      final alreadyVisited = saved.any(
                        (p) => p.placeId == place.id,
                      );

                      return BasePlaceCard(
                        icon: Icons.local_activity,
                        title: place.name,
                        subtitle: '',
                        isActive: alreadyVisited,
                        onTap: () {},
                        onToggle: () {
                          if (alreadyVisited) {
                            cityProvider.removePlaceFromCity(
                              cityId: widget.city.id,
                              placeId: place.id,
                            );
                          } else {
                            cityProvider.addPlaceToCity(
                              cityId: widget.city.id,
                              place: SavedPlace(
                                placeId: place.id,
                                name: place.name,
                                rating: 0,
                                userRatingsTotal: 0,
                                address: '',
                                category:
                                    PlaceCategory.activity,
                                visited: true,
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
