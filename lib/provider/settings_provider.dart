import 'package:flutter/foundation.dart';
import '../models/admin_settings.dart';
import '../services/settings_service.dart';

/// Provider для управления состоянием настроек администратора
class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  
  SettingsProvider(this._settingsService) {
    _init();
  }

  bool _isInitialized = false;
  AdminSettings? _settings;
  bool _isLoading = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AdminSettings? get settings => _settings;
  bool get isLoaded => _settings != null;
  
  AdminSettings get cachedSettings => _settings ?? AdminSettings.defaults();

  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get emailNotifications => _settings?.emailNotificationsEnabled ?? true;
  bool get pushNotifications => _settings?.pushNotificationsEnabled ?? true;
  bool get maintenanceMode => _settings?.maintenanceMode ?? false;
  bool get newUserApprovalRequired => _settings?.requireUserVerification ?? false;
  bool get carModerationEnabled => _settings?.moderateListings ?? false;
  String get selectedLanguage => _settings?.language ?? 'ru';
  String get selectedTheme => _settings?.themeMode ?? 'system';
  int get itemsPerPage => _settings?.itemsPerPage ?? 20;

  Future<void> _init() async {
    await _settingsService.initialize();
    _settings = _settingsService.settings;
    _isInitialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsService.dispose();
    super.dispose();
  }

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

      await _settingsService.saveSettingsWithAdmin(newSettings, adminUid);
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
