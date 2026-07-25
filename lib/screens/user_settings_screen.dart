import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../repositories/auth_repository.dart';
import '../services/language_service.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  Future<void> _sendPasswordReset(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final email = auth.currentUser?.email.trim() ?? '';
    if (email.isEmpty) {
      _message(context, 'У аккаунта не указан email', error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить пароль?'),
        content: Text('Ссылка для смены пароля будет отправлена на $email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await auth.resetPassword(email);
      if (context.mounted) {
        _message(context, 'Письмо для смены пароля отправлено');
      }
    } catch (_) {
      if (context.mounted) {
        _message(
          context,
          'Не удалось отправить письмо. Повторите позже.',
          error: true,
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'На этом устройстве потребуется снова выполнить вход.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await auth.signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  static void _message(
    BuildContext context,
    String text, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final preferences = context.watch<LanguageService>();
    final user = auth.currentUser;

    if (auth.isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Для настроек необходимо войти в аккаунт')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Аккаунт',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Редактировать профиль'),
                subtitle: Text(user.fullName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Роль и доступ'),
                subtitle: Text(user.roleTitle),
              ),
              ListTile(
                leading: Icon(
                  user.emailVerified
                      ? Icons.verified_user_outlined
                      : Icons.warning_amber_outlined,
                ),
                title: const Text('Подтверждение email'),
                subtitle: Text(
                  user.emailVerified ? 'Email подтверждён' : 'Email не подтверждён',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Приложение',
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Язык интерфейса'),
                subtitle: Text(preferences.getLanguageName()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.languageSelection),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Тема'),
                trailing: DropdownButton<ThemeMode>(
                  value: preferences.themeMode,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value != null) preferences.setThemeMode(value);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Системная'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Светлая'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Тёмная'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Безопасность',
            children: [
              ListTile(
                leading: const Icon(Icons.password_outlined),
                title: const Text('Изменить пароль'),
                subtitle: const Text('Получить защищённую ссылку на email'),
                trailing: const Icon(Icons.chevron_right),
                enabled: !auth.isLoading,
                onTap: () => _sendPasswordReset(context, auth),
              ),
              const ListTile(
                leading: Icon(Icons.security_outlined),
                title: Text('Защита данных'),
                subtitle: Text(
                  'Роль и системные права нельзя изменить из профиля',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: auth.isLoading ? null : () => _signOut(context, auth),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти из аккаунта'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
