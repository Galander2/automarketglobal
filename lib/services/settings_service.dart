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
    await _writeWithAudit(settings, adminUid, action: 'settings.updated');
  }

  Future<void> resetSettings(String adminUid) async {
    await _writeWithAudit(
      AdminSettings.defaults(),
      adminUid,
      action: 'settings.reset',
    );
  }

  Future<void> _writeWithAudit(
    AdminSettings settings,
    String adminUid, {
    required String action,
  }) async {
    final settingsRef = _firestore.collection(_collectionPath).doc(_docId);
    final auditRef = _firestore.collection('admin_audit_logs').doc();
    final data = settings.toMap()
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..['updatedBy'] = adminUid;

    final batch = _firestore.batch();
    batch.set(settingsRef, data);
    batch.set(auditRef, {
      'actorId': adminUid,
      'action': action,
      'targetType': 'settings',
      'targetId': _docId,
      'metadata': const <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
