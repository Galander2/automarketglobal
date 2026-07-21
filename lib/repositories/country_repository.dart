import '../data/country_data.dart';
import '../models/country.dart';

class CountryRepository {
  const CountryRepository();

  List<Country> getAllCountries() {
    return List<Country>.from(countries);
  }

  Country? getCountryByCode(String code) {
    try {
      return countries.firstWhere(
        (country) => country.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  List<Country> searchCountries(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      return getAllCountries();
    }

    return countries.where((country) {
      final text = [
        country.code,
        country.name,
        country.marketTitle,
      ].join(' ').toLowerCase();

      return text.contains(value);
    }).toList();
  }
}
