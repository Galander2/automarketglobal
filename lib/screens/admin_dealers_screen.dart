import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dealer.dart';

class AdminDealersScreen extends StatefulWidget {
  const AdminDealersScreen({super.key});

  @override
  State<AdminDealersScreen> createState() => _AdminDealersScreenState();
}

class _AdminDealersScreenState extends State<AdminDealersScreen> {
  List<Dealer> _dealers = [];
  List<Dealer> _filteredDealers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDealers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDealers() async {
    try {
      setState(() => _isLoading = true);

      final snapshot = await FirebaseFirestore.instance
          .collection('dealers')
          .orderBy('name')
          .get();

      final dealers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Dealer(
          id: doc.id,
          name: data['name'] ?? '',
          country: data['country'] ?? '',
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          deliveryCountries: List<String>.from(data['deliveryCountries'] ?? []),
          isVerified: data['isVerified'] ?? false,
          rating: (data['rating'] ?? 0).toDouble(),
          carsCount: (data['carsCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _dealers = dealers;
        _applyFilters();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить дилеров: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    _filteredDealers = _dealers.where((dealer) {
      return dealer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dealer.city.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applyFilters();
    });
  }

  Future<void> _verifyDealer(Dealer dealer) async {
    try {
      await FirebaseFirestore.instance
          .collection('dealers')
          .doc(dealer.id)
          .update({'isVerified': !dealer.isVerified});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              dealer.isVerified
                  ? 'Дилер больше не верифицирован'
                  : 'Дилер верифицирован',
            ),
          ),
        );
        _loadDealers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка')));
      }
    }
  }

  void _showDealerDetails(Dealer dealer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                dealer.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.location_on, 'Страна', dealer.country),
              _buildDetailRow(Icons.city, 'Город', dealer.city),
              _buildDetailRow(
                Icons.store,
                'Авто в наличии',
                '${dealer.carsCount}',
              ),
              _buildDetailRow(Icons.star, 'Рейтинг', '${dealer.rating}'),
              _buildDetailRow(
                Icons.verified_user,
                'Статус',
                dealer.isVerified ? 'Верифицирован' : 'Не верифицирован',
              ),
              const SizedBox(height: 16),
              const Text(
                'Описание:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(dealer.description),
              const SizedBox(height: 16),
              const Text(
                'Страны доставки:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: dealer.deliveryCountries
                    .map((c) => Chip(label: Text(c)))
                    .toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _verifyDealer(dealer);
                },
                icon: Icon(
                  dealer.isVerified ? Icons.cancel : Icons.check_circle,
                ),
                label: Text(
                  dealer.isVerified ? 'Снять верификацию' : 'Верифицировать',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Дилеры'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Поиск по названию или городу',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _filteredDealers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Дилеры не найдены',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDealers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final dealer = _filteredDealers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: dealer.isVerified
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.store,
                              color: dealer.isVerified
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            dealer.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${dealer.city}, ${dealer.country}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (dealer.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '✓',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showDealerDetails(dealer),
                              ),
                            ],
                          ),
                          onTap: () => _showDealerDetails(dealer),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
