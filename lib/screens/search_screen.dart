import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../models/car.dart';
import '../repositories/auth_repository.dart';
import '../repositories/car_repository.dart';
import '../widgets/car_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _countries = <String>[
    'Все',
    'Таджикистан',
    'Узбекистан',
    'Казахстан',
    'Кыргызстан',
  ];

  final TextEditingController _searchController = TextEditingController();
  final CarRepository _carRepository = CarRepository();

  Timer? _debounce;
  List<Car> _cars = const [];
  String _selectedCountry = _countries.first;
  String? _error;
  bool _isLoading = true;
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadCars);
  }

  Future<void> _loadCars({bool forceRefresh = false}) async {
    final generation = ++_requestGeneration;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final cars = await _carRepository.searchCars(
        query: _searchController.text,
        country: _selectedCountry == _countries.first
            ? null
            : _selectedCountry,
        forceRefresh: forceRefresh,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
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
            tooltip: 'Фильтры',
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.searchFilters,
              );
              if (result != null) await _loadCars();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _scheduleSearch,
              onSubmitted: (_) => _loadCars(),
              decoration: InputDecoration(
                hintText: 'Марка, модель или город',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Очистить',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadCars();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _countries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final country = _countries[index];
                return ChoiceChip(
                  label: Text(country),
                  selected: _selectedCountry == country,
                  onSelected: (_) {
                    if (_selectedCountry == country) return;
                    setState(() => _selectedCountry = country);
                    _loadCars();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final userId = context.read<AuthProvider?>()?.currentUser?.uid;
    if (_isLoading && _cars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _cars.isEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        actionLabel: 'Повторить',
        onAction: () => _loadCars(forceRefresh: true),
      );
    }

    if (_cars.isEmpty) {
      return const _MessageState(
        icon: Icons.search_off,
        message: 'По вашему запросу ничего не найдено',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadCars(forceRefresh: true),
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _cars.length,
        itemBuilder: (context, index) {
          final car = _cars[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CarCard(
              key: ValueKey(car.id),
              car: car,
              favoriteUserId: userId,
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
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
