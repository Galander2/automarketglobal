import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_users_screen.dart';
import 'admin_dealers_screen.dart';
import 'admin_markets_screen.dart';
import 'admin_complaints_screen.dart';

class AdminScreen extends StatefulWidget {
  final int initialTab;
  const AdminScreen({super.key, this.initialTab = 0});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminReportsScreen(),
    AdminUsersScreen(),
    AdminDealersScreen(),
    AdminMarketsScreen(),
    AdminComplaintsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Админ-панель'), centerTitle: true),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Дашборд',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Отчёты',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Пользователи',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Дилеры',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Рынки',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: 'Жалобы',
          ),
        ],
      ),
    );
  }
}
