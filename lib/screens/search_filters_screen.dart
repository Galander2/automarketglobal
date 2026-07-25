import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/car_search_filters.dart';

class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({
    super.key,
    this.initialFilters = const CarSearchFilters(),
  });

  final CarSearchFilters initialFilters;

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  static const countries = [
    'Таджикистан',
    'Узбекистан',
    'Казахстан',
    'Кыргызстан',
    'Туркменистан',
    'Азербайджан',
    'Грузия',
    'ОАЭ',
    'Китай',
    'Южная Корея',
    'Япония',
    'США',
    'Германия',
    'Франция',
    'Италия',
    'Великобритания',
  ];
  static const transmissions = [
    'Автомат',
    'Механика',
    'Вариатор',
    'Робот',
  ];
  static const bodyTypes = [
    'Седан',
    'Кроссовер',
    'Внедорожник',
    'Хэтчбек',
    'Универсал',
    'Купе',
    'Минивэн',
    'Пикап',
    'Кабриолет',
  ];
  static const fuelTypes = [
    'Бензин',
    'Дизель',
    'Гибрид',
    'Электро',
    'Газ',
  ];

  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _city;
  late final TextEditingController _minPrice;
  late final TextEditingController _maxPrice;
  late final TextEditingController _minYear;
  late final TextEditingController _maxYear;
  late final TextEditingController _maxMileage;
  String _country = '';
  String _transmission = '';
  String _bodyType = '';
  String _fuelType = '';
  CarSortOrder _sortOrder = CarSortOrder.relevance;

  @override
  void initState() {
    super.initState();
    final value = widget.initialFilters;
    _make = TextEditingController(text: value.make);
    _model = TextEditingController(text: value.model);
    _city = TextEditingController(text: value.city);
    _minPrice = _numberController(value.minPrice);
    _maxPrice = _numberController(value.maxPrice);
    _minYear = _numberController(value.minYear);
    _maxYear = _numberController(value.maxYear);
    _maxMileage = _numberController(value.maxMileage);
    _country = value.country;
    _transmission = value.transmission;
    _bodyType = value.bodyType;
    _fuelType = value.fuelType;
    _sortOrder = value.sortOrder;
  }

  TextEditingController _numberController(int? value) =>
      TextEditingController(text: value?.toString() ?? '');

  @override
  void dispose() {
    for (final controller in [
      _make,
      _model,
      _city,
      _minPrice,
      _maxPrice,
      _minYear,
      _maxYear,
      _maxMileage,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _number(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

  CarSearchFilters get _filters => CarSearchFilters(
    make: _make.text.trim(),
    model: _model.text.trim(),
    country: _country,
    city: _city.text.trim(),
    transmission: _transmission,
    bodyType: _bodyType,
    fuelType: _fuelType,
    minPrice: _number(_minPrice),
    maxPrice: _number(_maxPrice),
    minYear: _number(_minYear),
    maxYear: _number(_maxYear),
    maxMileage: _number(_maxMileage),
    sortOrder: _sortOrder,
  );

  void _reset() {
    for (final controller in [
      _make,
      _model,
      _city,
      _minPrice,
      _maxPrice,
      _minYear,
      _maxYear,
      _maxMileage,
    ]) {
      controller.clear();
    }
    setState(() {
      _country = '';
      _transmission = '';
      _bodyType = '';
      _fuelType = '';
      _sortOrder = CarSortOrder.relevance;
    });
  }

  void _apply() {
    final filters = _filters;
    if (filters.minPrice != null &&
        filters.maxPrice != null &&
        filters.minPrice! > filters.maxPrice!) {
      _showError('Минимальная цена не может быть больше максимальной');
      return;
    }
    if (filters.minYear != null &&
        filters.maxYear != null &&
        filters.minYear! > filters.maxYear!) {
      _showError('Начальный год не может быть больше конечного');
      return;
    }
    final maximumYear = DateTime.now().year + 1;
    if ((filters.minYear != null &&
            (filters.minYear! < 1886 || filters.minYear! > maximumYear)) ||
        (filters.maxYear != null &&
            (filters.maxYear! < 1886 || filters.maxYear! > maximumYear))) {
      _showError('Год должен быть от 1886 до $maximumYear');
      return;
    }
    Navigator.pop(context, filters);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расширенные фильтры'),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Сбросить')),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _FilterSection(
                    icon: Icons.directions_car_filled_outlined,
                    title: 'Автомобиль',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _textField(_make, 'Марка', 'Toyota'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _textField(_model, 'Модель', 'Camry'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _yearField(_minYear, 'Год от')),
                            const SizedBox(width: 12),
                            Expanded(child: _yearField(_maxYear, 'Год до')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _FilterSection(
                    icon: Icons.payments_outlined,
                    title: 'Цена и пробег',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _numberField(
                                _minPrice,
                                'Цена от',
                                suffix: '\$',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _numberField(
                                _maxPrice,
                                'Цена до',
                                suffix: '\$',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _numberField(
                          _maxMileage,
                          'Пробег до',
                          suffix: 'км',
                        ),
                      ],
                    ),
                  ),
                  _FilterSection(
                    icon: Icons.tune_rounded,
                    title: 'Характеристики',
                    child: Column(
                      children: [
                        _choiceField(
                          label: 'Коробка передач',
                          value: _transmission,
                          values: transmissions,
                          onChanged: (value) =>
                              setState(() => _transmission = value),
                        ),
                        const SizedBox(height: 12),
                        _choiceField(
                          label: 'Кузов',
                          value: _bodyType,
                          values: bodyTypes,
                          onChanged: (value) =>
                              setState(() => _bodyType = value),
                        ),
                        const SizedBox(height: 12),
                        _choiceField(
                          label: 'Топливо',
                          value: _fuelType,
                          values: fuelTypes,
                          onChanged: (value) =>
                              setState(() => _fuelType = value),
                        ),
                      ],
                    ),
                  ),
                  _FilterSection(
                    icon: Icons.location_on_outlined,
                    title: 'Расположение',
                    child: Column(
                      children: [
                        _choiceField(
                          label: 'Страна',
                          value: _country,
                          values: countries,
                          onChanged: (value) =>
                              setState(() => _country = value),
                        ),
                        const SizedBox(height: 12),
                        _textField(_city, 'Город', 'Душанбе'),
                      ],
                    ),
                  ),
                  _FilterSection(
                    icon: Icons.swap_vert_rounded,
                    title: 'Сортировка',
                    child: DropdownButtonFormField<CarSortOrder>(
                      initialValue: _sortOrder,
                      decoration: const InputDecoration(
                        labelText: 'Показывать сначала',
                      ),
                      items: CarSortOrder.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_sortTitle(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _sortOrder = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.search_rounded),
                  label: Text(
                    _filters.activeCount == 0
                        ? 'Показать автомобили'
                        : 'Применить (${_filters.activeCount})',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _yearField(TextEditingController controller, String label) =>
      _numberField(controller, label, maxLength: 4);

  Widget _numberField(
    TextEditingController controller,
    String label, {
    String? suffix,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }

  Widget _choiceField({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: '', child: Text('Любой')),
        ...values.map(
          (item) => DropdownMenuItem(value: item, child: Text(item)),
        ),
      ],
      onChanged: (selected) => onChanged(selected ?? ''),
    );
  }

  String _sortTitle(CarSortOrder value) {
    switch (value) {
      case CarSortOrder.relevance:
        return 'По соответствию';
      case CarSortOrder.newest:
        return 'Сначала новые';
      case CarSortOrder.priceLowToHigh:
        return 'Сначала дешевле';
      case CarSortOrder.priceHighToLow:
        return 'Сначала дороже';
      case CarSortOrder.yearNewest:
        return 'Новее по году';
      case CarSortOrder.mileageLowest:
        return 'Меньше пробег';
    }
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
