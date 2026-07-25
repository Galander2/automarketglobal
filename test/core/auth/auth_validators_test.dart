import 'package:flutter_application_1_car_sales/core/auth/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('validates email format', () {
      expect(AuthValidators.email('user@example.com'), isNull);
      expect(AuthValidators.email('invalid'), isNotNull);
    });

    test('requires a strong registration password', () {
      expect(AuthValidators.password('secure123'), isNull);
      expect(AuthValidators.password('short1'), isNotNull);
      expect(AuthValidators.password('onlyletters'), isNotNull);
    });

    test('accepts an international phone', () {
      expect(AuthValidators.phone('+992 900 00 00 00'), isNull);
      expect(AuthValidators.phone('123'), isNotNull);
    });

    test('validates multilingual profile names', () {
      expect(AuthValidators.name('Ахмад', 'имя'), isNull);
      expect(AuthValidators.name("O'Connor", 'фамилию'), isNull);
      expect(AuthValidators.name('李明', 'имя'), isNull);
      expect(AuthValidators.name('A', 'имя'), isNotNull);
      expect(AuthValidators.name('User_123', 'имя'), isNotNull);
    });

    test('validates optional country and city', () {
      expect(AuthValidators.optionalPlace('', 'Город'), isNull);
      expect(
        AuthValidators.optionalPlace('Душанбе', 'Город'),
        isNull,
      );
      expect(
        AuthValidators.optionalPlace('City<script>', 'Город'),
        isNotNull,
      );
    });

    test('normalizes phone before saving', () {
      expect(
        AuthValidators.normalizePhone('+992 (900) 00-00-00'),
        '+992900000000',
      );
    });
  });
}
