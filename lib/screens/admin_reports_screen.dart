import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/admin_stats.dart';
import '../repositories/admin_repository.dart';

class AdminReportsScreen extends StatefulWidget {
  final AdminRepository? repository;
  final bool embedded;

  const AdminReportsScreen({
    super.key,
    this.repository,
    this.embedded = false,
  });

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late final AdminRepository _repository =
      widget.repository ?? AdminRepository();
  AdminStats? _stats;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final stats = await _repository.loadStats();
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _stats = null;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoading && _stats == null
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadReport,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: _buildContent(context),
                ),
              ),
            ),
          );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёты'),
        actions: [
          IconButton(
            tooltip: 'Обновить данные',
            onPressed: _isLoading ? null : _loadReport,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    final stats = _stats;
    if (_hasError || stats == null) {
      return _ReportError(onRetry: _loadReport);
    }

    final reviewedCars = stats.approvedCars + stats.soldCars;
    final moderationTotal = reviewedCars + stats.pendingCars;
    final moderationProgress =
        moderationTotal == 0 ? 0.0 : reviewedCars / moderationTotal;
    final publishedShare =
        stats.totalCars == 0 ? 0.0 : stats.approvedCars / stats.totalCars;
    final soldShare =
        stats.totalCars == 0 ? 0.0 : stats.soldCars / stats.totalCars;

    final metrics = <_ReportMetric>[
      _ReportMetric(
        label: 'Пользователи',
        value: stats.totalUsers,
        description: 'Зарегистрировано',
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
      ),
      _ReportMetric(
        label: 'Дилеры',
        value: stats.totalDealers,
        description: 'Аккаунты дилеров',
        icon: Icons.storefront_rounded,
        color: AppColors.success,
      ),
      _ReportMetric(
        label: 'Все автомобили',
        value: stats.totalCars,
        description: 'Объявления в системе',
        icon: Icons.directions_car_filled_rounded,
        color: AppColors.accent,
      ),
      _ReportMetric(
        label: 'Ожидают проверки',
        value: stats.pendingCars,
        description: 'Очередь модерации',
        icon: Icons.pending_actions_rounded,
        color: AppColors.warning,
      ),
      _ReportMetric(
        label: 'Опубликовано',
        value: stats.approvedCars,
        description: 'Активные объявления',
        icon: Icons.verified_rounded,
        color: const Color(0xFF14B8A6),
      ),
      _ReportMetric(
        label: 'Продано',
        value: stats.soldCars,
        description: 'Завершённые объявления',
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportHeader(
          totalCars: stats.totalCars,
          pendingCars: stats.pendingCars,
        ),
        const SizedBox(height: 28),
        Text(
          'Основная статистика',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
        ),
        const SizedBox(height: 14),
        _ResponsiveMetricGrid(metrics: metrics),
        const SizedBox(height: 28),
        Text(
          'Состояние платформы',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final children = [
              _ProgressPanel(
                title: 'Модерация объявлений',
                subtitle: moderationTotal == 0
                    ? 'Объявлений для проверки пока нет'
                    : '$reviewedCars из $moderationTotal обработано',
                value: moderationProgress,
                color: AppColors.primary,
                icon: Icons.fact_check_rounded,
              ),
              _ProgressPanel(
                title: 'Статусы автомобилей',
                subtitle:
                    '${_percent(publishedShare)} опубликовано · '
                    '${_percent(soldShare)} продано',
                value: publishedShare + soldShare > 1
                    ? 1
                    : publishedShare + soldShare,
                color: AppColors.success,
                icon: Icons.insights_rounded,
              ),
            ];
            if (!wide) {
              return Column(
                children: [
                  children[0],
                  const SizedBox(height: 12),
                  children[1],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 12),
                Expanded(child: children[1]),
              ],
            );
          },
        ),
      ],
    );
  }

  String _percent(double value) => '${(value * 100).round()}%';
}

class _ReportHeader extends StatelessWidget {
  final int totalCars;
  final int pendingCars;

  const _ReportHeader({
    required this.totalCars,
    required this.pendingCars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primaryDark, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.query_stats_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Аналитика платформы',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Актуальные показатели из защищённой базы данных',
                  style: TextStyle(
                    color: Color(0xFFD7E3F4),
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          _HeaderPill(label: 'Объявлений', value: '$totalCars'),
          _HeaderPill(label: 'На проверке', value: '$pendingCars'),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD7E3F4),
              fontSize: 11,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveMetricGrid extends StatelessWidget {
  final List<_ReportMetric> metrics;

  const _ResponsiveMetricGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 3
            : constraints.maxWidth >= 580
                ? 2
                : 1;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _ReportMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(metric.icon, color: metric.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final Color color;
  final IconData icon;

  const _ProgressPanel({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: value,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ReportError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: scheme.onErrorContainer),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Text(
                'Не удалось загрузить отчёт. Проверьте подключение и права '
                'администратора, затем повторите.',
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMetric {
  final String label;
  final int value;
  final String description;
  final IconData icon;
  final Color color;

  const _ReportMetric({
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  });
}
