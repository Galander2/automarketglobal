import 'package:flutter/material.dart';
import 'package:flutter_application_1_car_sales/widgets/international_phone_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_form_field/phone_form_field.dart';

void main() {
  test('normalizes a parsed international number for storage', () {
    final phone = PhoneNumber.parse('+992 900 00 00 00');

    expect(
      InternationalPhoneField.normalized(phone),
      '+992900000000',
    );
  });

  test('falls back safely when a legacy profile phone is malformed', () {
    final phone = InternationalPhoneField.parseOrDefault('not-a-phone');

    expect(phone.countryCode, '992');
  });

  test('distinguishes Russia and Kazakhstan despite their shared +7 code', () {
    final russian = PhoneNumber.parse('+7 912 345 67 89');
    final kazakh = PhoneNumber.parse('+7 701 123 45 67');

    expect(russian.isoCode, IsoCode.RU);
    expect(kazakh.isoCode, IsoCode.KZ);
    expect(russian.isValid(type: PhoneNumberType.mobile), isTrue);
    expect(kazakh.isValid(type: PhoneNumberType.mobile), isTrue);
  });

  testWidgets('requires a valid mobile number for the selected country', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InternationalPhoneField(
              initialValue: PhoneNumber.parse('+992'),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Введите телефон'), findsOneWidget);
  });
}
