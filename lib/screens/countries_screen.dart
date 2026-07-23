import 'package:flutter/material.dart';
import '../repositories/car_repository.dart';
import '../models/car.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class CountriesScreen extends StatelessWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final countries = [
      {'name': 'Таджикистан', 'flag': '🇹🇯'},
      {'name': 'Узбекистан', 'flag': '🇺🇿'},
      {'name': 'Казахстан', 'flag': '🇰🇿'},
      {'name': 'Кыргызстан', 'flag': '🇰🇬'},
      {'name': 'Туркменистан', 'flag': '🇹🇲'},
      {'name': 'Азербайджан', 'flag': '🇦🇿'},
      {'name': 'Грузия', 'flag': '🇬🇪'},
      {'name': 'ОАЭ (Дубай)', 'flag': '🇦🇪'},
      {'name': 'Китай', 'flag': '🇨🇳'},
      {'name': 'Южная Корея', 'flag': '🇰🇷'},
      {'name': 'Япония', 'flag': '🇯🇵'},
      {'name': 'США', 'flag': '🇺🇸'},
      {'name': 'Германия', 'flag': '🇩🇪'},
      {'name': 'Франция', 'flag': '🇫🇷'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Выберите страну'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CountryMarketScreen(
                      countryName: country['name'] as String,
                      countryFlag: country['flag'] as String,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      country['flag'] as String,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country['name'] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Открыть рынок автомобилей',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CountryMarketScreen extends StatefulWidget {
  final String countryName;
  final String countryFlag;

  const CountryMarketScreen({
    super.key,
    required this.countryName,
    required this.countryFlag,
  });

  @override
  State<CountryMarketScreen> createState() => _CountryMarketScreenState();
}

class _CountryMarketScreenState extends State<CountryMarketScreen> {
  final CarRepository _carRepository = CarRepository();
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = _carRepository.getCarsByCountry(widget.countryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.countryFlag} ${widget.countryName}'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Car>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final cars = snapshot.data ?? [];

          if (cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.countryFlag,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'В ${widget.countryName} пока нет автомобилей',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Назад к странам'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarDetailsScreen(car: car),
                      ),
                    );
                  },
                  child: CarCard(car: car),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
