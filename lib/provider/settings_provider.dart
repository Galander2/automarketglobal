import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/admin_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  AdminSettings? _settings;
  bool _isLoading = false;
  String? _error;

  SettingsProvider(this._settingsService);

  AdminSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoaded => _settings != null;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _settingsService.getSettings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  StreamSubscription<AdminSettings>? _subscription;

  void watchSettingsStream() {
    _subscription = _settingsService.watchSettings().listen(
      (settings) {
        _settings = settings;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> saveSettings(AdminSettings settings, String adminUid) async {
    await _settingsService.saveSettings(settings, adminUid);
    _settings = settings.copyWith(
      updatedAt: DateTime.now(),
      updatedBy: adminUid,
    );
    notifyListeners();
  }

  Future<void> updateField(String field, dynamic value, String adminUid) async {
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

  Future<void> resetSettings(String adminUid) async {
    await _settingsService.resetSettings(adminUid);
    _settings = AdminSettings.defaults().copyWith(
      updatedAt: DateTime.now(),
      updatedBy: adminUid,
    );
    notifyListeners();
  }
}
