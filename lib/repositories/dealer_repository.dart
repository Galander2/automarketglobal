import '../data/dealer_data.dart';
import '../models/dealer.dart';

class DealerRepository {
  const DealerRepository();

  List<Dealer> getAllDealers() {
    return List<Dealer>.from(dealers);
  }

  List<Dealer> getVerifiedDealers() {
    return dealers.where((dealer) => dealer.isVerified).toList();
  }

  List<Dealer> searchDealers(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      return getAllDealers();
    }

    return dealers.where((dealer) {
      final text = [
        dealer.name,
        dealer.country,
        dealer.city,
        dealer.description,
        dealer.deliveryCountries.join(' '),
        dealer.rating.toString(),
        dealer.carsCount.toString(),
      ].join(' ').toLowerCase();

      return text.contains(value);
    }).toList();
  }
}
