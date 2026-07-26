import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../widgets/app_hover_lift.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLocale = languageService.locale.languageCode;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    const languages = [
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'tj', 'name': 'Тоҷикӣ', 'flag': '🇹🇯'},
      {'code': 'uz', 'name': 'O\'zbek', 'flag': '🇺🇿'},
      {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
      {'code': 'ky', 'name': 'Кыргызча', 'flag': '🇰🇬'},
      {'code': 'kk', 'name': 'Қазақша', 'flag': '🇰🇿'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('selectLanguage')),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = currentLocale == lang['code'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppHoverLift(
              borderRadius: BorderRadius.circular(18),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  leading: Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.primary,
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await languageService.setLocale(Locale(lang['code']!));
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
