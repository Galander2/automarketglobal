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
  static const _destinations = [
    _AdminDestination(
      label: 'Обзор',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _AdminDestination(
      label: 'Отчёты',
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment_rounded,
    ),
    _AdminDestination(
      label: 'Пользователи',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_alt_rounded,
    ),
    _AdminDestination(
      label: 'Дилеры',
      icon: Icons.store_outlined,
      selectedIcon: Icons.storefront_rounded,
    ),
    _AdminDestination(
      label: 'Рынки',
      icon: Icons.public_outlined,
      selectedIcon: Icons.public_rounded,
    ),
    _AdminDestination(
      label: 'Жалобы',
      icon: Icons.report_outlined,
      selectedIcon: Icons.report_rounded,
    ),
  ];

  late int _currentIndex;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminReportsScreen(embedded: true),
    AdminUsersScreen(),
    AdminDealersScreen(),
    AdminMarketsScreen(),
    AdminComplaintsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab < 0
        ? 0
        : widget.initialTab >= _screens.length
        ? _screens.length - 1
        : widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;
        final content = IndexedStack(index: _currentIndex, children: _screens);

        return Scaffold(
          appBar: AppBar(
            title: Text(_destinations[_currentIndex].label),
            centerTitle: !useRail,
          ),
          body: useRail
              ? Row(
                  children: [
                    SafeArea(
                      top: false,
                      child: NavigationRail(
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _selectDestination,
                        extended: constraints.maxWidth >= 1180,
                        labelType: constraints.maxWidth >= 1180
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.selected,
                        leading: const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 30,
                          ),
                        ),
                        destinations: _destinations
                            .map(
                              (item) => NavigationRailDestination(
                                icon: Icon(item.icon),
                                selectedIcon: Icon(item.selectedIcon),
                                label: Text(item.label),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _selectDestination,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: _destinations
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }

  void _selectDestination(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }
}

class _AdminDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _AdminDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
