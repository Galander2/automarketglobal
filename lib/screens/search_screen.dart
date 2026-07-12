import 'package:flutter/material.dart';
import 'package:flutter_application_1_car_sales/l10n/app_localizations.dart';
import 'package:flutter_application_1_car_sales/core/router/app_routes.dart';
import 'package:flutter_application_1_car_sales/models/car.dart';
import 'package:flutter_application_1_car_sales/widgets/car_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCountry = 'All';

  final List<Car> _cars = [
    Car(
      id: '1',
      sellerId: 'seller1',
      title: 'Toyota Camry 2020',
      price: '25000',
      year: 2020,
      mileage: 45000,
      city: 'Dushanbe',
      route: 'Korea -> Tajikistan',
      country: 'Tajikistan',
      status: CarStatus.approved,
      imageUrl: 'https://example.com/camry.jpg',
      createdAt: DateTime.now(),
      description: 'Excellent condition',
      vin: '1HGBH41JXMN109186',
    ),
    Car(
      id: '2',
      sellerId: 'seller2',
      title: 'Honda Accord 2019',
      price: '23000',
      year: 2019,
      mileage: 52000,
      city: 'Tashkent',
      route: 'Japan -> Uzbekistan',
      country: 'Uzbekistan',
      status: CarStatus.approved,
      imageUrl: 'https://example.com/accord.jpg',
      createdAt: DateTime.now(),
      description: 'Full drive',
      vin: '1HGBH41JXMN109187',
    ),
    Car(
      id: '3',
      sellerId: 'seller3',
      title: 'Lexus RX 350 2021',
      price: '45000',
      year: 2021,
      mileage: 28000,
      city: 'Almaty',
      route: 'Korea -> Kazakhstan',
      country: 'Kazakhstan',
      status: CarStatus.approved,
      imageUrl: 'https://example.com/lexus.jpg',
      createdAt: DateTime.now(),
      description: '',
      vin: '1HGBH41JXMN109188',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('search')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.searchFilters,
              );
              if (result != null) {
                // Apply filters
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cars...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Country',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Tajikistan', 'Uzbekistan', 'Kazakhstan', 'Kyrgyzstan']
                  .map((country) {
                final isSelected = _selectedCountry == country;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(country),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCountry = selected ? country : 'All';
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _cars.isEmpty
                ? const Center(
                    child: Text('No cars'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cars.length,
                    itemBuilder: (context, index) {
                      final car = _cars[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CarCard(
                          car: car,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.carDetails,
                              arguments: {'car': car},
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
