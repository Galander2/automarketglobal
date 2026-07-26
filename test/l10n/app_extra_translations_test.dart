import 'package:flutter_application_1_car_sales/l10n/app_extra_translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported locale contains the same non-empty translations', () {
    const requiredKeys = <String>{
      'selectLanguage',
      'searchHint',
      'clear',
      'resetFilters',
      'searching',
      'found',
      'allFilters',
      'vehicles',
      'nothingFound',
      'tryAgain',
      'loadFailed',
    };

    for (final languageCode in AppExtraTranslations.supportedCodes) {
      final translations = AppExtraTranslations.forLocale(languageCode);

      expect(
        translations.keys.toSet(),
        requiredKeys,
        reason: 'Translation keys differ for locale $languageCode',
      );
      expect(
        translations.values.every((value) => value.trim().isNotEmpty),
        isTrue,
        reason: 'Locale $languageCode contains an empty translation',
      );
    }
  });
}
