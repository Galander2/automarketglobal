import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiVinCheckScreen extends StatefulWidget {
  const AiVinCheckScreen({super.key});

  @override
  State<AiVinCheckScreen> createState() => _AiVinCheckScreenState();
}

class _AiVinCheckScreenState extends State<AiVinCheckScreen> {
  final _vinController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _vinData;
  String? _error;

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _checkVin() async {
    final vin = _vinController.text.trim().toUpperCase();

    if (vin.isEmpty) {
      setState(() {
        _error = 'Введите VIN код';
      });
      return;
    }

    if (vin.length != 17) {
      setState(() {
        _error = 'VIN должен содержать 17 символов';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _vinData = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$vin?format=json',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;

        final vinInfo = <String, String>{};

        for (var item in results) {
          final variable = item['Variable'] as String?;
          final value = item['Value'] as String?;

          if (variable != null && value != null && value.isNotEmpty) {
            vinInfo[variable] = value;
          }
        }

        setState(() {
          _vinData = vinInfo;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Ошибка сервера. Попробуйте снова.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ошибка подключения: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Проверка VIN'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI VIN Check',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Проверьте историю автомобиля по VIN коду',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ввод VIN
            const Text(
              'Введите VIN код',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vinController,
              decoration: InputDecoration(
                hintText: 'Например: 1HGBH41JXMN109186',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _vinController.clear();
                    setState(() {
                      _vinData = null;
                      _error = null;
                    });
                  },
                ),
              ),
              maxLength: 17,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _checkVin(),
            ),
            const SizedBox(height: 16),

            // Кнопка проверки
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkVin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Проверить VIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Ошибка
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Результаты
            if (_vinData != null) ...[
              const Text(
                'Результаты проверки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: _vinData!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
