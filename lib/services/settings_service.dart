import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_settings.dart';

class SettingsService {
  final FirebaseFirestore _firestore;

  static const String _collectionPath = 'admin_settings';
  static const String _docId = 'global';

  SettingsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<AdminSettings> watchSettings() {
    return _firestore.collection(_collectionPath).doc(_docId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return AdminSettings.fromMap(snapshot.data()!);
      }
      return AdminSettings.defaults();
    });
  }

  Future<AdminSettings> getSettings() async {
    final doc = await _firestore.collection(_collectionPath).doc(_docId).get();
    if (doc.exists) {
      return AdminSettings.fromMap(doc.data()!);
    }
    return AdminSettings.defaults();
  }

  Future<void> saveSettings(AdminSettings settings, String adminUid) async {
    final updatedSettings = settings.copyWith(
      updatedAt: DateTime.now(),
      updatedBy: adminUid,
    );
    await _firestore
        .collection(_collectionPath)
        .doc(_docId)
        .set(updatedSettings.toMap(), SetOptions(merge: true));
  }

  Future<void> resetSettings(String adminUid) async {
    final defaultSettings = AdminSettings.defaults().copyWith(
      updatedAt: DateTime.now(),
      updatedBy: adminUid,
    );
    await _firestore
        .collection(_collectionPath)
        .doc(_docId)
        .set(defaultSettings.toMap(), SetOptions(merge: false));
  }
}
