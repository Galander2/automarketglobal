import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/cars/vin_validator.dart';

class AiVinCheckScreen extends StatefulWidget {
  const AiVinCheckScreen({super.key});

  @override
  State<AiVinCheckScreen> createState() => _AiVinCheckScreenState();
}

class _AiVinCheckScreenState extends State<AiVinCheckScreen> {
  static const _resultFields = <String, String>{
    'Make': 'Марка',
    'Model': 'Модель',
    'Model Year': 'Год',
    'Body Class': 'Кузов',
    'Vehicle Type': 'Тип автомобиля',
    'Manufacturer Name': 'Производитель',
    'Plant Country': 'Страна производства',
    'Fuel Type - Primary': 'Топливо',
    'Transmission Style': 'Коробка передач',
  };

  final _vinController = TextEditingController();
  bool _isLoading = false;
  Map<String, String>? _vinData;
  String? _error;

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _checkVin() async {
    final vin = VinValidator.normalize(_vinController.text);
    if (!VinValidator.isValid(vin)) {
      setState(() {
        _error = 'Введите корректный VIN из 17 символов без I, O и Q.';
        _vinData = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _error = null;
      _vinData = null;
    });

    try {
      final uri = Uri.https(
        'vpic.nhtsa.dot.gov',
        '/api/vehicles/decodevin/$vin',
        const {'format': 'json'},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw const _VinServiceException();
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected VIN response');
      }
      final rawResults = decoded['Results'];
      if (rawResults is! List) {
        throw const FormatException('Missing VIN results');
      }

      final result = <String, String>{};
      for (final rawItem in rawResults) {
        if (rawItem is! Map) continue;
        final variable = rawItem['Variable'];
        final value = rawItem['Value'];
        if (variable is! String || value is! String) continue;
        final label = _resultFields[variable];
        final cleanValue = value.trim();
        if (label != null &&
            cleanValue.isNotEmpty &&
            cleanValue.toLowerCase() != 'not applicable') {
          result[label] = cleanValue;
        }
      }

      if (result.isEmpty) {
        throw const _VinServiceException();
      }
      if (!mounted) return;
      setState(() => _vinData = result);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _error = 'Сервис не ответил вовремя. Проверьте интернет и повторите.';
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _error = 'Сервис вернул некорректные данные. Повторите позже.';
      });
    } on _VinServiceException {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось получить данные VIN. Проверьте код и повторите.';
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _error = 'Нет подключения к сервису VIN. Повторите позже.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clear() {
    _vinController.clear();
    setState(() {
      _vinData = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Проверка VIN'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.24),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIN Decoder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Получите заводские характеристики автомобиля '
                          'из официального каталога NHTSA.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.fact_check_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'VIN-код',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _vinController,
              enabled: !_isLoading,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(17),
              ],
              decoration: InputDecoration(
                hintText: 'Например: 1HGBH41JXMN109186',
                prefixIcon: const Icon(Icons.pin_outlined),
                suffixIcon: IconButton(
                  tooltip: 'Очистить',
                  onPressed: _isLoading ? null : _clear,
                  icon: const Icon(Icons.clear_rounded),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: _isLoading ? null : (_) => _checkVin(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _checkVin,
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(_isLoading ? 'Проверяем…' : 'Проверить VIN'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              _MessageCard(
                icon: Icons.error_outline_rounded,
                color: colorScheme.error,
                message: _error!,
              ),
            ],
            if (_vinData case final data?) ...[
              const SizedBox(height: 24),
              Text(
                'Характеристики',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: data.entries.indexed.map((indexedEntry) {
                    final index = indexedEntry.$1;
                    final entry = indexedEntry.$2;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(entry.key),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: Text(
                              entry.value,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (index < data.length - 1) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Данные декодирования не являются отчётом об авариях, '
                'пробеге или юридической чистоте автомобиля.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _VinServiceException implements Exception {
  const _VinServiceException();
}
