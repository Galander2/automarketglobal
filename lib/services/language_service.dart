import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_extra_translations.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('ru');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  LanguageService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('language_code') ?? 'ru';
      final languageCode =
          AppExtraTranslations.supportedCodes.contains(savedCode)
              ? savedCode
              : 'ru';
      _locale = Locale(languageCode);
      _themeMode = _themeModeFromName(prefs.getString('theme_mode'));
      notifyListeners();
    } catch (_) {
      // Keep safe in-memory defaults when local storage is unavailable.
    }
  }

  Future<void> setLocale(Locale locale) async {
    final languageCode = locale.languageCode;
    if (!AppExtraTranslations.supportedCodes.contains(languageCode)) return;
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (_) {
      // The selected locale remains active for the current session.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }

  static ThemeMode _themeModeFromName(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'tj':
        return 'Тоҷикӣ';
      case 'uz':
        return 'O\'zbek';
      case 'zh':
        return '中文';
      case 'ky':
        return 'Кыргызча';
      case 'kk':
        return 'Қазақша';
      case 'ar':
        return 'العربية';
      case 'ko':
        return '한국어';
      default:
        return 'Русский';
    }
  }
}
