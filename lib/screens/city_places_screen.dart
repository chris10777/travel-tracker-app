import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/city_provider.dart';
import '../models/saved_place_model.dart';

/// ─────────────────────────────────────────────
/// Sortier- & Filteroptionen
/// ─────────────────────────────────────────────
enum PlaceSort {
  ratingDesc,
  ratingAsc,
  reviewsDesc,
}

enum PlaceFilter {
  all,
  restaurant,
  activity,
}

class CityPlacesScreen extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CityPlacesScreen({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CityPlacesScreen> createState() => _CityPlacesScreenState();
}

class _CityPlacesScreenState extends State<CityPlacesScreen> {
  PlaceSort _sort = PlaceSort.ratingDesc;
  PlaceFilter _filter = PlaceFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CityProvider>();

    List<SavedPlace> places =
        List.from(provider.getPlacesForCity(widget.cityId));

    // ─────────────────────────────────────────────
    // FILTER (über PlaceCategory)
    // ─────────────────────────────────────────────
    if (_filter != PlaceFilter.all) {
      places = places.where((p) {
        if (_filter == PlaceFilter.restaurant) {
          return p.category == PlaceCategory.restaurant;
        }
        if (_filter == PlaceFilter.activity) {
          return p.category == PlaceCategory.activity;
        }
        return true;
      }).toList();
    }

    // ─────────────────────────────────────────────
    // SORT
    // ─────────────────────────────────────────────
    switch (_sort) {
      case PlaceSort.ratingDesc:
        places.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case PlaceSort.ratingAsc:
        places.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case PlaceSort.reviewsDesc:
        places.sort(
          (a, b) =>
              b.userRatingsTotal.compareTo(a.userRatingsTotal),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Places in ${widget.cityName}'),
      ),
      body: Column(
        children: [
          _FilterBar(
            sort: _sort,
            filter: _filter,
            onSortChanged: (v) => setState(() => _sort = v),
            onFilterChanged: (v) => setState(() => _filter = v),
          ),
          Expanded(
            child: places.isEmpty
                ? const Center(
                    child: Text('Keine passenden Places gefunden'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: places.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return _PlaceTile(
                        place: place,
                        cityId: widget.cityId,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Filter & Sort UI
/// ─────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final PlaceSort sort;
  final PlaceFilter filter;
  final ValueChanged<PlaceSort> onSortChanged;
  final ValueChanged<PlaceFilter> onFilterChanged;

  const _FilterBar({
    required this.sort,
    required this.filter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          /// FILTER
          DropdownButton<PlaceFilter>(
            value: filter,
            onChanged: (v) {
              if (v != null) onFilterChanged(v);
            },
            items: const [
              DropdownMenuItem(
                value: PlaceFilter.all,
                child: Text('Alle'),
              ),
              DropdownMenuItem(
                value: PlaceFilter.restaurant,
                child: Text('Restaurants'),
              ),
              DropdownMenuItem(
                value: PlaceFilter.activity,
                child: Text('Aktivitäten'),
              ),
            ],
          ),
          const Spacer(),

          /// SORT
          DropdownButton<PlaceSort>(
            value: sort,
            onChanged: (v) {
              if (v != null) onSortChanged(v);
            },
            items: const [
              DropdownMenuItem(
                value: PlaceSort.ratingDesc,
                child: Text('⭐ Beste zuerst'),
              ),
              DropdownMenuItem(
                value: PlaceSort.ratingAsc,
                child: Text('⭐ Schlechteste zuerst'),
              ),
              DropdownMenuItem(
                value: PlaceSort.reviewsDesc,
                child: Text('💬 Meiste Bewertungen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Place Tile
/// ─────────────────────────────────────────────
class _PlaceTile extends StatelessWidget {
  final SavedPlace place;
  final String cityId;

  const _PlaceTile({
    required this.place,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CityProvider>();

    return Card(
      child: ListTile(
        title: Text(place.name),
        subtitle: Text(
          '⭐ ${place.rating} (${place.userRatingsTotal})\n'
          '${place.category == PlaceCategory.restaurant ? "Restaurant" : "Aktivität"}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            place.visited
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color: place.visited ? Colors.green : null,
          ),
          onPressed: () {
            provider.togglePlaceVisited(
              cityId: cityId,
              placeId: place.placeId,
            );
          },
        ),
      ),
    );
  }
}
