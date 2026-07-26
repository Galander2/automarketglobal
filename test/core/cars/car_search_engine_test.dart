import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/core/cars/car_search_engine.dart';
import 'package:flutter_application_1_car_sales/models/car.dart';
import 'package:flutter_application_1_car_sales/models/car_search_filters.dart';

void main() {
  final camry = _car(
    id: 'camry',
    title: 'Toyota Camry 70',
    make: 'Toyota',
    model: 'Camry',
    year: 2022,
    price: '25000',
    mileage: 30000,
    city: 'Душанбе',
    transmission: 'Автомат',
    bodyType: 'Седан',
    fuelType: 'Бензин',
  );
  final rav4 = _car(
    id: 'rav4',
    title: 'Toyota RAV4',
    make: 'Toyota',
    model: 'RAV4',
    year: 2020,
    price: '31000',
    mileage: 54000,
    city: 'Худжанд',
    transmission: 'Автомат',
    bodyType: 'Кроссовер',
    fuelType: 'Гибрид',
  );

  test('smart query matches all words regardless of their order', () {
    final result = CarSearchEngine.apply(
      [rav4, camry],
      query: 'душанбе camry',
    );

    expect(result.map((car) => car.id), ['camry']);
  });

  test('combines vehicle, price, year and mileage filters', () {
    final result = CarSearchEngine.apply(
      [rav4, camry],
      filters: const CarSearchFilters(
        make: 'toyota',
        transmission: 'Автомат',
        bodyType: 'Седан',
        fuelType: 'Бензин',
        minPrice: 20000,
        maxPrice: 28000,
        minYear: 2021,
        maxMileage: 40000,
      ),
    );

    expect(result.map((car) => car.id), ['camry']);
  });

  test('sorts matching cars by price', () {
    final result = CarSearchEngine.apply(
      [rav4, camry],
      filters: const CarSearchFilters(
        sortOrder: CarSortOrder.priceHighToLow,
      ),
    );

    expect(result.map((car) => car.id), ['rav4', 'camry']);
  });

  test('exact catalog year returns only listings from that year', () {
    final result = CarSearchEngine.apply(
      [rav4, camry],
      filters: const CarSearchFilters(
        make: 'Toyota',
        minYear: 2022,
        maxYear: 2022,
      ),
    );

    expect(result.map((car) => car.id), ['camry']);
  });

  test('legacy listings remain searchable by title', () {
    final legacy = _car(
      id: 'legacy',
      title: 'Mercedes-Benz E 200',
      make: '',
      model: '',
      year: 2019,
      price: '22000',
      mileage: 80000,
      city: 'Душанбе',
      transmission: '',
      bodyType: '',
      fuelType: '',
    );

    final result = CarSearchEngine.apply(
      [legacy],
      filters: const CarSearchFilters(make: 'Mercedes', model: 'E 200'),
    );

    expect(result.single.id, 'legacy');
  });
}

Car _car({
  required String id,
  required String title,
  required String make,
  required String model,
  required int year,
  required String price,
  required int mileage,
  required String city,
  required String transmission,
  required String bodyType,
  required String fuelType,
}) {
  return Car(
    id: id,
    sellerId: 'seller',
    title: title,
    price: price,
    year: year,
    mileage: mileage,
    city: city,
    route: '',
    country: 'Таджикистан',
    status: CarStatus.approved,
    imageUrl: 'https://example.com/car.jpg',
    make: make,
    model: model,
    transmission: transmission,
    bodyType: bodyType,
    fuelType: fuelType,
    createdAt: DateTime.utc(year),
  );
}
