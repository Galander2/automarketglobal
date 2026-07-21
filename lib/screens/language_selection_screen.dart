import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLocale = languageService.locale.languageCode;

    final languages = [
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'tj', 'name': 'Тоҷикӣ', 'flag': '🇹'},
      {'code': 'uz', 'name': 'O\'zbek', 'flag': '🇿'},
      {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
      {'code': 'ky', 'name': 'Кыргызча', 'flag': '🇰🇬'},
      {'code': 'kk', 'name': 'Қазақша', 'flag': '🇿'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Выберите язык'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = currentLocale == lang['code'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Text(
                lang['flag'] as String,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                lang['name'] as String,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2563EB) : Colors.black,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF2563EB))
                  : null,
              onTap: () {
                languageService.setLocale(Locale(lang['code'] as String));
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
