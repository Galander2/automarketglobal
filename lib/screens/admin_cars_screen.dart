import 'package:flutter/material.dart';

class AdminCarsScreen extends StatelessWidget {
  const AdminCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Автомобили'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Модерация автомобилей'),
      ),
    );
  }
}