enum CarSortOrder {
  relevance,
  newest,
  priceLowToHigh,
  priceHighToLow,
  yearNewest,
  mileageLowest,
}

class CarSearchFilters {
  const CarSearchFilters({
    this.make = '',
    this.model = '',
    this.country = '',
    this.city = '',
    this.transmission = '',
    this.bodyType = '',
    this.fuelType = '',
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxMileage,
    this.sortOrder = CarSortOrder.relevance,
  });

  final String make;
  final String model;
  final String country;
  final String city;
  final String transmission;
  final String bodyType;
  final String fuelType;
  final int? minPrice;
  final int? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? maxMileage;
  final CarSortOrder sortOrder;

  int get activeCount => [
    make,
    model,
    country,
    city,
    transmission,
    bodyType,
    fuelType,
    minPrice,
    maxPrice,
    minYear,
    maxYear,
    maxMileage,
  ].where((value) => value != null && value.toString().trim().isNotEmpty).length;

  bool get isEmpty =>
      activeCount == 0 && sortOrder == CarSortOrder.relevance;
}
