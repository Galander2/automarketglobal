import 'package:flutter/material.dart';
import '../widgets/app_hover_lift.dart';
import '../core/router/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../models/admin_stats.dart';
import '../repositories/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminRepository? repository;

  const AdminDashboardScreen({super.key, this.repository});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminRepository _adminRepository =
      widget.repository ?? AdminRepository();
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'load_failed';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(onRetry: _loadStats),
                    ],
                    const SizedBox(height: 24),
                    if (stats != null)
                      _buildQuickStats(stats)
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 24),
                    _buildMainGrid(context),
                    const SizedBox(height: 24),
                    if (stats != null) _buildModerationSection(stats),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primaryDark, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final identity = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Панель управления',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Безопасное управление платформой',
                      style: TextStyle(
                        color: Color(0xFFD7E3F4),
                        fontSize: 13,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final refresh = IconButton(
            tooltip: 'Обновить статистику',
            onPressed: _loadStats,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: refresh),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16),
              refresh,
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(AdminStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;
        final cards = [
          _buildStatCard(
            'Пользователи',
            stats.totalUsers.toString(),
            Icons.people,
            AppColors.primary,
          ),
          _buildStatCard(
            'Дилеры',
            stats.totalDealers.toString(),
            Icons.store,
            AppColors.success,
          ),
          _buildStatCard(
            'Авто',
            stats.totalCars.toString(),
            Icons.directions_car,
            AppColors.warning,
          ),
          _buildStatCard(
            'Продано',
            stats.soldCars.toString(),
            Icons.check_circle,
            const Color(0xFF8B5CF6),
          ),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
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
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    final cards = [
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
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: columns == 1 ? 156 : 190,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }

  Widget _buildModerationSection(AdminStats stats) {
    final totalReviewed = stats.approvedCars + stats.soldCars;
    final totalModeration = totalReviewed + stats.pendingCars;
    final progress = totalModeration == 0
        ? 0.0
        : totalReviewed / totalModeration;

    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Не удалось загрузить актуальную статистику.'),
            ),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
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
    final scheme = Theme.of(context).colorScheme;
    return AppHoverLift(
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
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
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
