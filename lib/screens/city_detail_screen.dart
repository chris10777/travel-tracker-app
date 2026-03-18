import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/city_model.dart';
import '../utils/number_formatter.dart';
import '../utils/country_flag.dart';
import '../utils/rating_style.dart';
import '../widgets/city_places_section.dart'; // 👈 NEU

class CityDetailScreen extends StatelessWidget {
  final City city;

  const CityDetailScreen({
    super.key,
    required this.city,
  });

  double get topValue => [
        city.detailedRating.flair,
        city.detailedRating.food,
        city.detailedRating.culture,
        city.detailedRating.safety,
        city.detailedRating.nature,
      ].reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(city.latitude, city.longitude);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(city.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼 Photos
          if (city.photos.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: city.photos.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(p.path),
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // 🌍 Country
          Text(
            '${countryCodeToEmoji(city.countryCode)} ${city.country}',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          // ⭐ Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                city.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _infoRow(
            Icons.people,
            'Population: ${formatPopulation(city.population)}',
          ),

          const SizedBox(height: 24),

          // 🗺️ Map
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 11,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('city'),
                    position: position,
                    infoWindow: InfoWindow(title: city.name),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text('Open in Google Maps'),
            onPressed: () => _openInMaps(),
          ),

          const SizedBox(height: 24),

          // 📊 Ratings
          const Text(
            'Ratings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _ratingBar(
            context,
            Icons.auto_awesome,
            'Flair',
            city.detailedRating.flair,
            isDark,
          ),
          _ratingBar(
            context,
            Icons.restaurant,
            'Food',
            city.detailedRating.food,
            isDark,
          ),
          _ratingBar(
            context,
            Icons.account_balance,
            'Culture & Architecture',
            city.detailedRating.culture,
            isDark,
          ),
          _ratingBar(
            context,
            Icons.health_and_safety,
            'Safety & Hygiene',
            city.detailedRating.safety,
            isDark,
          ),
          _ratingBar(
            context,
            Icons.park,
            'Nature & Parks',
            city.detailedRating.nature,
            isDark,
          ),

          const SizedBox(height: 24),

          // ❤️ Favorite Place
          if (city.detailedRating.favoritePlace?.isNotEmpty ?? false)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        city.detailedRating.favoritePlace!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─────────────────────────────────────────
          // 📍 PLACES (NEU – Option A)
          // ─────────────────────────────────────────
          CityPlacesSection(cityId: city.id),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────

  Widget _ratingBar(
    BuildContext context,
    IconData icon,
    String label,
    double value,
    bool isDark,
  ) {
    final bool isTop = value == topValue;
    final Color color = ratingColor(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isTop ? color : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                '$label: ${value.toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                  color: isTop ? color : null,
                ),
              ),
              if (isTop) ...[
                const SizedBox(width: 6),
                Icon(Icons.star, size: 16, color: color),
              ],
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 10,
              minHeight: 8,
              backgroundColor: isDark
                  ? color.withOpacity(0.25)
                  : color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────

  void _openInMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${city.latitude},${city.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

