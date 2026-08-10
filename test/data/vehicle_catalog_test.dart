import 'package:flutter_application_1_car_sales/data/vehicle_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog exposes unique sorted makes', () {
    final makes = VehicleCatalog.makes;

    expect(makes, isNotEmpty);
    expect(makes.toSet().length, makes.length);
    expect(makes, containsAll(['BMW', 'Mercedes-Benz', 'Toyota']));
  });

  test('BMW catalog contains requested generations and models', () {
    final models = VehicleCatalog.modelsFor('BMW');

    expect(models, containsAll(['5 Series (F10)', 'M5 (F90)', 'X5']));
  });

  test('year catalog includes current year and remains descending', () {
    final years = VehicleCatalog.years;

    expect(years, contains(DateTime.now().year));
    expect(years.first, DateTime.now().year + 1);
    expect(years.last, 1886);
  });
}
