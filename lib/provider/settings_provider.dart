import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  
  SettingsProvider(this._settingsService) {
    _init();
  }

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  
  AdminSettings get settings => _settingsService.settings;

  bool get notificationsEnabled => _settingsService.notificationsEnabled;
  bool get emailNotifications => _settingsService.emailNotifications;
  bool get pushNotifications => _settingsService.pushNotifications;
  bool get maintenanceMode => _settingsService.maintenanceMode;
  bool get newUserApprovalRequired => _settingsService.newUserApprovalRequired;
  bool get carModerationEnabled => _settingsService.carModerationEnabled;
  String get selectedLanguage => _settingsService.selectedLanguage;
  String get selectedTheme => _settingsService.selectedTheme;
  int get itemsPerPage => _settingsService.itemsPerPage;
  double get commissionRate => _settingsService.commissionRate;
  String? get bannerUrl => _settingsService.bannerUrl;
  List<String> get supportedCountries => _settingsService.supportedCountries;
  List<String> get categories => _settingsService.categories;

  Future<void> _init() async {
    await _settingsService.initialize();
    _isInitialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsService.dispose();
    super.dispose();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _settingsService.setNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool value) async {
    await _settingsService.setEmailNotifications(value);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool value) async {
    await _settingsService.setPushNotifications(value);
    notifyListeners();
  }

  Future<void> setMaintenanceMode(bool value) async {
    await _settingsService.setMaintenanceMode(value);
    notifyListeners();
  }

  Future<void> setNewUserApprovalRequired(bool value) async {
    await _settingsService.setNewUserApprovalRequired(value);
    notifyListeners();
  }

  Future<void> setCarModerationEnabled(bool value) async {
    await _settingsService.setCarModerationEnabled(value);
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String value) async {
    await _settingsService.setSelectedLanguage(value);
    notifyListeners();
  }

  Future<void> setSelectedTheme(String value) async {
    await _settingsService.setSelectedTheme(value);
    notifyListeners();
  }

  Future<void> setItemsPerPage(int value) async {
    await _settingsService.setItemsPerPage(value);
    notifyListeners();
  }

  Future<void> setCommissionRate(double value) async {
    await _settingsService.setCommissionRate(value);
    notifyListeners();
  }

  Future<void> setBannerUrl(String? value) async {
    await _settingsService.setBannerUrl(value);
    notifyListeners();
  }

  Future<void> setSupportedCountries(List<String> value) async {
    await _settingsService.setSupportedCountries(value);
    notifyListeners();
  }

  Future<void> setCategories(List<String> value) async {
    await _settingsService.setCategories(value);
    notifyListeners();
  }

  Future<void> saveSettings(AdminSettings newSettings) async {
    await _settingsService.saveSettings(newSettings);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _settingsService.resetToDefaults();
    notifyListeners();
  }
}
