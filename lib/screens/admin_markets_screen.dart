import 'package:flutter/material.dart';

class AdminMarketsScreen extends StatelessWidget {
  const AdminMarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рынки'), centerTitle: true),
      body: const Center(child: Text('Управление рынками')),
    );
  }
}
