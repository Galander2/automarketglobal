import 'package:flutter/material.dart';
import '../core/router/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ панель'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
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
          _AdminCard(
            icon: Icons.settings,
            title: 'Настройки',
            subtitle: 'Настройки системы',
            color: const Color(0xFF6B7280),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.adminSettings);
            },
          ),
        ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
  color.withOpacity(0.1),
  color.withOpacity(0.05),
],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}