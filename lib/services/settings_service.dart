import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_settings.dart';

class SettingsService {
  static const String _collectionPath = 'admin_settings';
  static const String _docId = 'global';

  final FirebaseFirestore _firestore;

  SettingsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AdminSettings> getSettings() async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(_docId).get();
      if (doc.exists) {
        return AdminSettings.fromMap(doc.data()!);
      }
      return AdminSettings.defaults();
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  Stream<AdminSettings> watchSettings() {
    return _firestore.collection(_collectionPath).doc(_docId).snapshots().map((doc) {
      if (doc.exists) {
        return AdminSettings.fromMap(doc.data()!);
      }
      return AdminSettings.defaults();
    });
  }

  Future<void> saveSettingsWithAdmin(AdminSettings settings, String adminUid) async {
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
      throw Exception('Failed to save settings: $e');
    }
  }

  Future<void> resetSettings(String adminUid) async {
    try {
      final defaultSettings = AdminSettings.defaults().copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );
      await _firestore.collection(_collectionPath).doc(_docId).set(
        defaultSettings.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }
}
