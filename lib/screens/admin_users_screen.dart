import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/app_user.dart';
import '../data/user_data.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _roleFilter = 'all';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser(
          id: doc.id,
          fullName: data['fullName'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          role: UserRole.values.firstWhere(
            (e) => e.name == data['role'],
            orElse: () => UserRole.user,
          ),
          isVerified: data['isVerified'] ?? false,
          rating: (data['rating'] ?? 0).toDouble(),
        );
      }).toList();

      setState(() {
        _users = users;
        _applyFilters();
      });
    } catch (e) {
      // Use mock data on error
      setState(() {
        _users = [currentUser];
        _applyFilters();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      final matchesSearch = user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'all' || user.role.name == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applyFilters();
    });
  }

  Future<void> _changeUserRole(AppUser user, UserRole newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'role': newRole.name,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Роль изменена на ${newRole.title}')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при изменении роли')),
        );
      }
    }
  }

  Future<void> _toggleUserBlock(AppUser user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'isBlocked': !(user.role == UserRole.user), // Simple toggle logic
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(user.role == UserRole.user ? 'Пользователь разблокирован' : 'Пользователь заблокирован')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при изменении статуса')),
        );
      }
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление пользователя'),
        content: Text('Вы уверены, что хотите удалить ${user.fullName}?'),
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
        await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пользователь удалён')),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при удалении')),
          );
        }
      }
    }
  }

  void _showUserDetails(AppUser user) {
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
                user.fullName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.email, 'Email', user.email),
              _buildDetailRow(Icons.phone, 'Телефон', user.phone),
              _buildDetailRow(Icons.badge, 'Роль', user.roleTitle),
              _buildDetailRow(
                Icons.verified_user,
                'Статус',
                user.isVerified ? 'Подтверждён' : 'Не подтверждён',
              ),
              _buildDetailRow(Icons.star, 'Рейтинг', user.rating.toString()),
              const SizedBox(height: 24),
              const Text(
                'Действия',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.admin_panel_settings,
                title: 'Сделать администратором',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _changeUserRole(user, UserRole.admin);
                },
              ),
              _buildActionTile(
                icon: Icons.store,
                title: 'Сделать дилером',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _changeUserRole(user, UserRole.dealer);
                },
              ),
              _buildActionTile(
                icon: Icons.person,
                title: 'Сделать пользователем',
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                  _changeUserRole(user, UserRole.user);
                },
              ),
              _buildActionTile(
                icon: user.role == UserRole.user ? Icons.lock_open : Icons.lock,
                title: user.role == UserRole.user ? 'Разблокировать' : 'Заблокировать',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _toggleUserBlock(user);
                },
              ),
              _buildActionTile(
                icon: Icons.delete,
                title: 'Удалить пользователя',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteUser(user);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        centerTitle: true,
      ),
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
                    hintText: 'Поиск по имени или email',
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
                      _buildFilterChip('Пользователи', 'user'),
                      _buildFilterChip('Дилеры', 'dealer'),
                      _buildFilterChip('Админы', 'admin'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Пользователи не найдены',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                            child: Icon(
                              _getRoleIcon(user.role),
                              color: _getRoleColor(user.role),
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.roleTitle,
                                  style: TextStyle(
                                    color: _getRoleColor(user.role),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showUserDetails(user),
                              ),
                            ],
                          ),
                          onTap: () => _showUserDetails(user),
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
    final isSelected = _roleFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _roleFilter = value;
            _applyFilters();
          });
        },
        selectedColor: const Color(0xFF2563EB).withOpacity(0.2),
        checkmarkColor: const Color(0xFF2563EB),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return Colors.blue;
      case UserRole.dealer:
        return Colors.green;
      case UserRole.seller:
        return Colors.orange;
      case UserRole.user:
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.dealer:
        return Icons.store;
      case UserRole.seller:
        return Icons.sell;
      case UserRole.user:
      default:
        return Icons.person;
    }
  }
}

extension on UserRole {
  String get title {
    switch (this) {
      case UserRole.user:
        return 'Пользователь';
      case UserRole.seller:
        return 'Продавец';
      case UserRole.dealer:
        return 'Дилер';
      case UserRole.admin:
        return 'Администратор';
      case UserRole.superAdmin:
        return 'Супер-админ';
    }
  }
}