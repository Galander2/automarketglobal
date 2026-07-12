import 'package:flutter/material.dart';

class DealersScreen extends StatelessWidget {
  const DealersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dealers = [
      {'name': 'Toyota Dubai', 'desc': 'Официальный дилер Toyota', 'rating': 4.9, 'cars': 245},
      {'name': 'Japan Motors', 'desc': 'Автомобили из Японии', 'rating': 4.8, 'cars': 189},
      {'name': 'China Auto Export', 'desc': 'Китайские автомобили', 'rating': 4.7, 'cars': 312},
      {'name': 'Korea Auto Group', 'desc': 'Корейские авто под ключ', 'rating': 4.8, 'cars': 156},
      {'name': 'Luxury Dubai Cars', 'desc': 'Премиум автомобили', 'rating': 4.9, 'cars': 78},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Крупные дилеры'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dealers.length,
        itemBuilder: (context, index) {
          final dealer = dealers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      child: Text(
                        dealer['name'].toString().substring(0, 1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dealer['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dealer['desc'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber[700]),
                              const SizedBox(width: 4),
                              Text(
                                dealer['rating'].toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.directions_car, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${dealer['cars']} авто',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}