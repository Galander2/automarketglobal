import 'package:flutter/material.dart';
import '../core/router/app_routes.dart';
import '../models/admin_stats.dart';
import '../repositories/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  AdminStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final stats = await _adminRepository.loadStats();
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _stats = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = _stats;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Не удалось загрузить статистику: $_error'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (stats != null)
              _buildQuickStats(stats)
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Статистические данные пока отсутствуют'),
                ),
              ),
            const SizedBox(height: 24),
            _buildMainGrid(context),
            const SizedBox(height: 24),
            if (stats != null) _buildModerationSection(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Админ панель',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Управление платформой',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        IconButton.filled(
          onPressed: _loadStats,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildQuickStats(AdminStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Пользователи',
            stats.totalUsers.toString(),
            Icons.people,
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Дилеры',
            stats.totalDealers.toString(),
            Icons.store,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Авто',
            stats.totalCars.toString(),
            Icons.directions_car,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Продано',
            stats.soldCars.toString(),
            Icons.check_circle,
            const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _AdminCard(
          icon: Icons.people,
          title: 'Пользователи',
          subtitle: 'Управление пользователями',
          color: const Color(0xFF2563EB),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminUsers);
          },
        ),
        _AdminCard(
          icon: Icons.car_rental,
          title: 'Автомобили',
          subtitle: 'Модерация объявлений',
          color: const Color(0xFF10B981),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminCars);
          },
        ),
        _AdminCard(
          icon: Icons.store,
          title: 'Дилеры',
          subtitle: 'Управление дилерами',
          color: const Color(0xFF8B5CF6),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminDealers);
          },
        ),
        _AdminCard(
          icon: Icons.bar_chart,
          title: 'Отчёты',
          subtitle: 'Статистика и аналитика',
          color: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminReports);
          },
        ),
        _AdminCard(
          icon: Icons.chat,
          title: 'Жалобы',
          subtitle: 'Рассмотрение жалоб',
          color: const Color(0xFFEF4444),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminComplaints);
          },
        ),
      ],
    );
  }

  Widget _buildModerationSection(AdminStats stats) {
    final totalReviewed = stats.approvedCars + stats.soldCars;
    final totalModeration = totalReviewed + stats.pendingCars;
    final progress = totalModeration == 0
        ? 0.0
        : totalReviewed / totalModeration;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Состояние модерации',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Text(
              'Ожидают проверки: ${stats.pendingCars}. '
              'Опубликованы: ${stats.approvedCars}. '
              'Проданы: ${stats.soldCars}.',
            ),
          ],
        ),
      ),
    );
  }

}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
