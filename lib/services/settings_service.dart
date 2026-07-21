import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_settings.dart';

class SettingsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collectionPath = 'admin_settings';
  static const String _docId = 'global';

  SettingsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<AdminSettings?> watchSettings() {
    return _firestore.collection(_collectionPath).doc(_docId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AdminSettings.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Future<AdminSettings?> getSettings() async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(_docId).get();
      if (doc.exists) {
        return AdminSettings.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  Future<void> saveSettings(AdminSettings settings, String adminUid) async {
    try {
      final updatedSettings = settings.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );
      await _firestore.collection(_collectionPath).doc(_docId).set(
        updatedSettings.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  Future<void> resetSettings(String adminUid) async {
    try {
      final defaultSettings = AdminSettings().copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );
      await _firestore.collection(_collectionPath).doc(_docId).set(
        defaultSettings.toMap(),
        SetOptions(merge: false),
      );
    } catch (e) {
      print('Error resetting settings: $e');
      rethrow;
    }
  }
}