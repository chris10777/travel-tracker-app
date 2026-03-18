import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/city_model.dart';

class FirestoreCityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  bool get isLoggedIn => _user != null;

  /// 📍 User-spezifische City-Collection
  CollectionReference<Map<String, dynamic>> _citiesRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cities');
  }

  /// 🔑 Stabile Dokument-ID
  String _cityDocId(City city) {
    final name = city.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final country = city.countryCode.toLowerCase();
    return '${name}_$country';
  }

  // ─────────────────────────────────────────────
  // 🔼 PUSH (local → cloud)
  // ─────────────────────────────────────────────
  Future<void> uploadCities(List<City> cities) async {
    final user = _user;
    if (user == null) return;

    try {
      final batch = _firestore.batch();
      final ref = _citiesRef(user.uid);

      for (final city in cities) {
        final docId = _cityDocId(city);
        batch.set(
          ref.doc(docId),
          city.toJson(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Firestore uploadCities failed: $e');
    }
  }

  // ─────────────────────────────────────────────
  // 🔽 PULL (cloud → local)
  // ─────────────────────────────────────────────
  Future<List<City>> downloadCities() async {
    final user = _user;
    if (user == null) return [];

    try {
      final snapshot = await _citiesRef(user.uid).get();

      return snapshot.docs
          .map((d) => City.fromJson(d.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore downloadCities failed: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // 🗑 DELETE (cloud)
  // ─────────────────────────────────────────────
  Future<void> deleteCity(City city) async {
    final user = _user;
    if (user == null) return;

    try {
      final docId = _cityDocId(city);
      await _citiesRef(user.uid).doc(docId).delete();
    } catch (e) {
      debugPrint('Firestore deleteCity failed: $e');
    }
  }
}
