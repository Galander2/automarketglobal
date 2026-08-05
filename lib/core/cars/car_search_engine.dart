import '../../models/car.dart';
import '../../models/car_search_filters.dart';

class CarSearchEngine {
  const CarSearchEngine._();

  static List<Car> apply(
    Iterable<Car> source, {
    String query = '',
    CarSearchFilters filters = const CarSearchFilters(),
  }) {
    final normalizedQuery = _normalize(query);
    final result = source
        .where((car) {
          final price = _parsePrice(car.price);
          return _matchesQuery(car, normalizedQuery) &&
              _contains(
                car.make.isEmpty ? car.title : car.make,
                filters.make,
              ) &&
              _contains(
                car.model.isEmpty ? car.title : car.model,
                filters.model,
              ) &&
              _equals(car.country, filters.country) &&
              _contains(car.city, filters.city) &&
              _equals(car.transmission, filters.transmission) &&
              _equals(car.bodyType, filters.bodyType) &&
              _equals(car.fuelType, filters.fuelType) &&
              (filters.minPrice == null || price >= filters.minPrice!) &&
              (filters.maxPrice == null || price <= filters.maxPrice!) &&
              (filters.minYear == null || car.year >= filters.minYear!) &&
              (filters.maxYear == null || car.year <= filters.maxYear!) &&
              (filters.maxMileage == null ||
                  car.mileage <= filters.maxMileage!);
        })
        .toList(growable: true);

    _sort(result, filters.sortOrder, normalizedQuery);
    return List.unmodifiable(result);
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^a-zа-яқғӣӯҳҷәөұүңһі0-9]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool _contains(String value, String expected) {
    final filter = _normalize(expected);
    return filter.isEmpty || _normalize(value).contains(filter);
  }

  static bool _equals(String value, String expected) {
    final filter = _normalize(expected);
    return filter.isEmpty || _normalize(value) == filter;
  }

  static bool _matchesQuery(Car car, String query) {
    if (query.isEmpty) return true;
    final searchable = _normalize(
      [
        car.title,
        car.make,
        car.model,
        car.year,
        car.city,
        car.country,
        car.transmission,
        car.bodyType,
        car.fuelType,
        car.description,
      ].join(' '),
    );
    return query.split(' ').every(searchable.contains);
  }

  static int _relevanceScore(Car car, String query) {
    if (query.isEmpty) return 0;
    final title = _normalize(car.title);
    final makeModel = _normalize('${car.make} ${car.model}');
    var score = 0;
    if (title == query || makeModel == query) score += 100;
    if (title.startsWith(query) || makeModel.startsWith(query)) score += 50;
    for (final token in query.split(' ')) {
      if (title.contains(token)) score += 12;
      if (makeModel.contains(token)) score += 16;
      if (_normalize(car.city).contains(token)) score += 4;
      if (_normalize(car.country).contains(token)) score += 3;
    }
    return score;
  }

  static void _sort(List<Car> cars, CarSortOrder order, String query) {
    switch (order) {
      case CarSortOrder.relevance:
        if (query.isEmpty) {
          cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          cars.sort((a, b) {
            final score = _relevanceScore(b, query) - _relevanceScore(a, query);
            return score != 0 ? score : b.createdAt.compareTo(a.createdAt);
          });
        }
        return;
      case CarSortOrder.newest:
        cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return;
      case CarSortOrder.priceLowToHigh:
        cars.sort(
          (a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)),
        );
        return;
      case CarSortOrder.priceHighToLow:
        cars.sort(
          (a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)),
        );
        return;
      case CarSortOrder.yearNewest:
        cars.sort((a, b) => b.year.compareTo(a.year));
        return;
      case CarSortOrder.mileageLowest:
        cars.sort((a, b) => a.mileage.compareTo(b.mileage));
        return;
    }
  }

  static double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }
}
