import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_settings.dart';

/// Сервис для работы с настройками администратора в Firestore
class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'admin_settings';
  static const String _docId = 'global';

  /// Получить документ настроек
  Future<AdminSettings> getSettings() async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(_docId).get();
      
      if (doc.exists) {
        return AdminSettings.fromMap(doc.data()!);
      }
      
      // Если документа нет, вернуть значения по умолчанию
      return AdminSettings.defaults();
    } catch (e) {
      throw Exception('Ошибка загрузки настроек: ${e.toString()}');
    }
  }

  /// Сохранить настройки
  Future<void> saveSettings(AdminSettings settings, String adminUid) async {
    try {
      final updatedSettings = settings.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );

      await _firestore
          .collection(_collectionPath)
          .doc(_docId)
          .set(updatedSettings.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Ошибка сохранения настроек: ${e.toString()}');
    }
  }

  /// Сбросить настройки к значениям по умолчанию
  Future<void> resetSettings(String adminUid) async {
    try {
      final defaults = AdminSettings.defaults().copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );

      await _firestore
          .collection(_collectionPath)
          .doc(_docId)
          .set(defaults.toMap());
    } catch (e) {
      throw Exception('Ошибка сброса настроек: ${e.toString()}');
    }
  }

  /// Слушать изменения настроек в реальном времени
  Stream<AdminSettings> watchSettings() {
    return _firestore
        .collection(_collectionPath)
        .doc(_docId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return AdminSettings.fromMap(snapshot.data()!);
      }
      return AdminSettings.defaults();
    });
  }
}
