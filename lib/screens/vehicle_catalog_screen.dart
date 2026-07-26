import 'package:flutter/material.dart';

import '../data/vehicle_catalog.dart';
import '../models/car_search_filters.dart';

class VehicleCatalogScreen extends StatefulWidget {
  const VehicleCatalogScreen({super.key, required this.initialFilters});

  final CarSearchFilters initialFilters;

  @override
  State<VehicleCatalogScreen> createState() => _VehicleCatalogScreenState();
}

class _VehicleCatalogScreenState extends State<VehicleCatalogScreen> {
  final _brandSearch = TextEditingController();
  late String _make;
  late String _model;
  int? _year;

  @override
  void initState() {
    super.initState();
    _make = VehicleCatalog.modelsByMake.containsKey(widget.initialFilters.make)
        ? widget.initialFilters.make
        : '';
    final models = VehicleCatalog.modelsFor(_make);
    _model = models.contains(widget.initialFilters.model)
        ? widget.initialFilters.model
        : '';
    _year = widget.initialFilters.minYear != null &&
            widget.initialFilters.minYear == widget.initialFilters.maxYear
        ? widget.initialFilters.minYear
        : null;
    _brandSearch.addListener(_refresh);
  }

  @override
  void dispose() {
    _brandSearch
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<String> get _visibleMakes {
    final query = _brandSearch.text.trim().toLowerCase();
    if (query.isEmpty) return VehicleCatalog.makes;
    return VehicleCatalog.makes
        .where((make) => make.toLowerCase().contains(query))
        .toList(growable: false);
  }

  CarSearchFilters _result() {
    final value = widget.initialFilters;
    return CarSearchFilters(
      make: _make,
      model: _model,
      country: value.country,
      city: value.city,
      transmission: value.transmission,
      bodyType: value.bodyType,
      fuelType: value.fuelType,
      minPrice: value.minPrice,
      maxPrice: value.maxPrice,
      minYear: _year,
      maxYear: _year,
      maxMileage: value.maxMileage,
      sortOrder: value.sortOrder,
    );
  }

  void _selectMake(String make) {
    _brandSearch.clear();
    setState(() {
      _make = make;
      _model = '';
      _year = null;
    });
  }

  void _clearVehicle() {
    setState(() {
      _make = '';
      _model = '';
      _year = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все автомобили'),
        actions: [
          if (_make.isNotEmpty)
            TextButton(onPressed: _clearVehicle, child: const Text('Сбросить')),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _make.isEmpty ? _buildMakes() : _buildVehicleOptions(),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMakes() {
    final makes = _visibleMakes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _brandSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Марка автомобиля',
              hintText: 'Например, BMW или Toyota',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _brandSearch.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Очистить',
                      onPressed: _brandSearch.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Text(
            'Выберите марку',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: makes.isEmpty
              ? const Center(child: Text('Марка не найдена'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 600
                        ? 3
                        : 2;
                    return GridView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: makes.length,
                      itemBuilder: (context, index) {
                        final make = makes[index];
                        return OutlinedButton(
                          onPressed: () => _selectMake(make),
                          child: Text(
                            make,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVehicleOptions() {
    final models = VehicleCatalog.modelsFor(_make);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.directions_car_filled_rounded),
            ),
            title: Text(
              _make,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Нажмите, чтобы выбрать другую марку'),
            trailing: const Icon(Icons.swap_horiz_rounded),
            onTap: _clearVehicle,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Модель',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _model,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.category_outlined),
            labelText: 'Выберите модель',
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('Все модели')),
            ...models.map(
              (model) => DropdownMenuItem(value: model, child: Text(model)),
            ),
          ],
          onChanged: (value) => setState(() => _model = value ?? ''),
        ),
        const SizedBox(height: 22),
        Text(
          'Год выпуска',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: _year,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.calendar_month_outlined),
            labelText: 'Точный год',
          ),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Все годы'),
            ),
            ...VehicleCatalog.years.map(
              (year) => DropdownMenuItem<int>(
                value: year,
                child: Text('$year'),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _year = value),
        ),
        const SizedBox(height: 16),
        Text(
          _year == null
              ? 'Будут показаны объявления любого года.'
              : 'Будут показаны только объявления $_year года.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    final title = _make.isEmpty
        ? 'Показать все автомобили'
        : [
            _make,
            if (_model.isNotEmpty) _model,
            if (_year != null) _year,
          ].join(' • ');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: () => Navigator.pop(context, _result()),
          icon: const Icon(Icons.search_rounded),
          label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
