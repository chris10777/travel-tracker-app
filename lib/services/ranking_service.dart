import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/city_model.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  bool get isLoggedIn => _user != null;

  CollectionReference<Map<String, dynamic>> get _rankingRef =>
      _firestore.collection('rankings');

  String _cityDocId(City city) =>
      '${city.name.toLowerCase()}_${city.countryCode.toLowerCase()}';

  /// ➕ ADD / UPDATE vote (exactly once per user)
  Future<void> submitCityRating(City city) async {
    if (!isLoggedIn) return;

    final uid = _user!.uid;
    final cityId = _cityDocId(city);

    final rankingDoc = _rankingRef.doc(cityId);
    final voteDoc = rankingDoc.collection('votes').doc(uid);

    await _firestore.runTransaction((tx) async {
      final voteSnap = await tx.get(voteDoc);

      // 🔁 Vote exists → update rating
      if (voteSnap.exists) {
        tx.update(voteDoc, {
          'rating': city.rating,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      // 🆕 First vote
      else {
        tx.set(voteDoc, {
          'rating': city.rating,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 🔄 Recalculate ranking
      final votesSnap = await rankingDoc.collection('votes').get();

      final ratings = votesSnap.docs
          .map((d) => (d.data()['rating'] as num).toDouble())
          .toList();

      final avg = ratings.isEmpty
          ? 0
          : ratings.reduce((a, b) => a + b) / ratings.length;

      tx.set(
        rankingDoc,
        {
          'name': city.name,
          'countryCode': city.countryCode,
          'avgRating': avg,
          'votes': ratings.length,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// ❌ REMOVE vote when user deletes city
  Future<void> removeCityRating(City city) async {
    if (!isLoggedIn) return;

    final uid = _user!.uid;
    final cityId = _cityDocId(city);

    final rankingDoc = _rankingRef.doc(cityId);
    final voteDoc = rankingDoc.collection('votes').doc(uid);

    await _firestore.runTransaction((tx) async {
      tx.delete(voteDoc);

      final votesSnap = await rankingDoc.collection('votes').get();

      if (votesSnap.docs.isEmpty) {
        // 🧹 No votes left → delete ranking doc
        tx.delete(rankingDoc);
        return;
      }

      final ratings = votesSnap.docs
          .map((d) => (d.data()['rating'] as num).toDouble())
          .toList();

      final avg =
          ratings.reduce((a, b) => a + b) / ratings.length;

      tx.update(rankingDoc, {
        'avgRating': avg,
        'votes': ratings.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
