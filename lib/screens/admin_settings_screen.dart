import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import '../provider/auth_provider.dart'; // Убедитесь, что этот файл существует

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Запускаем прослушивание настроек при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SettingsProvider>();
      provider.startListening();
    });
  }

  Future<void> _showConfirmDialog(String title, String message, VoidCallback onConfirm) async {
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
            child: const Text('Подтвердить', style: TextStyle(color: Colors.white)),
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
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
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
              _buildSectionTitle('Уведомления'),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Уведомления включены',
                value: settings.notificationsEnabled,
                onChanged: (value) => provider.updateSetting(notificationsEnabled: value),
              ),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email уведомления',
                value: settings.emailNotificationsEnabled,
                onChanged: (value) => provider.updateSetting(emailNotificationsEnabled: value),
              ),
              _buildSwitchTile(
                icon: Icons.phone_android_outlined,
                title: 'Push уведомления',
                value: settings.pushNotificationsEnabled,
                onChanged: (value) => provider.updateSetting(pushNotificationsEnabled: value),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Безопасность и модерация'),
              _buildSwitchTile(
                icon: Icons.build_outlined,
                title: 'Режим обслуживания',
                value: settings.maintenanceMode,
                onChanged: (value) => provider.updateSetting(maintenanceMode: value),
              ),
              _buildSwitchTile(
                icon: Icons.person_check_outlined,
                title: 'Проверка новых пользователей',
                value: settings.requireUserVerification,
                onChanged: (value) => provider.updateSetting(requireUserVerification: value),
              ),
              _buildSwitchTile(
                icon: Icons.car_crash_outlined,
                title: 'Модерация объявлений',
                value: settings.moderateListings,
                onChanged: (value) => provider.updateSetting(moderateListings: value),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Интерфейс'),
              _buildDropdownTile(
                icon: Icons.language_outlined,
                title: 'Язык',
                value: settings.language,
                items: const ['ru', 'en', 'de'],
                onChanged: (value) => provider.updateSetting(language: value!),
              ),
              _buildDropdownTile(
                icon: Icons.palette_outlined,
                title: 'Тема',
                value: settings.themeMode,
                items: const ['system', 'light', 'dark'],
                onChanged: (value) => provider.updateSetting(themeMode: value!),
              ),
              _buildNumberTile(
                icon: Icons.list_alt_outlined,
                title: 'Элементов на странице',
                value: settings.itemsPerPage,
                onChanged: (value) => provider.updateSetting(itemsPerPage: value),
              ),

              const SizedBox(height: 32),
              _buildDangerZone(provider),
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
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNumberTile({
    required IconData icon,
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: SizedBox(
          width: 100,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: TextEditingController(text: value.toString()),
            onSubmitted: (val) {
              final parsed = int.tryParse(val);
              if (parsed != null) onChanged(parsed);
            },
          ),
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
                Text('Опасная зона', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Сброс всех настроек к значениям по умолчанию. Это действие нельзя отменить.'),
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
                  () => provider.resetToDefaults(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}