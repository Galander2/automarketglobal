import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../core/router/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('profile')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF2563EB),
            child: user?.avatar != null
                ? ClipOval(
                    child: Image.network(
                      user!.avatar!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.fullName ?? 'Гость',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          if (user?.role != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(user!.role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getRoleColor(user.role), width: 1),
                ),
                child: Text(
                  _getRoleTitle(user.role),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Редактировать профиль',
            onTap: () {
              Navigator.pushNamed(context, '/profile/edit');
            },
          ),
          _ProfileMenuItem(
            icon: Icons.car_rental,
            title: l10n.translate('myPublications'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myPublications);
            },
          ),
          _ProfileMenuItem(
            icon: Icons.favorite,
            title: l10n.translate('favorites'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.favorites);
            },
          ),
          _ProfileMenuItem(
            icon: Icons.account_balance_wallet,
            title: l10n.translate('wallet'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.wallet);
            },
          ),
          _ProfileMenuItem(
            icon: Icons.local_shipping,
            title: l10n.translate('delivery'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.delivery);
            },
          ),

          // Переключатель языка
          _ProfileMenuItem(
            icon: Icons.language,
            title: l10n.translate('language'),
            subtitle: context.watch<LanguageService>().getLanguageName(),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.languageSelection);
            },
          ),

          // Админ-панель (только для админов)
          if (authProvider.isAdmin) ...[
            _ProfileMenuItem(
              icon: Icons.admin_panel_settings,
              title: 'Админ-панель',
              subtitle: 'Управление системой',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.admin);
              },
            ),
          ],

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выход из аккаунта'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await authProvider.signOut();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.translate('logout')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(dynamic role) {
    switch (role.toString()) {
      case 'UserRole.admin':
      case 'UserRole.superAdmin':
        return Colors.red;
      case 'UserRole.dealer':
        return Colors.purple;
      case 'UserRole.seller':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getRoleTitle(dynamic role) {
    switch (role.toString()) {
      case 'UserRole.admin':
        return 'Администратор';
      case 'UserRole.superAdmin':
        return 'Владелец платформы';
      case 'UserRole.dealer':
        return 'Дилер';
      case 'UserRole.seller':
        return 'Продавец';
      default:
        return 'Пользователь';
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
