import 'dart:convert';
import 'package:flutter/services.dart';

class CityInfo {
  final String name;
  final String country;
  final String countryCode;
  final int population;
  final double latitude;
  final double longitude;

  CityInfo({
    required this.name,
    required this.country,
    required this.countryCode,
    required this.population,
    required this.latitude,
    required this.longitude,
  });
}

class LocalCityService {
  Future<List<CityInfo>> fetchCities() async {
    final jsonString = await rootBundle.loadString('assets/cities.json');
    final List<dynamic> data = json.decode(jsonString);

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) {
        return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return data
        .where((c) => c['population'] != null)
        .map((city) => CityInfo(
              name: city['city']?.toString() ?? '',
              country: city['country']?.toString() ?? '',
              countryCode:
                  city['countryCode']?.toString().trim().toUpperCase() ?? '',
              population: parseInt(city['population']),
              latitude: parseDouble(city['lat']),
              longitude: parseDouble(city['lng']),
            ))
        .toList();
  }
}
