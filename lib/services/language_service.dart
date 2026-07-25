import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('ru');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  LanguageService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ru';
    _locale = Locale(languageCode);
    _themeMode = _themeModeFromName(prefs.getString('theme_mode'));
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
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
