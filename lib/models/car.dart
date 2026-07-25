enum CarStatus { pending, approved, rejected, sold, draft }

class Car {
  final String id;
  final String sellerId;
  final String title;
  final String price;
  final int year;
  final int mileage;
  final String city;
  final String route;
  final String country;
  final CarStatus status;
  final String imageUrl;
  final List<String> images;
  final String description;
  final String vin;
  final String make;
  final String model;
  final String transmission;
  final String bodyType;
  final String fuelType;
  final DateTime createdAt;

  const Car({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.price,
    required this.year,
    required this.mileage,
    required this.city,
    required this.route,
    required this.country,
    required this.status,
    required this.imageUrl,
    this.images = const [],
    this.description = '',
    this.vin = '',
    this.make = '',
    this.model = '',
    this.transmission = '',
    this.bodyType = '',
    this.fuelType = '',
    required this.createdAt,
  });

  bool get isPending => status == CarStatus.pending;
  bool get isApproved => status == CarStatus.approved;
  bool get isRejected => status == CarStatus.rejected;
  bool get isSold => status == CarStatus.sold;
}
