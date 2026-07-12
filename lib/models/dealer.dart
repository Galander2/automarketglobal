class Dealer {
  final String id;
  final String name;
  final String country;
  final String city;
  final String description;
  final List<String> deliveryCountries;
  final bool isVerified;
  final double rating;
  final int carsCount;

  const Dealer({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.description,
    required this.deliveryCountries,
    required this.isVerified,
    required this.rating,
    required this.carsCount,
  });
}