import 'package:flutter/material.dart';

import '../data/car_data.dart';
import '../data/user_data.dart';
import '../models/car.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _cityController = TextEditingController();
  final _routeController = TextEditingController();
  final _imageController = TextEditingController();
  final _vinController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _cityController.dispose();
    _routeController.dispose();
    _imageController.dispose();
    _vinController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final car = Car(
      id: 'car_${DateTime.now().millisecondsSinceEpoch}',
      sellerId: currentUser.id,
      title: _titleController.text.trim(),
      price: _priceController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 0,
      mileage: int.tryParse(_mileageController.text.trim()) ?? 0,
      city: _cityController.text.trim(),
      route: _routeController.text.trim(),
      status: CarStatus.pending,
      imageUrl: _imageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8'
          : _imageController.text.trim(),
      images: [
        _imageController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8'
            : _imageController.text.trim(),
      ],
      description: _descriptionController.text.trim(),
      vin: _vinController.text.trim(),
      createdAt: DateTime.now(),
    );

    cars.add(car);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Автомобиль отправлен на модерацию'),
      ),
    );

    Navigator.pop(context);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните поле';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните поле';
    }

    if (int.tryParse(value.trim()) == null) {
      return 'Введите число';
    }

    return null;
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
            _Field(
              controller: _titleController,
              label: 'Название автомобиля',
              hint: 'Toyota Camry 70',
              icon: Icons.directions_car,
              validator: _requiredValidator,
            ),
            _Field(
              controller: _priceController,
              label: 'Цена',
              hint: '24 500 \$',
              icon: Icons.attach_money,
              validator: _requiredValidator,
            ),
            _Field(
              controller: _yearController,
              label: 'Год выпуска',
              hint: '2021',
              icon: Icons.calendar_month,
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            _Field(
              controller: _mileageController,
              label: 'Пробег',
              hint: '42000',
              icon: Icons.speed,
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            _Field(
              controller: _cityController,
              label: 'Город',
              hint: 'Душанбе',
              icon: Icons.location_on,
              validator: _requiredValidator,
            ),
            _Field(
              controller: _routeController,
              label: 'Маршрут доставки',
              hint: 'ОАЭ → Таджикистан',
              icon: Icons.local_shipping,
              validator: _requiredValidator,
            ),
            _Field(
              controller: _imageController,
              label: 'Фото автомобиля URL',
              hint: 'https://...',
              icon: Icons.image,
            ),
            _Field(
              controller: _vinController,
              label: 'VIN',
              hint: 'JTNB11HK0M3000001',
              icon: Icons.confirmation_number,
            ),
            _Field(
              controller: _descriptionController,
              label: 'Описание',
              hint: 'Состояние, комплектация, документы...',
              icon: Icons.description,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Отправить на модерацию'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}