import 'package:flutter_application_1_car_sales/core/cars/vin_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VinValidator', () {
    test('normalizes spaces and lowercase characters', () {
      expect(
        VinValidator.normalize('1hg cm826 33a004352'),
        '1HGCM82633A004352',
      );
    });

    test('accepts a structurally valid VIN', () {
      expect(VinValidator.isValid('1HGCM82633A004352'), isTrue);
    });

    test('rejects forbidden VIN letters', () {
      expect(VinValidator.isValid('1HGCM82633A00I352'), isFalse);
      expect(VinValidator.isValid('1HGCM82633A00O352'), isFalse);
      expect(VinValidator.isValid('1HGCM82633A00Q352'), isFalse);
    });

    test('rejects a VIN with the wrong length', () {
      expect(VinValidator.isValid('1HGCM82633A00435'), isFalse);
    });
  });
}
