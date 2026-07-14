import 'package:flutter/foundation.dart';
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
