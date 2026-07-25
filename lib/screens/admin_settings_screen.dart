import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import '../repositories/auth_repository.dart';
import '../core/router/app_routes.dart';
import '../models/app_user.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsProvider>().loadSettings();
      }
    });
  }

  Future<void> _updateField(
    SettingsProvider provider,
    String field,
    Object value,
  ) async {
    final adminUid = context.read<AuthProvider>().currentUser?.uid;
    if (adminUid == null) {
      _showMessage('Сессия администратора недоступна', isError: true);
      return;
    }

    try {
      await provider.updateField(field, value, adminUid);
    } catch (error) {
      _showMessage('Не удалось сохранить настройку: $error', isError: true);
    }
  }

  Future<void> _resetSettings(SettingsProvider provider) async {
    final adminUid = context.read<AuthProvider>().currentUser?.uid;
    if (adminUid == null) {
      _showMessage('Сессия администратора недоступна', isError: true);
      return;
    }

    try {
      await provider.resetSettings(adminUid);
      _showMessage('Настройки сброшены');
    } catch (error) {
      _showMessage('Не удалось сбросить настройки: $error', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showConfirmDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Подтвердить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final canEdit = user?.role == UserRole.superAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки администратора'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Ошибка: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadSettings(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final settings = provider.settings;
          if (settings == null) {
            return const Center(child: Text('Настройки не найдены'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: canEdit
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListTile(
                  leading: Icon(
                    canEdit ? Icons.admin_panel_settings : Icons.visibility,
                  ),
                  title: Text(
                    canEdit
                        ? 'Режим суперадминистратора'
                        : 'Безопасный режим администратора',
                  ),
                  subtitle: Text(
                    canEdit
                        ? 'Изменения записываются в журнал безопасности.'
                        : 'Параметры доступны для просмотра. Критические изменения может выполнять только суперадминистратор.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Рабочие разделы'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.car_rental_outlined),
                      title: const Text('Модерация объявлений'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.adminCars),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Жалобы пользователей'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminComplaints,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Уведомления'),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Уведомления включены',
                value: settings.notificationsEnabled,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'notificationsEnabled', value),
              ),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email уведомления',
                value: settings.emailNotificationsEnabled,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'emailNotificationsEnabled', value),
              ),
              _buildSwitchTile(
                icon: Icons.phone_android_outlined,
                title: 'Push уведомления',
                value: settings.pushNotificationsEnabled,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'pushNotificationsEnabled', value),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Безопасность и модерация'),
              _buildSwitchTile(
                icon: Icons.build_outlined,
                title: 'Режим обслуживания',
                value: settings.maintenanceMode,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'maintenanceMode', value),
              ),
              _buildSwitchTile(
                icon: Icons.how_to_reg_outlined,
                title: 'Проверка новых пользователей',
                value: settings.requireUserVerification,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'requireUserVerification', value),
              ),
              _buildSwitchTile(
                icon: Icons.car_crash_outlined,
                title: 'Модерация объявлений',
                value: settings.moderateListings,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'moderateListings', value),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Интерфейс'),
              _buildDropdownTile(
                icon: Icons.language_outlined,
                title: 'Язык',
                value: settings.language,
                items: const [
                  'ru',
                  'en',
                  'tj',
                  'uz',
                  'zh',
                  'ky',
                  'kk',
                  'ar',
                  'ko',
                ],
                enabled: canEdit,
                onChanged: (value) {
                  if (value != null) {
                    _updateField(provider, 'language', value);
                  }
                },
              ),
              _buildDropdownTile(
                icon: Icons.palette_outlined,
                title: 'Тема',
                value: settings.themeMode,
                items: const ['system', 'light', 'dark'],
                enabled: canEdit,
                onChanged: (value) {
                  if (value != null) {
                    _updateField(provider, 'themeMode', value);
                  }
                },
              ),
              _buildNumberTile(
                icon: Icons.list_alt_outlined,
                title: 'Элементов на странице',
                value: settings.itemsPerPage,
                enabled: canEdit,
                onChanged: (value) =>
                    _updateField(provider, 'itemsPerPage', value),
              ),

              const SizedBox(height: 32),
              if (canEdit) _buildDangerZone(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildNumberTile({
    required IconData icon,
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Уменьшить',
              onPressed: enabled && value > 10
                  ? () => onChanged(value - 10)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 36,
              child: Text(value.toString(), textAlign: TextAlign.center),
            ),
            IconButton(
              tooltip: 'Увеличить',
              onPressed: enabled && value < 100
                  ? () => onChanged(value + 10)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(SettingsProvider provider) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Опасная зона',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Сброс всех настроек к значениям по умолчанию. Это действие нельзя отменить.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Сбросить настройки'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showConfirmDialog(
                  'Сброс настроек',
                  'Вы уверены? Все текущие настройки будут удалены.',
                  () => _resetSettings(provider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
