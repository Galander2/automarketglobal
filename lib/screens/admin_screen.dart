import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../core/security/app_permissions.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import 'admin_dashboard_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final destinations = _destinationsFor(user);
    final isSuperAdmin = user.role == UserRole.superAdmin;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;
        final drawer = useRail
            ? null
            : Drawer(
                child: SafeArea(
                  child: _AdminNavigation(
                    destinations: destinations,
                    closeDrawerAfterSelection: true,
                  ),
                ),
              );

        return Scaffold(
          drawer: drawer,
          appBar: AppBar(
            title: Text(
              isSuperAdmin
                  ? 'Панель супер-администратора'
                  : 'Панель администратора',
            ),
          ),
          body: Row(
            children: [
              if (useRail) ...[
                SafeArea(
                  top: false,
                  child: _AdminNavigation(destinations: destinations),
                ),
                const VerticalDivider(width: 1),
              ],
              const Expanded(child: AdminDashboardScreen()),
            ],
          ),
        );
      },
    );
  }

  static List<_AdminDestination> _destinationsFor(AppUser user) {
    const permissions = AppPermissions();
    return [
      if (permissions.canModerateCars(user))
        const _AdminDestination(
          label: 'Автомобили',
          icon: Icons.directions_car_outlined,
          route: AppRoutes.adminCars,
        ),
      if (permissions.canManageUsers(user))
        const _AdminDestination(
          label: 'Пользователи',
          icon: Icons.people_outline_rounded,
          route: AppRoutes.adminUsers,
        ),
      if (permissions.canManageDealers(user))
        const _AdminDestination(
          label: 'Дилеры',
          icon: Icons.storefront_outlined,
          route: AppRoutes.adminDealers,
        ),
      if (permissions.canManageMarkets(user))
        const _AdminDestination(
          label: 'Рынки',
          icon: Icons.public_outlined,
          route: AppRoutes.adminMarkets,
        ),
      if (permissions.canViewFullReports(user))
        const _AdminDestination(
          label: 'Отчёты',
          icon: Icons.assessment_outlined,
          route: AppRoutes.adminReports,
        ),
      const _AdminDestination(
        label: 'Жалобы',
        icon: Icons.report_outlined,
        route: AppRoutes.adminComplaints,
      ),
    ];
  }
}

class _AdminNavigation extends StatelessWidget {
  const _AdminNavigation({
    required this.destinations,
    this.closeDrawerAfterSelection = false,
  });

  final List<_AdminDestination> destinations;
  final bool closeDrawerAfterSelection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const ListTile(
            leading: Icon(Icons.admin_panel_settings_rounded),
            title: Text(
              'Управление',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('Доступные разделы'),
          ),
          const Divider(),
          for (final item in destinations)
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                final navigator = Navigator.of(context);
                if (closeDrawerAfterSelection) navigator.pop();
                navigator.pushNamed(item.route);
              },
            ),
        ],
      ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
