import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

/// A country-aware mobile phone field used by registration and profile forms.
///
/// Parsing and validation happen locally using libphonenumber metadata. The
/// selected country is therefore authoritative for shared dial codes such as
/// +7 (Russia and Kazakhstan).
class InternationalPhoneField extends StatelessWidget {
  final PhoneNumber initialValue;
  final ValueChanged<PhoneNumber?> onChanged;
  final bool enabled;
  final TextInputAction textInputAction;

  const InternationalPhoneField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
  });

  static PhoneNumber parseOrDefault(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isNotEmpty) {
      try {
        return PhoneNumber.parse(phone);
      } catch (_) {
        // Existing legacy profiles can contain an incomplete phone number.
      }
    }
    return PhoneNumber.parse('+992');
  }

  static String normalized(PhoneNumber phone) =>
      phone.international.replaceAll(RegExp(r'[\s()\-]'), '');

  @override
  Widget build(BuildContext context) {
    final locale = _phoneFieldLocale(Localizations.localeOf(context));

    return Localizations.override(
      context: context,
      locale: locale,
      delegates: PhoneFieldLocalization.delegates.toList(),
      child: Builder(
        builder: (fieldContext) => PhoneFormField(
          initialValue: initialValue,
          enabled: enabled,
          textInputAction: textInputAction,
          autofillHints: const [AutofillHints.telephoneNumber],
          countrySelectorNavigator: const CountrySelectorNavigator.page(),
          countryButtonStyle: const CountryButtonStyle(
            showDialCode: true,
            showIsoCode: true,
            showFlag: true,
            flagSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: 'Телефон',
            hintText: 'Выберите страну и введите номер',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
          ),
          validator: PhoneValidator.compose([
            PhoneValidator.required(
              fieldContext,
              errorText: 'Введите телефон',
            ),
            PhoneValidator.validMobile(
              fieldContext,
              errorText: 'Неверный мобильный номер для выбранной страны',
            ),
          ]),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Locale _phoneFieldLocale(Locale locale) {
    const supportedLanguages = {
      'ar',
      'en',
      'ko',
      'ru',
      'uz',
      'zh',
    };
    return supportedLanguages.contains(locale.languageCode)
        ? locale
        : const Locale('en');
  }
}
