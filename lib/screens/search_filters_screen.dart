import 'package:flutter/material.dart';

class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  String _sortOrder = 'newest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Фильтры'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Цена',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'От',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'До',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Год',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'От',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'До',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Пробег',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'До',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Марка',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Марка',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Топливо',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Тип топлива',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Коробка',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Тип КПП',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Сортировка',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          RadioGroup<String>(
            groupValue: _sortOrder,
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortOrder = value);
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(value: 'newest', title: Text('Новые')),
                RadioListTile<String>(value: 'price', title: Text('По цене')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _sortOrder),
            child: const Text(
              'Применить',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
