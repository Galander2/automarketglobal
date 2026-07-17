import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import '../models/admin_settings.dart';
import '../provider/settings_provider.dart';
import '../repositories/auth_repository.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late SettingsProvider _settingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = context.read<SettingsProvider>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          return ListView(
    return Consumer2<SettingsProvider, AuthProvider>(
      builder: (context, settingsProvider, authProvider, _) {
        if (settingsProvider.isLoading && settingsProvider.settings == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = settingsProvider.settings ?? AdminSettings.defaults();
        final adminUid = authProvider.currentUser?.uid ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Настройки'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Общие настройки'),
              _buildSettingsCard([
                _buildSwitchTile(
                  title: 'Уведомления',
                  subtitle: 'Включить систему уведомлений',
                  value: provider.notificationsEnabled,
                  onChanged: (value) {
                    provider.setNotificationsEnabled(value);
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'notificationsEnabled',
                      value,
                      adminUid,
                    );
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Email уведомления',
                  subtitle: 'Получать уведомления на email',
                  value: provider.emailNotifications,
                  onChanged: (value) {
                    provider.setEmailNotifications(value);
                  value: settings.emailNotificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'emailNotificationsEnabled',
                      value,
                      adminUid,
                    );
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Push уведомления',
                  subtitle: 'Отправлять push-уведомления',
                  value: provider.pushNotifications,
                  onChanged: (value) {
                    provider.setPushNotifications(value);
                  value: settings.pushNotificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'pushNotificationsEnabled',
                      value,
                      adminUid,
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Модерация'),
              _buildSettingsCard([
                _buildSwitchTile(
                  title: 'Режим обслуживания',
                  subtitle: 'Временно отключить доступ пользователям',
                  value: provider.maintenanceMode,
                  onChanged: (value) {
                    provider.setMaintenanceMode(value);
                  value: settings.maintenanceMode,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'maintenanceMode',
                      value,
                      adminUid,
                    );
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Проверка новых пользователей',
                  subtitle: 'Требовать подтверждение регистрации',
                  value: provider.newUserApprovalRequired,
                  onChanged: (value) {
                    provider.setNewUserApprovalRequired(value);
                  value: settings.requireUserVerification,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'requireUserVerification',
                      value,
                      adminUid,
                    );
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'Модерация объявлений',
                  subtitle: 'Проверять объявления перед публикацией',
                  value: provider.carModerationEnabled,
                  onChanged: (value) {
                    provider.setCarModerationEnabled(value);
                  value: settings.moderateListings,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'moderateListings',
                      value,
                      adminUid,
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Интерфейс'),
              _buildSettingsCard([
                _buildDropdownTile(
                  title: 'Язык',
                  subtitle: 'Выберите язык интерфейса',
                  value: provider.selectedLanguage,
                  value: settings.language,
                  items: const [
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedLanguage(value);
                      settingsProvider.updateField('language', value, adminUid);
                    }
                  },
                ),
                _buildDivider(),
                _buildDropdownTile(
                  title: 'Тема',
                  subtitle: 'Выберите тему оформления',
                  value: provider.selectedTheme,
                  value: settings.themeMode,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('Системная')),
                    DropdownMenuItem(value: 'light', child: Text('Светлая')),
                    DropdownMenuItem(value: 'dark', child: Text('Тёмная')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedTheme(value);
                      settingsProvider.updateField('themeMode', value, adminUid);
                    }
                  },
                ),
                _buildDivider(),
                _buildNumberTile(
                  title: 'Элементов на страницу',
                  subtitle: 'Количество записей в таблицах',
                  value: provider.itemsPerPage,
                  onChanged: (value) {
                    provider.setItemsPerPage(value);
                  value: settings.itemsPerPage,
                  onChanged: (value) {
                    settingsProvider.updateField(
                      'itemsPerPage',
                      value,
                      adminUid,
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Данные'),
              _buildSettingsCard([
                ListTile(
                  leading: const Icon(Icons.backup, color: Color(0xFF2563EB)),
                  title: const Text('Резервное копирование'),
                  subtitle: const Text('Создать резервную копию данных'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('Резервное копирование начато');
                  subtitle: const Text('Требуется серверная настройка'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('Функция требует серверной настройки');
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: const Icon(Icons.restore, color: Color(0xFF10B981)),
                  title: const Text('Восстановление'),
                  subtitle: const Text('Восстановить данные из копии'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('Открыто меню восстановления');
                  subtitle: const Text('Требуется серверная настройка'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('Функция требует серверной настройки');
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  leading:
                      const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  title: const Text('Очистка кэша'),
                  subtitle: const Text('Удалить временные файлы'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showConfirmDialog(
                      'Очистка кэша',
                      'Вы уверены, что хотите очистить кэш?',
                      () {
                      () async {
                        // Очистка кэша приложения
                        await _clearCache();
                        _showSnackBar('Кэш очищен');
                      },
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Безопасность'),
              _buildSettingsCard([
                ListTile(
                  leading: const Icon(Icons.lock, color: Color(0xFF8B5CF6)),
                  title: const Text('Сменить пароль'),
                  subtitle: const Text('Изменить пароль администратора'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showChangePasswordDialog();
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: const Icon(Icons.security, color: Color(0xFFF59E0B)),
                  title: const Text('Двухфакторная аутентификация'),
                  subtitle: const Text('Настроить 2FA'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('Настройка 2FA в разработке');
                  leading:
                      const Icon(Icons.security, color: Color(0xFFF59E0B)),
                  title: const Text('Двухфакторная аутентификация'),
                  subtitle: const Text('Требуется настройка Firebase Console'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar(
                        'Функция требует настройки Firebase Console');
                  },
                ),
              ]),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  _showSnackBar('Настройки сохранены');
                onPressed: () async {
                  try {
                    await settingsProvider.saveSettings(settings, adminUid);
                    _showSnackBar('Настройки сохранены');
                  } catch (e) {
                    _showSnackBar('Ошибка сохранения: ${e.toString()}');
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Сохранить настройки'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  await provider.resetToDefaults();
                  _showSnackBar('Настройки сброшены');
                  final confirmed = await _showResetConfirmDialog();
                  if (confirmed && mounted) {
                    try {
                      await settingsProvider.resetSettings(adminUid);
                      _showSnackBar('Настройки сброшены');
                    } catch (e) {
                      _showSnackBar('Ошибка сброса: ${e.toString()}');
                    }
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Сбросить настройки'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2563EB),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 72);
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberTile({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: value > 10 ? () => onChanged(value - 10) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF2563EB),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 10),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _showResetConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Сбросить настройки'),
            content: const Text(
              'Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _clearCache() async {
    // Очистка временных данных приложения
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сменить пароль'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Текущий пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Новый пароль',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Подтвердите пароль',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text &&
                  newPasswordController.text.isNotEmpty) {
                Navigator.pop(context);
                _showSnackBar('Пароль успешно изменён');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пароли не совпадают или пустые'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
