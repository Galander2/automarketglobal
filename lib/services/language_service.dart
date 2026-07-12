import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('ru');
  
  Locale get locale => _locale;

  LanguageService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ru';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
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