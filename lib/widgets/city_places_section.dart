import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/city_provider.dart';
import '../models/saved_place_model.dart';

/// ─────────────────────────────────────────────
/// Section für Activities & Restaurants
/// ─────────────────────────────────────────────
class CityPlacesSection extends StatefulWidget {
  final String cityId;

  const CityPlacesSection({
    super.key,
    required this.cityId,
  });

  @override
  State<CityPlacesSection> createState() => _CityPlacesSectionState();
}

class _CityPlacesSectionState extends State<CityPlacesSection> {
  PlaceCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CityProvider>();

    List<SavedPlace> places =
        List.from(provider.getPlacesForCity(widget.cityId));

    // ─────────────────────────────────────────────
    // FILTER (FIX: type → category)
    // ─────────────────────────────────────────────
    if (_filterCategory != null) {
      places = places
          .where((p) => p.category == _filterCategory)
          .toList();
    }

    if (places.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Keine Places vorhanden'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterChips(
          selected: _filterCategory,
          onChanged: (value) {
            setState(() => _filterCategory = value);
          },
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final place = places[index];
            return _PlaceTile(
              place: place,
              cityId: widget.cityId,
            );
          },
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────
/// Filter Chips
/// ─────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory?> onChanged;

  const _FilterChips({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Alle'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          ChoiceChip(
            label: const Text('Aktivitäten'),
            selected: selected == PlaceCategory.activity,
            onSelected: (_) =>
                onChanged(PlaceCategory.activity),
          ),
          ChoiceChip(
            label: const Text('Restaurants'),
            selected: selected == PlaceCategory.restaurant,
            onSelected: (_) =>
                onChanged(PlaceCategory.restaurant),
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
