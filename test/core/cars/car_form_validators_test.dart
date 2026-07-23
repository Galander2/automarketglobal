import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/core/cars/car_form_validators.dart';

void main() {
  group('CarFormValidators', () {
    test('accepts valid car fields', () {
      expect(CarFormValidators.title('Toyota Camry'), isNull);
      expect(CarFormValidators.price('25 000'), isNull);
      expect(CarFormValidators.year('2025', currentYear: 2026), isNull);
      expect(CarFormValidators.mileage('42 000'), isNull);
      expect(CarFormValidators.city('Душанбе'), isNull);
      expect(
        CarFormValidators.description('Автомобиль в хорошем состоянии'),
        isNull,
      );
      expect(CarFormValidators.vin('JTDBF3FG500123456'), isNull);
    });

    test('rejects invalid numeric values', () {
      expect(CarFormValidators.price('0'), isNotNull);
      expect(CarFormValidators.price('abc'), isNotNull);
      expect(CarFormValidators.year('1800', currentYear: 2026), isNotNull);
      expect(CarFormValidators.year('2030', currentYear: 2026), isNotNull);
      expect(CarFormValidators.mileage('-1'), isNotNull);
    });

    test('rejects malformed VIN but allows an empty VIN', () {
      expect(CarFormValidators.vin(''), isNull);
      expect(CarFormValidators.vin('SHORT'), isNotNull);
      expect(CarFormValidators.vin('JTDBF3FG50012345I'), isNotNull);
    });
  });
}
