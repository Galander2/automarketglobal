import 'package:flutter/material.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Жалобы'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Рассмотрение жалоб'),
      ),
    );
  }
}