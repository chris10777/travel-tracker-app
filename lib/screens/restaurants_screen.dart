import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/city_model.dart';
import '../models/saved_place_model.dart';
import '../models/osm_place.dart';
import '../providers/city_provider.dart';
import '../providers/global_places_provider.dart';
import '../services/places_query_service.dart';

class RestaurantsScreen extends StatefulWidget {
  final City city;

  const RestaurantsScreen({super.key, required this.city});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  String searchQuery = '';
  String? selectedLetter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalPlacesProvider.instance
          .loadForCity(widget.city.name.toLowerCase());
    });
  }

  // 🌍 DISTANCE
  double calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  String formatDistance(OsmPlace place) {
    final userLat = widget.city.latitude;
    final userLon = widget.city.longitude;

    final d = calculateDistanceKm(
        userLat, userLon, place.lat, place.lon);

    if (d < 1) {
      return '📍 ${(d * 1000).toStringAsFixed(0)} m away';
    }

    return '📍 ${d.toStringAsFixed(1)} km away';
  }

  // 🗺️ MAPS FIX (Name statt Koordinaten)
  Future<void> openMaps(OsmPlace place) async {
    final query =
        Uri.encodeComponent("${place.name} ${place.city}");

    final url =
        "https://www.google.com/maps/search/?api=1&query=$query";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
    }
  }

  // 🏆 BADGE SYSTEM (UNVERÄNDERT)
  Map<String, dynamic> getBadge(int count) {
    if (count >= 100) return {"title": "Legendary Foodie", "emoji": "👑", "colors": [Colors.purple, Colors.black]};
    if (count >= 80) return {"title": "Master Gourmet", "emoji": "🏆", "colors": [Colors.deepPurple, Colors.purple]};
    if (count >= 60) return {"title": "Elite Foodie", "emoji": "💎", "colors": [Colors.indigo, Colors.blue]};
    if (count >= 50) return {"title": "Top Critic", "emoji": "🎯", "colors": [Colors.blue, Colors.teal]};
    if (count >= 40) return {"title": "Explorer+", "emoji": "🌍", "colors": [Colors.teal, Colors.green]};
    if (count >= 30) return {"title": "Explorer", "emoji": "🧭", "colors": [Colors.green, Colors.lightGreen]};
    if (count >= 20) return {"title": "Adventurer", "emoji": "🚀", "colors": [Colors.orange, Colors.deepOrange]};
    if (count >= 10) return {"title": "Food Lover", "emoji": "🍽️", "colors": [Colors.amber, Colors.orange]};
    if (count >= 5) return {"title": "Taster", "emoji": "😋", "colors": [Colors.grey, Colors.blueGrey]};
    return {"title": "Beginner", "emoji": "🌱", "colors": [Colors.grey, Colors.grey]};
  }

  // ⭐ RATING (0.1 Schritte)
  Future<double?> showRatingDialog(BuildContext context) async {
    double rating = 3;

    String emoji(double r) {
      if (r >= 4.5) return "🤩";
      if (r >= 4) return "😍";
      if (r >= 3) return "🙂";
      if (r >= 2) return "😐";
      return "😬";
    }

    return showDialog<double>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate Restaurant"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji(rating),
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: rating,
                    min: 0,
                    max: 5,
                    divisions: 50,
                    onChanged: (v) =>
                        setState(() => rating = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, rating),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CityProvider>();
    final globalPlaces =
        context.watch<GlobalPlacesProvider>().places;

    final restaurants = PlacesQueryService.query(
      allPlaces: globalPlaces,
      city: widget.city,
      category: PlaceCategory.restaurant,
    );

    final saved =
        provider.getRestaurantsForCity(widget.city.id);

    List<OsmPlace> visible = restaurants.where((p) {
      if (searchQuery.isNotEmpty &&
          !p.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        return false;
      }

      if (selectedLetter != null &&
          !p.name
              .toUpperCase()
              .startsWith(selectedLetter!)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final badge = getBadge(saved.length);

    // ⭐ SORTIERUNG (NEU)
    final sorted = List.of(saved)
      ..sort((a, b) {
        final r = b.rating.compareTo(a.rating);
        if (r != 0) return r;
        return a.name.compareTo(b.name);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: Stack(
        children: [
          Column(
            children: [
              // SEARCH
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) =>
                      setState(() => searchQuery = v),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Distances are calculated from the city center',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // FILTER
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                      .split('')
                      .map((l) => Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 4),
                            child: ChoiceChip(
                              label: Text(l),
                              selected:
                                  selectedLetter == l,
                              onSelected: (_) {
                                setState(() {
                                  selectedLetter =
                                      selectedLetter == l
                                          ? null
                                          : l;
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: visible.map((place) {
                    final visited = saved.any(
                        (p) => p.placeId == place.id);

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                      child: ListTile(
                        leading:
                            const Icon(Icons.restaurant),
                        title: Text(place.name),
                        subtitle:
                            Text(formatDistance(place)),
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.map),
                              onPressed: () =>
                                  openMaps(place),
                            ),
                            IconButton(
                              icon: Icon(
                                visited
                                    ? Icons.check
                                    : Icons.add,
                                color: visited
                                    ? Colors.green
                                    : null,
                              ),
                              onPressed: () async {
                                if (visited) return;

                                final rating =
                                    await showRatingDialog(
                                        context);

                                if (rating == null) return;

                                provider.addPlaceToCity(
                                  cityId:
                                      widget.city.id,
                                  place: SavedPlace(
                                    placeId:
                                        place.id,
                                    name: place.name,
                                    rating: rating,
                                    userRatingsTotal:
                                        0,
                                    address: '',
                                    category:
                                        PlaceCategory
                                            .restaurant,
                                    visited: true,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // BOTTOM SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).cardColor,
                  borderRadius:
                      const BorderRadius.vertical(
                          top:
                              Radius.circular(20)),
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // BADGE
                    Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration:
                            BoxDecoration(
                          gradient: LinearGradient(
                              colors:
                                  badge['colors']),
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              badge['emoji'],
                              style: const TextStyle(
                                  fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${badge['title']} (${saved.length})",
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SORTED LIST
                    ...sorted.map((p) => ListTile(
                          title: Text(p.name),
                          subtitle: Text(
                              '⭐ ${p.rating.toStringAsFixed(1)}'),
                          trailing: IconButton(
                            icon: const Icon(
                                Icons.remove),
                            onPressed: () {
                              provider
                                  .removePlaceFromCity(
                                cityId:
                                    widget.city.id,
                                placeId:
                                    p.placeId,
                              );
                            },
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}