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
import '../models/admin_settings.dart';
import '../services/settings_service.dart';

/// Provider для управления состоянием настроек администратора
class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  AdminSettings? _settings;
  bool _isLoading = false;
  String? _error;

  AdminSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoaded => _settings != null;

  /// Загрузить настройки из Firestore
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _settings = await _settingsService.getSettings();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Сохранить настройки в Firestore
  Future<void> saveSettings(AdminSettings newSettings, String adminUid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _settingsService.saveSettings(newSettings, adminUid);
      _settings = newSettings.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Сбросить настройки к значениям по умолчанию
  Future<void> resetSettings(String adminUid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _settingsService.resetSettings(adminUid);
      _settings = AdminSettings.defaults().copyWith(
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Обновить отдельное поле настроек
  Future<void> updateField<T>(
    String field,
    T value,
    String adminUid,
  ) async {
    if (_settings == null) return;

    AdminSettings updated;
    
    switch (field) {
      case 'notificationsEnabled':
        updated = _settings!.copyWith(notificationsEnabled: value as bool);
        break;
      case 'emailNotificationsEnabled':
        updated = _settings!.copyWith(emailNotificationsEnabled: value as bool);
        break;
      case 'pushNotificationsEnabled':
        updated = _settings!.copyWith(pushNotificationsEnabled: value as bool);
        break;
      case 'maintenanceMode':
        updated = _settings!.copyWith(maintenanceMode: value as bool);
        break;
      case 'requireUserVerification':
        updated = _settings!.copyWith(requireUserVerification: value as bool);
        break;
      case 'moderateListings':
        updated = _settings!.copyWith(moderateListings: value as bool);
        break;
      case 'language':
        updated = _settings!.copyWith(language: value as String);
        break;
      case 'themeMode':
        updated = _settings!.copyWith(themeMode: value as String);
        break;
      case 'itemsPerPage':
        updated = _settings!.copyWith(itemsPerPage: value as int);
        break;
      default:
        return;
    }

    await saveSettings(updated, adminUid);
  }
}
