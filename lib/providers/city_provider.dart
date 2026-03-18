import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/city_model.dart';
import '../models/place_model.dart' as gplace;
import '../models/saved_place_model.dart';
import '../services/firestore_city_service.dart';
import '../providers/global_places_provider.dart';

class CityProvider extends ChangeNotifier {
  final List<City> _cities = [];
  final _firestore = FirestoreCityService();

  /// 🌱 Restaurant Seed pro City (lokal gecached)
  final Map<String, List<gplace.Place>> _restaurantSeed = {};

  bool syncing = false;
  DateTime? lastSync;
  String? lastSyncError;

  /// ✅ nur aktive Städte anzeigen
  List<City> get cities =>
      _cities.where((c) => c.deletedAt == null).toList();

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  Future<void> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cities');

    _cities.clear();

    if (jsonStr != null) {
      _cities.addAll(
        (json.decode(jsonStr) as List)
            .map((e) => City.fromJson(e)),
      );
    }

    _deduplicate();

    if (isLoggedIn) {
      await syncFromCloud();
    }

    await _saveLocal();
    notifyListeners();
  }

  void _deduplicate() {
    final Map<String, City> map = {};
    for (final city in _cities) {
      final existing = map[city.id];
      if (existing == null ||
          city.updatedAt.isAfter(existing.updatedAt)) {
        map[city.id] = city;
      }
    }
    _cities
      ..clear()
      ..addAll(map.values);
  }

  // ─────────────────────────────────────────────
  // CRUD – CITY
  // ─────────────────────────────────────────────
  bool cityExists(String name, String countryCode) {
    return _cities.any(
      (c) =>
          c.name == name &&
          c.countryCode == countryCode &&
          c.deletedAt == null,
    );
  }

  void addCity(City city) {
    if (_cities.any(
        (c) => c.id == city.id && c.deletedAt == null)) {
      return;
    }
    _cities.add(city);
    _persist();
  }

  void updateCity(City updatedCity) {
    final index =
        _cities.indexWhere((c) => c.id == updatedCity.id);
    if (index == -1) return;
    _cities[index] = updatedCity;
    _persist();
  }

  Future<void> deleteCity(City city) async {
    final index = _cities.indexWhere((c) => c.id == city.id);
    if (index == -1) return;
    _cities[index] =
        city.copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  // ─────────────────────────────────────────────
  // 🌱 RESTAURANT SEED (OSM → Place)
  // ─────────────────────────────────────────────

  double _restaurantScore(gplace.Place p) {
    final rating = p.rating ?? 0;
    final reviews = p.userRatingsTotal ?? 0;
    return (rating * 20) +
        (reviews > 0 ? math.log(reviews) * 10 : 0);
  }

  Future<void> buildRestaurantSeedForCity(City city) async {
    if (_restaurantSeed.containsKey(city.id)) return;

    final globalPlaces =
        GlobalPlacesProvider.instance.places;

    final Map<String, gplace.Place> unique = {};

    for (final osm in globalPlaces) {
      if (osm.category != 'food') continue;
      if (osm.city != city.name) continue;

      final place = gplace.Place.fromOsm(osm);

      if ((place.userRatingsTotal ?? 0) >= 100) {
        unique[place.placeId] = place;
      }
    }

    final seed = unique.values.toList()
      ..sort(
        (a, b) =>
            _restaurantScore(b).compareTo(_restaurantScore(a)),
      );

    _restaurantSeed[city.id] = seed;
    notifyListeners();
  }

  List<gplace.Place> getRestaurantSeed(String cityId) {
    return _restaurantSeed[cityId] ?? [];
  }

  List<gplace.Place> top5FromRestaurantSeed(String cityId) {
    return getRestaurantSeed(cityId).take(5).toList();
  }

  // ─────────────────────────────────────────────
  // 💾 SAVED PLACES (User-Zustand)
  // ─────────────────────────────────────────────

  List<SavedPlace> getPlacesForCity(String cityId) {
    final index = _cities.indexWhere((c) => c.id == cityId);
    if (index == -1) return [];
    return _cities[index].places;
  }

  void addPlaceToCity({
    required String cityId,
    required SavedPlace place,
  }) {
    final index = _cities.indexWhere((c) => c.id == cityId);
    if (index == -1) return;

    final city = _cities[index];
    if (city.places.any((p) => p.placeId == place.placeId)) {
      return;
    }

    city.places.add(place);
    _cities[index] =
        city.copyWith(places: List.from(city.places));
    _persist();
  }

  void removePlaceFromCity({
    required String cityId,
    required String placeId,
  }) {
    final index = _cities.indexWhere((c) => c.id == cityId);
    if (index == -1) return;

    final city = _cities[index];
    city.places.removeWhere((p) => p.placeId == placeId);
    _cities[index] =
        city.copyWith(places: List.from(city.places));
    _persist();
  }

  /// ✅ WIRD von city_places_section.dart benutzt
  void togglePlaceVisited({
    required String cityId,
    required String placeId,
  }) {
    final index = _cities.indexWhere((c) => c.id == cityId);
    if (index == -1) return;

    final city = _cities[index];
    final placeIndex =
        city.places.indexWhere((p) => p.placeId == placeId);
    if (placeIndex == -1) return;

    city.places[placeIndex].visited =
        !city.places[placeIndex].visited;

    _cities[index] =
        city.copyWith(places: List.from(city.places));
    _persist();
  }

  List<SavedPlace> getRestaurantsForCity(String cityId) {
    return getPlacesForCity(cityId)
        .where((p) => p.category == PlaceCategory.restaurant)
        .toList();
  }

  List<SavedPlace> getActivitiesForCity(String cityId) {
    return getPlacesForCity(cityId)
        .where((p) => p.category == PlaceCategory.activity)
        .toList();
  }

  // ─────────────────────────────────────────────
  // ⭐ VISITED COUNT (NEU – für CityCard)
  // ─────────────────────────────────────────────

  int visitedCount({
    required String cityId,
    required PlaceCategory category,
  }) {
    return getPlacesForCity(cityId)
        .where(
          (p) =>
              p.category == category &&
              p.visited == true,
        )
        .length;
  }

List<SavedPlace> getVisitedPlaces({
  required String cityId,
  required PlaceCategory category,
}) {
  return getPlacesForCity(cityId)
      .where(
        (p) =>
            p.category == category &&
            p.visited == true,
      )
      .toList();
}

  // ─────────────────────────────────────────────
  // CLOUD SYNC
  // ─────────────────────────────────────────────
  Future<void> syncFromCloud() async {
    syncing = true;
    notifyListeners();

    try {
      final cloudCities =
          await _firestore.downloadCities();

      for (final cloudCity in cloudCities) {
        final index =
            _cities.indexWhere((c) => c.id == cloudCity.id);

        if (index == -1 ||
            cloudCity.updatedAt
                .isAfter(_cities[index].updatedAt)) {
          if (index == -1) {
            _cities.add(cloudCity);
          } else {
            _cities[index] = cloudCity;
          }
        }
      }

      lastSync = DateTime.now();
      lastSyncError = null;
      await _saveLocal();
    } catch (e) {
      lastSyncError = e.toString();
    }

    syncing = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _saveLocal();
    if (isLoggedIn) {
      await _firestore.uploadCities(_cities);
      lastSync = DateTime.now();
    }
    notifyListeners();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cities',
      json.encode(_cities.map((c) => c.toJson()).toList()),
    );
  }
}
