import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    try {
      setState(() => _isLoading = true);

      final snapshot = await FirebaseFirestore.instance
          .collection('cars')
          .orderBy('createdAt', descending: true)
          .get();

      final cars = snapshot.docs.map((doc) {
        final data = doc.data();
        return Car(
          id: doc.id,
          sellerId: data['sellerId'] ?? '',
          title: data['title'] ?? '',
          price: data['price']?.toString() ?? '',
          year: (data['year'] as num?)?.toInt() ?? 0,
          mileage: (data['mileage'] as num?)?.toInt() ?? 0,
          city: data['city'] ?? '',
          route: data['route'] ?? '',
          country: data['country'] ?? '',
          status: CarStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => CarStatus.pending,
          ),
          imageUrl: data['imageUrl'] ?? '',
          images: List<String>.from(data['images'] ?? []),
          description: data['description'] ?? '',
          vin: data['vin'] ?? '',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _cars = cars;
        _applyFilters();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить автомобили: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    _filteredCars = _cars.where((car) {
      final matchesSearch =
          car.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          car.vin.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _statusFilter == 'all' || car.status.name == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applyFilters();
    });
  }

  Future<void> _approveCar(Car car) async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(car.id).update({
        'status': CarStatus.approved.name,
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Автомобиль одобрен')));
        _loadCars();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка при одобрении')));
      }
    }
  }

  Future<void> _rejectCar(Car car) async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(car.id).update({
        'status': CarStatus.rejected.name,
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Автомобиль отклонён')));
        _loadCars();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка при отклонении')));
      }
    }
  }

  Future<void> _deleteCar(Car car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление объявления'),
        content: Text('Вы уверены, что хотите удалить "${car.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('cars')
            .doc(car.id)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Объявление удалено')));
          _loadCars();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Ошибка при удалении')));
        }
      }
    }
  }

  void _showCarDetails(Car car) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  car.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 64),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                car.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${car.price} \$',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.info_outline, 'VIN', car.vin),
              _buildDetailRow(Icons.calendar_today, 'Год', car.year.toString()),
              _buildDetailRow(Icons.speed, 'Пробег', '${car.mileage} км'),
              _buildDetailRow(Icons.location_city, 'Город', car.city),
              _buildDetailRow(Icons.route, 'Маршрут', car.route),
              _buildDetailRow(Icons.public, 'Страна', car.country),
              _buildDetailRow(
                Icons.status,
                'Статус',
                _getStatusTitle(car.status),
              ),
              const SizedBox(height: 24),
              const Text(
                'Действия',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (car.isPending) ...[
                _buildActionTile(
                  icon: Icons.check_circle,
                  title: 'Одобрить',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _approveCar(car);
                  },
                ),
                _buildActionTile(
                  icon: Icons.cancel,
                  title: 'Отклонить',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _rejectCar(car);
                  },
                ),
              ],
              _buildActionTile(
                icon: Icons.edit,
                title: 'Редактировать',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit screen
                },
              ),
              _buildActionTile(
                icon: Icons.delete,
                title: 'Удалить объявление',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteCar(car);
                },
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getStatusTitle(CarStatus status) {
    switch (status) {
      case CarStatus.pending:
        return 'На модерации';
      case CarStatus.approved:
        return 'Одобрен';
      case CarStatus.rejected:
        return 'Отклонён';
      case CarStatus.sold:
        return 'Продан';
      case CarStatus.draft:
        return 'Черновик';
    }
  }

  Color _getStatusColor(CarStatus status) {
    switch (status) {
      case CarStatus.pending:
        return Colors.orange;
      case CarStatus.approved:
        return Colors.green;
      case CarStatus.rejected:
        return Colors.red;
      case CarStatus.sold:
        return Colors.blue;
      case CarStatus.draft:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Автомобили'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию или VIN',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Все', 'all'),
                      _buildFilterChip('На модерации', 'pending'),
                      _buildFilterChip('Одобренные', 'approved'),
                      _buildFilterChip('Отклонённые', 'rejected'),
                      _buildFilterChip('Проданные', 'sold'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredCars.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.car_rental,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Автомобили не найдены',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCars.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final car = _filteredCars[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              car.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            ),
                          ),
                          title: Text(
                            car.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${car.price} \$'),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    car.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusTitle(car.status),
                                  style: TextStyle(
                                    color: _getStatusColor(car.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'approve' && car.isPending) {
                                _approveCar(car);
                              } else if (value == 'reject' && car.isPending) {
                                _rejectCar(car);
                              } else if (value == 'delete') {
                                _deleteCar(car);
                              } else if (value == 'details') {
                                _showCarDetails(car);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'details',
                                child: Text('Подробнее'),
                              ),
                              if (car.isPending) ...[
                                const PopupMenuItem(
                                  value: 'approve',
                                  child: Text('Одобрить'),
                                ),
                                const PopupMenuItem(
                                  value: 'reject',
                                  child: Text('Отклонить'),
                                ),
                              ],
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Удалить'),
                              ),
                            ],
                          ),
                          onTap: () => _showCarDetails(car),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _statusFilter = value;
            _applyFilters();
          });
        },
        selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF2563EB),
      ),
    );
  }
}
