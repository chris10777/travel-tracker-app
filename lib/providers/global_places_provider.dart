import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../models/osm_place.dart';

class GlobalPlacesProvider extends ChangeNotifier {
  static final GlobalPlacesProvider instance =
      GlobalPlacesProvider._internal();

  GlobalPlacesProvider._internal();

  List<OsmPlace> _places = [];
  String? _loadedCity;

  List<OsmPlace> get places => _places;

  Future<void> loadForCity(String citySlug) async {
    if (_loadedCity == citySlug) return;

    final path = 'assets/data/places_by_city/$citySlug.json';

    try {
      final raw = await rootBundle.loadString(path);
      final List data = json.decode(raw);

      _places = data.map((e) => OsmPlace.fromJson(e)).toList();
      _loadedCity = citySlug;

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed loading $path: $e');
      _places = [];
      notifyListeners();
    }
  }

  void clear() {
    _places = [];
    _loadedCity = null;
  }
}
