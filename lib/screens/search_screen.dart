import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../models/car.dart';
import '../models/car_search_filters.dart';
import '../repositories/auth_repository.dart';
import '../repositories/car_repository.dart';
import '../widgets/car_card.dart';
import 'vehicle_catalog_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CarRepository _carRepository = CarRepository();

  Timer? _debounce;
  List<Car> _cars = const [];
  CarSearchFilters _filters = const CarSearchFilters();
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
    setState(() {});
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
        filters: _filters,
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

  Future<void> _openFilters() async {
    final result = await Navigator.pushNamed<CarSearchFilters>(
      context,
      AppRoutes.searchFilters,
      arguments: _filters,
    );
    if (!mounted || result == null) return;
    setState(() => _filters = result);
    await _loadCars();
  }

  Future<void> _openVehicleCatalog() async {
    final result = await Navigator.of(context).push<CarSearchFilters>(
      MaterialPageRoute(
        builder: (_) => VehicleCatalogScreen(initialFilters: _filters),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _filters = result);
    await _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('search')),
        centerTitle: true,
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
          if (_filters.activeCount > 0)
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Сбросить фильтры'),
                    onPressed: () {
                      setState(() => _filters = const CarSearchFilters());
                      _loadCars();
                    },
                  ),
                  ..._filterLabels().map(
                    (label) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Chip(label: Text(label)),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? 'Поиск…' : 'Найдено: ${_cars.length}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    children: [
                      TextButton.icon(
                        onPressed: _openFilters,
                        icon: Badge(
                          isLabelVisible: _filters.activeCount > 0,
                          label: Text('${_filters.activeCount}'),
                          child: const Icon(Icons.tune_rounded, size: 18),
                        ),
                        label: const Text('Все фильтры'),
                      ),
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: _openVehicleCatalog,
                        icon: const Icon(
                          Icons.directions_car_filled_outlined,
                          size: 18,
                        ),
                        label: const Text('Автомобили'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        return RefreshIndicator(
          onRefresh: () => _loadCars(forceRefresh: true),
          child: GridView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: _cars.length,
            itemBuilder: (context, index) {
              final car = _cars[index];
              return CarCard(
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
              );
            },
          ),
        );
      },
    );
  }

  List<String> _filterLabels() {
    final labels = <String>[];
    if (_filters.make.isNotEmpty) labels.add(_filters.make);
    if (_filters.model.isNotEmpty) labels.add(_filters.model);
    if (_filters.country.isNotEmpty) labels.add(_filters.country);
    if (_filters.city.isNotEmpty) labels.add(_filters.city);
    if (_filters.transmission.isNotEmpty) {
      labels.add(_filters.transmission);
    }
    if (_filters.bodyType.isNotEmpty) labels.add(_filters.bodyType);
    if (_filters.fuelType.isNotEmpty) labels.add(_filters.fuelType);
    if (_filters.minPrice != null || _filters.maxPrice != null) {
      labels.add(
        '\$${_filters.minPrice ?? 0}–${_filters.maxPrice ?? '∞'}',
      );
    }
    if (_filters.minYear != null || _filters.maxYear != null) {
      labels.add('${_filters.minYear ?? '…'}–${_filters.maxYear ?? '…'} г.');
    }
    if (_filters.maxMileage != null) {
      labels.add('до ${_filters.maxMileage} км');
    }
    return labels;
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
