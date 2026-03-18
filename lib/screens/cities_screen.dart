import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import '../models/city_model.dart' show City, CityDetailedRating, Photo;
import '../providers/city_provider.dart';
import '../widgets/city_rating_dialog.dart';
import '../services/local_city_service.dart' as service;
import '../utils/number_formatter.dart';
import '../utils/country_flag.dart';
import '../utils/continent_data.dart';
import '../utils/rating_style.dart';

import '../widgets/world_map_widget.dart';
import '../widgets/continent_progress.dart';

import 'city_detail_screen.dart';
import 'settings_screen.dart';
import 'ranking_screen.dart';
import '../services/ranking_service.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/city_photo_carousel.dart';
import '../models/saved_place_model.dart';
import 'activities_screen.dart';
import 'restaurants_screen.dart';




class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cloudAnimation;
final ScrollController _cityScrollController = ScrollController();



  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _cloudAnimation = Tween<double>(
      begin: -40,
      end: 40,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // 🌤️ GLOBALER HIMMEL (verhindert weißen Rand)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFBFE7FF),
                Color(0xFFEAF6FF),
              ],
            ),
          ),
        ),

        // ───────────── CONTENT ─────────────
        Column(
          children: [
            _buildHeader(),
            Expanded(child: _getBody()),
          ],
        ),
      ],
    ),

    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: const Color(0xFF5DA9E9),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'My Cities'),
        BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ranking'),
        BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Photos'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}

//Rating Farbverlauf

LinearGradient ratingGradient(double rating) {
  if (rating < 5.0) {
    // 🔴 schlecht
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE53935),
        Color(0xFFD32F2F),
      ],
    );
  } else if (rating < 7.0) {
    // 🟡 mittel
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFD54F),
        Color(0xFFFFB300),
      ],
    );
  } else {
    // 🟢 sehr gut
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF66BB6A),
        Color(0xFF43A047),
      ],
    );
  }
}

  // ───────────────────────────────────────── HEADER

Widget _buildHeader() {
  return Container(
    height: 200, // 🔥 minimal höher, damit nichts abgeschnitten wird
    width: double.infinity,
    decoration: const BoxDecoration(
      // Himmel-Hintergrund, falls Banner schmaler ist
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFBFE7FF),
          Color(0xFFEAF6FF),
        ],
      ),
    ),
    child: Stack(
      children: [
        // 🖼️ Banner – vollständig sichtbar
        Positioned.fill(
          child: Image.asset(
            'assets/banner.png',
            fit: BoxFit.contain, // ✅ KEIN Abschneiden mehr
            alignment: Alignment.topCenter,
          ),
        ),

        // ➕ Add City Icon – höher im Banner
        if (_selectedIndex == 0)
Positioned(
  right: 0,
  bottom: -4, // 🔥 wieder in der Ecke
  child: GestureDetector(
    onTap: _addNewCity,
    child: Image.asset(
      'assets/icons/add_city.png',
      width: 96,
      height: 96,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  ),
),

      ],
    ),
  );
}

  // ───────────────────────────────────────── BODY SWITCH
  Widget _getBody() {
    final cityProvider = Provider.of<CityProvider>(context);

    switch (_selectedIndex) {
      case 0:
        return _buildMyCities(cityProvider);
      case 1:
        return _buildProgressTab(cityProvider);
      case 2:
        return const RankingScreen();
      case 3:
        return const Center(child: Text('Photos'));
      case 4:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  // ───────────────────────────────────────── MY CITIES

Widget _buildMyCities(CityProvider cityProvider) {
  final cities = [...cityProvider.cities]
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  if (cities.isEmpty) {
    return _buildEmptyState();
  }

  // ───────────────── GROUP BY LETTER ─────────────────
  final Map<String, List<City>> grouped = {};
  for (final city in cities) {
    final letter = city.name[0].toUpperCase();
    grouped.putIfAbsent(letter, () => []).add(city);
  }

  // ───────────────── SCROLL OFFSETS ─────────────────
  final Map<String, double> letterOffsets = {};
  double offset = 0;

  grouped.forEach((letter, list) {
    letterOffsets[letter] = offset;
    offset += 28; // letter height
    final rows = (list.length / 2).ceil();
    offset += rows * 260; // card height approx
  });

  return Stack(
    children: [
      // ───────────── LIST ─────────────
      ListView(
        controller: _cityScrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 40, 16),
        children: grouped.entries.map((entry) {
          final letter = entry.key;
          final letterCities = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔤 LETTER
              Text(
                letter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // 🧱 GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: letterCities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.735,
                ),
                itemBuilder: (context, index) {
                  final city = letterCities[index];
                  final hasPhotos = city.photos.isNotEmpty;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CityDetailScreen(city: city),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient:
                            Theme.of(context).brightness == Brightness.dark
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF1E2A36),
                                      Color(0xFF16202A),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFEAF6FF),
                                      Color(0xFFF4FBF7),
                                    ],
                                  ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      // ⭐ STACK
child: Stack(
  children: [
    // ───────────────── CONTENT ─────────────────
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───── TEXTBLOCK (feste Höhe durch Inhalt begrenzt) ─────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏙 CITY NAME
              AutoSizeText(
                city.name,
                maxLines: 1,
                minFontSize: 11,
                maxFontSize: 16,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // 🌍 COUNTRY
              Row(
                children: [
                  Text(
                    countryCodeToEmoji(city.countryCode),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AutoSizeText(
                      city.country,
                      maxLines: 1,
                      minFontSize: 10,
                      maxFontSize: 13,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

// 👥 POPULATION + ⋮ MENU (GLEICHE HÖHE)
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Icon(
      Icons.groups_rounded,
      size: 15,
      color: Colors.grey.shade500,
    ),
    const SizedBox(width: 6),

    // Population
    Expanded(
      child: Text(
        formatPopulation(city.population),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
    ),

    // ⋮ Drei Punkte – rechts, ohne Hintergrund
    PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32),
      icon: Icon(
        Icons.more_vert,
        size: 18,
        color: Colors.grey.shade600, // ✅ sichtbar, aber dezent
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _openEditCitySheet(city);
        } else if (value == 'photos') {
          _editCityPhotos(city);
        } else if (value == 'favorite') {
          _editFavoritePlace(city);
        } else if (value == 'delete') {
          _confirmDeleteCity(city);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit Rating'),
        ),
        PopupMenuItem(
          value: 'photos',
          child: Text('Edit Photos'),
        ),
        PopupMenuItem(
          value: 'favorite',
          child: Text('Favorite Place'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  ],
),

              // ❤️ FAVORITE PLACE
              if (city.detailedRating.favoritePlace != null &&
                  city.detailedRating.favoritePlace!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          city.detailedRating.favoritePlace!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
const SizedBox(height: 8),

// 🧭 ACTIVITIES / RESTAURANTS BUTTONS
Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          side: BorderSide(color: Colors.blueGrey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.directions_walk, size: 16),
        label: Text(
          '${city.places.where((p) => p.category == PlaceCategory.activity && p.visited).length} Activities',
          style: const TextStyle(fontSize: 12),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActivitiesScreen(city: city),
            ),
          );
        },
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          side: BorderSide(color: Colors.blueGrey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.restaurant, size: 16),
        label: Text(
          '${city.places.where((p) => p.category == PlaceCategory.restaurant && p.visited).length} Restaurants',
          style: const TextStyle(fontSize: 12),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantsScreen(city: city),
            ),
          );
        },
      ),
    ),
  ],
),

        // ───── IMAGE (nimmt Resthöhe ein, KEIN Overflow) ─────
        if (city.photos.isNotEmpty)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
              child: Image.file(
                File(city.photos.first.path),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    ),

    // ───────────────── ⭐ RATING BADGE ─────────────────
    Positioned(
      top: 8,
      right: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: ratingGradient(city.rating),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  city.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ]
),

                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),

      // ───────────── ALPHABET SIDEBAR ─────────────
      Positioned(
        right: 4,
        top: 80,
        bottom: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: grouped.keys.map((letter) {
            return GestureDetector(
              onTap: () {
                final target = letterOffsets[letter];
                if (target != null) {
                  _cityScrollController.animateTo(
                    target,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildEmptyState() {
  return Container(
    width: double.infinity,
decoration: const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFBFE7FF), // 👈 klares Himmelblau
      Color(0xFFEAF6FF), // 👈 nach unten heller
    ],
  ),
),

    child: Stack(
      children: [
        // ☁️ WOLKEN – klein, verteilt, ruhig
        AnimatedBuilder(
          animation: _cloudAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: 70,
                  left: _cloudAnimation.value,
                  child: _cloud(size: 56, opacity: 0.22),
                ),
                Positioned(
                  top: 120,
                  right: _cloudAnimation.value * 0.8,
                  child: _cloud(size: 44, opacity: 0.18),
                ),
                Positioned(
                  top: 180,
                  left: _cloudAnimation.value * 0.6,
                  child: _cloud(size: 68, opacity: 0.16),
                ),
                Positioned(
                  top: 240,
                  right: _cloudAnimation.value * 0.4,
                  child: _cloud(size: 40, opacity: 0.20),
                ),
              ],
            );
          },
        ),

        // 🌍 CONTENT
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✨ PULSE ICON
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: GestureDetector(
                    onTap: _addNewCity,
                    child: Image.asset(
                      'assets/icons/add_city.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'No cities yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Your travel memories start here.\nAdd your first city and begin exploring.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Tap the city icon to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _cloud({
  double size = 60,
  double opacity = 0.35,
}) {
  return Icon(
    Icons.cloud,
    size: size,
    color: Colors.white.withOpacity(opacity), // ☁️ REINWEISS
  );
}

  // ───────────────────────────────────────── PROGRESS TAB
  Widget _buildProgressTab(CityProvider cityProvider) {
    final visitedCountryCodes = cityProvider.cities
        .map((c) => c.countryCode)
        .where((c) => c.isNotEmpty)
        .toSet();

    const totalCountries = 248;
    final progress = visitedCountryCodes.length / totalCountries;

    final Map<String, int> continentProgress = {
      for (final c in continentTotals.keys) c: 0,
    };

    for (final code in visitedCountryCodes) {
      final continent = countryToContinent[code];
      if (continent != null) continentProgress[continent] =
          continentProgress[continent]! + 1;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('World Progress',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: WorldMap(visitedCountries: visitedCountryCodes)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, minHeight: 14),
          const SizedBox(height: 20),
          Expanded(
            child: ContinentProgress(
              progress: continentProgress,
              visitedCountries: visitedCountryCodes,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────── ACTIONS (LOGIC UNCHANGED)

Future<void> _confirmDeleteCity(City city) async {
  final cityProvider =
      Provider.of<CityProvider>(context, listen: false);

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete City'),
      content: Text('Really delete ${city.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await cityProvider.deleteCity(city);
    await RankingService().removeCityRating(city);
  }
}


  // 🔽 REST: add/edit/photos → UNVERÄNDERT


Future<void> _addNewCity() async {
  final cityProvider =
      Provider.of<CityProvider>(context, listen: false);
  final serviceInstance = service.LocalCityService();

  final cities = await serviceInstance.fetchCities();
  service.CityInfo? selected;

  selected = await showDialog<service.CityInfo>(
    context: context,
    builder: (_) {
      List<service.CityInfo> filtered = [...cities];

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Select City'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search city',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filtered = cities
                            .where((c) => c.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final c = filtered[index];

                        // ❗ WICHTIG:
                        // NUR aktive Städte blockieren
                        final exists = cityProvider.cityExists(
                          c.name,
                          c.countryCode,
                        );

                        return ListTile(
                          title: Text(
                            '${c.name} (${formatPopulation(c.population)})',
                          ),
                          enabled: !exists,
                          onTap: !exists
                              ? () => Navigator.pop(ctx, c)
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (selected == null) return;

  final rating =
      await showCityRatingDialog(context, selected.name);
  if (rating == null) return;

  final photos = await _pickPhotos();

final city = City(
  name: selected.name,
  country: selected.country,
  countryCode: selected.countryCode,
  population: selected.population,
  latitude: selected.latitude,
  longitude: selected.longitude,
  rating: rating.average,
  detailedRating: rating,
  photos: photos,
  visited: true,
);

// ✅ City lokal hinzufügen
cityProvider.addCity(city);

cityProvider.addCity(city);
await RankingService().submitCityRating(city);
    
  }

void _openEditCitySheet(City city) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            _editTile(
              icon: Icons.star_rounded,
              label: 'Edit Rating',
              onTap: () {
                Navigator.pop(context);
                _editCityRating(city);
              },
            ),

            _editTile(
              icon: Icons.photo_library_rounded,
              label: 'Edit Photos',
              onTap: () {
                Navigator.pop(context);
                _editCityPhotos(city);
              },
            ),

            _editTile(
              icon: Icons.favorite_rounded,
              label: 'Edit Favorite Place',
              onTap: () {
                Navigator.pop(context);
                _editFavoritePlace(city);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Widget _editTile({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(label),
    onTap: onTap,
  );
}

Future<void> _editCityRating(City city) async {
  final provider = Provider.of<CityProvider>(context, listen: false);

  final updatedRating = await showCityRatingDialog(
    context,
    city.name,
    initial: city.detailedRating,
  );

  if (updatedRating == null) return;

  provider.updateCity(
    city.copyWith(
      rating: updatedRating.average,
      detailedRating: updatedRating,
    ),
  );
}

Future<void> _editCityPhotos(City city) async {
  final provider = Provider.of<CityProvider>(context, listen: false);

  final updatedPhotos = await _editPhotos(city.photos);

  provider.updateCity(
    city.copyWith(photos: updatedPhotos),
  );
}

Future<void> _editFavoritePlace(City city) async {
  final controller =
      TextEditingController(text: city.detailedRating.favoritePlace ?? '');

  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Favorite Place'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'e.g. Central Park, Old Town, Beach...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result == null) return;

  final provider = Provider.of<CityProvider>(context, listen: false);

  provider.updateCity(
    city.copyWith(
      detailedRating: city.detailedRating
        ..favoritePlace = result.isEmpty ? null : result,
    ),
  );
}


  Future<List<Photo>> _editPhotos(List<Photo> currentPhotos) async {
    final List<Photo> photos = List.from(currentPhotos);
    bool editing = true;

    final picker = ImagePicker();
    final dir = await getApplicationDocumentsDirectory();

    while (editing) {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Photos'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.count(
              crossAxisCount: 3,
              children: photos.map((p) {
                return Stack(
                  children: [
                    Image.file(File(p.path), fit: BoxFit.cover),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          photos.remove(p);
                          Navigator.pop(context, 'refresh');
                        },
                        child:
                            const Icon(Icons.close, color: Colors.red),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, 'done'),
                child: const Text('Done')),
            ElevatedButton.icon(
              onPressed: () async {
                final pickedFiles = await picker.pickMultiImage();
                if (pickedFiles != null) {
                  for (var picked in pickedFiles) {
                    final saved = await File(picked.path).copy(
                      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${picked.name}',
                    );
                    photos.add(Photo(path: saved.path));
                  }
                  Navigator.pop(context, 'refresh');
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Photos'),
            ),
          ],
        ),
      );

      if (result == 'done' || result == null) editing = false;
    }

    return photos;
  }

  Future<List<Photo>> _pickPhotos() async {
    final picker = ImagePicker();
    final dir = await getApplicationDocumentsDirectory();

    final List<Photo> photos = [];

    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var picked in pickedFiles) {
        final saved = await File(picked.path).copy(
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${picked.name}',
        );
        photos.add(Photo(path: saved.path));
      }
    }

    return photos;
  }
}




