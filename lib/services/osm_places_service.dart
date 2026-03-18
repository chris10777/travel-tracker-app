import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/osm_place.dart';

class OsmPlacesService {
  /// Lädt das globale OSM Places Dataset
  /// (vorerst aus Assets, später Patch/FS)
  static Future<List<OsmPlace>> loadAll() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/places.json');

    final List<dynamic> data = json.decode(jsonStr);
    return data
        .map((e) => OsmPlace.fromJson(e))
        .toList();
  }
}
