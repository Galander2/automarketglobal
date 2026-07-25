import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/admin_repository.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      setState(() => _isLoading = true);

      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .get();

      final complaints = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      if (!mounted) return;
      setState(() => _complaints = complaints);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить жалобы: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _blockUser(String userId, String userName) async {
    try {
      await _adminRepository.setUserBlockedById(userId, true);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$userName заблокирован')));
        _loadComplaints();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка при блокировке')));
      }
    }
  }

  Future<void> _deleteCar(String carId, String carTitle) async {
    try {
      await _adminRepository.deleteCar(carId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Объявление "$carTitle" удалено')),
        );
        _loadComplaints();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка при удалении')));
      }
    }
  }

  Future<void> _resolveComplaint(String complaintId) async {
    try {
      await _adminRepository.resolveComplaint(complaintId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Жалоба рассмотрена')));
        _loadComplaints();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка')));
      }
    }
  }

  void _showComplaintDetails(Map<String, dynamic> complaint) {
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
              const Text(
                'Детали жалобы',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.car_rental,
                'Автомобиль',
                complaint['carTitle'] ?? '',
              ),
              _buildDetailRow(
                Icons.person,
                'Пожаловался',
                complaint['userName'] ?? '',
              ),
              _buildDetailRow(
                Icons.warning,
                'Причина',
                complaint['reason'] ?? '',
              ),
              const SizedBox(height: 16),
              const Text(
                'Описание:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                complaint['description'] ?? '',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              const Text(
                'Действия',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.block,
                title: 'Заблокировать пользователя',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(complaint['userId'], complaint['userName']);
                },
              ),
              _buildActionTile(
                icon: Icons.delete,
                title: 'Удалить объявление',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _deleteCar(complaint['carId'], complaint['carTitle']);
                },
              ),
              _buildActionTile(
                icon: Icons.check_circle,
                title: 'Отметить как решённую',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _resolveComplaint(complaint['id']);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Жалобы'), centerTitle: true),
      body: _complaints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text('Жалоб нет', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _complaints.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      child: const Icon(Icons.warning, color: Colors.red),
                    ),
                    title: Text(
                      complaint['reason'] ?? 'Жалоба',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(complaint['carTitle'] ?? ''),
                        const SizedBox(height: 2),
                        Text(
                          'От: ${complaint['userName'] ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showComplaintDetails(complaint),
                    ),
                    onTap: () => _showComplaintDetails(complaint),
                  ),
                );
              },
            ),
    );
  }
}
