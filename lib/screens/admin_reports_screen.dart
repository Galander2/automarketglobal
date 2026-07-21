import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/admin_report_data.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('analytics')
          .doc('main')
          .get();

      if (!mounted) return;
      setState(() => _analytics = snapshot.data());
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
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

    return Scaffold(
      appBar: AppBar(title: const Text('Отчёты'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Основная статистика',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: adminReports
                    .map((report) => _buildStatCard(report))
                    .toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Аналитика',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_loadError != null) ...[
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Не удалось загрузить аналитику: $_loadError'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _buildAnalyticsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(dynamic report) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              report.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              report.subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    final analytics = _analytics;
    if (analytics == null || analytics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Аналитические данные пока отсутствуют'),
        ),
      );
    }

    return _buildAnalyticsCard(
      title: 'Данные Firestore',
      icon: Icons.analytics_outlined,
      color: Colors.blue,
      items: analytics.entries
          .map((entry) => '${entry.key}: ${_formatValue(entry.value)}')
          .toList(),
    );
  }

  String _formatValue(Object? value) {
    if (value is Iterable) return value.join(', ');
    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', ');
    }
    return value?.toString() ?? '—';
  }

  Widget _buildAnalyticsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
