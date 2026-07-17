import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/admin_settings.dart';

class SettingsService {
  final FirebaseFirestore _firestore;
  final String _settingsDocId = 'app_settings';
  
  AdminSettings? _cachedSettings;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  bool _isInitialized = false;

  SettingsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  bool get isInitialized => _isInitialized;
  
  AdminSettings get settings {
    return _cachedSettings ?? AdminSettings.defaults();
  }

  bool get notificationsEnabled => settings.notificationsEnabled;
  bool get emailNotifications => settings.emailNotifications;
  bool get pushNotifications => settings.pushNotifications;
  bool get maintenanceMode => settings.maintenanceMode;
  bool get newUserApprovalRequired => settings.newUserApprovalRequired;
  bool get carModerationEnabled => settings.carModerationEnabled;
  String get selectedLanguage => settings.selectedLanguage;
  String get selectedTheme => settings.selectedTheme;
  int get itemsPerPage => settings.itemsPerPage;
  double get commissionRate => settings.commissionRate;
  String? get bannerUrl => settings.bannerUrl;
  List<String> get supportedCountries => settings.supportedCountries;
  List<String> get categories => settings.categories;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _subscription = _firestore
        .collection('settings')
        .doc(_settingsDocId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _cachedSettings = AdminSettings.fromMap(
          snapshot.data() as Map<String, dynamic>,
        );
      } else {
        _cachedSettings = AdminSettings.defaults();
      }
      _isInitialized = true;
    });

    // Wait for first data
    await _firestore.collection('settings').doc(_settingsDocId).get();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _updateSettings({'notificationsEnabled': value});
  }

  Future<void> setEmailNotifications(bool value) async {
    await _updateSettings({'emailNotifications': value});
  }

  Future<void> setPushNotifications(bool value) async {
    await _updateSettings({'pushNotifications': value});
  }

  Future<void> setMaintenanceMode(bool value) async {
    await _updateSettings({'maintenanceMode': value});
  }

  Future<void> setNewUserApprovalRequired(bool value) async {
    await _updateSettings({'newUserApprovalRequired': value});
  }

  Future<void> setCarModerationEnabled(bool value) async {
    await _updateSettings({'carModerationEnabled': value});
  }

  Future<void> setSelectedLanguage(String value) async {
    await _updateSettings({'selectedLanguage': value});
  }

  Future<void> setSelectedTheme(String value) async {
    await _updateSettings({'selectedTheme': value});
  }

  Future<void> setItemsPerPage(int value) async {
    await _updateSettings({'itemsPerPage': value});
  }

  Future<void> setCommissionRate(double value) async {
    await _updateSettings({'commissionRate': value});
  }

  Future<void> setBannerUrl(String? value) async {
    await _updateSettings({'bannerUrl': value});
  }

  Future<void> setSupportedCountries(List<String> value) async {
    await _updateSettings({'supportedCountries': value});
  }

  Future<void> setCategories(List<String> value) async {
    await _updateSettings({'categories': value});
  }

  Future<void> saveSettings(AdminSettings newSettings) async {
    await _firestore
        .collection('settings')
        .doc(_settingsDocId)
        .set(newSettings.toMap(), SetOptions(merge: true));
  }

  Future<void> _updateSettings(Map<String, dynamic> updates) async {
    final now = DateTime.now();
    await _firestore
        .collection('settings')
        .doc(_settingsDocId)
        .set({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetToDefaults() async {
    final defaults = AdminSettings.defaults();
    await saveSettings(defaults);
  }
}
