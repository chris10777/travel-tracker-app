import 'dart:io';

import 'package:flutter/foundation.dart'; // ✅ für debugPrint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  bool get isLoggedIn => _user != null;

  /// 🔼 Upload Foto → Firebase Storage
  /// Gibt Download-URL zurück oder null
  Future<String?> uploadPhoto(File file, String cityId) async {
    if (!isLoggedIn) return null;

    try {
      final uid = _user!.uid;

      // 🔒 Kollisionssicherer Dateiname
      final extension = file.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$extension';

      final ref = _storage.ref(
        'users/$uid/cities/$cityId/photos/$fileName',
      );

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Photo upload failed: $e');
      return null;
    }
  }

  /// 🔽 Download Foto → lokal speichern
  /// Gibt lokale Datei zurück
  Future<File> downloadPhoto(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // 🔒 stabiler Dateiname aus URL
      final cleanName = url
          .split('/')
          .last
          .split('?')
          .first
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');

      final file = File('${dir.path}/$cleanName');

      // ✅ Schon vorhanden
      if (await file.exists()) {
        return file;
      }

      final ref = _storage.refFromURL(url);
      await ref.writeToFile(file);

      return file;
    } catch (e) {
      debugPrint('Photo download failed: $e');

      // ❗ Fallback (UI zeigt Placeholder)
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/invalid_photo');
    }
  }
}
