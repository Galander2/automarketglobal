import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../core/cars/car_form_validators.dart';
import '../repositories/car_repository.dart';
import '../services/cloudinary_image_service.dart';
import '../widgets/app_hover_lift.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carRepository = CarRepository();
  final _imageService = CloudinaryImageService();

  final _titleController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _routeController = TextEditingController();

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _selectedCountry;
  String? _selectedTransmission;
  String? _selectedBodyType;
  String? _selectedFuelType;

  static const _transmissions = ['Автомат', 'Механика', 'Вариатор', 'Робот'];
  static const _bodyTypes = [
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
  static const _fuelTypes = ['Бензин', 'Дизель', 'Гибрид', 'Электро', 'Газ'];

  final List<String> _countries = [
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

  @override
  void dispose() {
    _titleController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _routeController.dispose();
    _imageService.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Можно добавить не более 10 фотографий')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть галерею')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];
    const parallelUploads = 3;
    for (var start = 0; start < _images.length; start += parallelUploads) {
      final proposedEnd = start + parallelUploads;
      final end = proposedEnd < _images.length
          ? proposedEnd
          : _images.length;
      final batch = _images.sublist(start, end);
      imageUrls.addAll(
        await Future.wait(batch.map(_imageService.uploadImage)),
      );
    }

    return imageUrls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы одно фото')),
      );
      return;
    }
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите страну')));
      return;
    }
    if (_selectedTransmission == null ||
        _selectedBodyType == null ||
        _selectedFuelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните характеристики автомобиля')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sellerId = FirebaseAuth.instance.currentUser?.uid;
      if (sellerId == null) {
        throw StateError('Для публикации необходимо войти в аккаунт');
      }

      final imageUrls = await _uploadImages();

      if (imageUrls.isEmpty) {
        throw Exception('Не удалось загрузить фото');
      }

      final carData = {
        'sellerId': sellerId,
        'title': _titleController.text.trim(),
        'make': _makeController.text.trim(),
        'model': _modelController.text.trim(),
        'transmission': _selectedTransmission,
        'bodyType': _selectedBodyType,
        'fuelType': _selectedFuelType,
        'price': double.parse(
          _priceController.text.replaceAll(RegExp(r'[^\d]'), ''),
        ),
        'year': int.parse(_yearController.text),
        'mileage': int.parse(
          _mileageController.text.replaceAll(RegExp(r'[^\d]'), ''),
        ),
        'city': _cityController.text.trim(),
        'route': _routeController.text.trim(),
        'country': _selectedCountry,
        'description': _descriptionController.text.trim(),
        'vin': _vinController.text.trim(),
        'imageUrl': imageUrls.first,
        'images': imageUrls,
        'status': 'pending',
      };

      await _carRepository.addCar(carData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Автомобиль добавлен'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on CloudinaryUploadException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text('Не удалось опубликовать автомобиль. Повторите позже'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить автомобиль'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Фотографии',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 120,
              child: _images.isEmpty
                  ? AppHoverLift(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('Добавить фото'),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<Uint8List>(
                                  future: _images[index].readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return const Icon(Icons.error);
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: AppHoverLift(
                                borderRadius: BorderRadius.circular(20),
                                hoverScale: 1.08,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            if (_images.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add),
                label: const Text('Добавить ещё фото'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                ),
              ),
            ],

            const SizedBox(height: 24),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Toyota Camry 70',
                border: OutlineInputBorder(),
              ),
              validator: CarFormValidators.title,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _makeController,
                    decoration: const InputDecoration(
                      labelText: 'Марка',
                      hintText: 'Toyota',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => _requiredShortText(value, 'марку'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Модель',
                      hintText: 'Camry',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => _requiredShortText(value, 'модель'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _carPropertyDropdown(
                    label: 'Коробка',
                    value: _selectedTransmission,
                    values: _transmissions,
                    onChanged: (value) =>
                        setState(() => _selectedTransmission = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _carPropertyDropdown(
                    label: 'Кузов',
                    value: _selectedBodyType,
                    values: _bodyTypes,
                    onChanged: (value) =>
                        setState(() => _selectedBodyType = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _carPropertyDropdown(
              label: 'Тип топлива',
              value: _selectedFuelType,
              values: _fuelTypes,
              onChanged: (value) => setState(() => _selectedFuelType = value),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCountry,
              // ...
              decoration: const InputDecoration(
                labelText: 'Страна',
                border: OutlineInputBorder(),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Выберите страну';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Город',
                hintText: 'Душанбе',
                border: OutlineInputBorder(),
              ),
              validator: CarFormValidators.city,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _routeController,
              decoration: const InputDecoration(
                labelText: 'Маршрут',
                hintText: 'Дубай - Душанбе',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Цена (\$)',
                      hintText: '24500',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: CarFormValidators.price,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Год',
                      hintText: '2021',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: CarFormValidators.year,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Пробег (км)',
                hintText: '42000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: CarFormValidators.mileage,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(
                labelText: 'VIN код',
                hintText: 'JTDBF3FG500123456',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: CarFormValidators.vin,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                hintText: 'Опишите состояние...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: CarFormValidators.description,
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
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
                    : const Text(
                        'Отправить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String? _requiredShortText(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите $fieldName';
    if (text.length < 2) return 'Минимум 2 символа';
    if (text.length > 60) return 'Не более 60 символов';
    return null;
  }

  Widget _carPropertyDropdown({
    required String label,
    required String? value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (selected) => selected == null ? 'Выберите значение' : null,
    );
  }
}
