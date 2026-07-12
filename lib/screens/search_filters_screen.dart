import 'package:flutter/material.dart';

class SearchFiltersScreen extends StatelessWidget {
  const SearchFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Цена', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const TextField(decoration: InputDecoration(labelText: 'От', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          const TextField(decoration: InputDecoration(labelText: 'До', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          const Text('Год', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const TextField(decoration: InputDecoration(labelText: 'От', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          const TextField(decoration: InputDecoration(labelText: 'До', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          const Text('Пробег', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const TextField(decoration: InputDecoration(labelText: 'До', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          const Text('Марка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const TextField(decoration: InputDecoration(labelText: 'Марка', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          const Text('Топливо', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const TextField(decoration: InputDecoration(labelText: 'Тип топлива', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          const Text('Коробка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const TextField(decoration: InputDecoration(labelText: 'Тип КПП', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          const Text('Сортировка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const RadioListTile<String>(value: 'newest', groupValue: 'newest', title: Text('Новые'), onChanged: null),
          const RadioListTile<String>(value: 'price', groupValue: 'newest', title: Text('По цене'), onChanged: null),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Применить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}