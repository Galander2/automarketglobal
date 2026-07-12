import 'package:flutter/material.dart';
import 'package:flutter_application_1_car_sales/core/router/app_routes.dart';
import 'package:flutter_application_1_car_sales/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('profile')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF2563EB),
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Гость',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Center(
            child: Text(
              'user@example.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),

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
            subtitle: 'Русский / English / Тоҷикӣ / O\'zbek',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.languageSelection);
            },
          ),

          _ProfileMenuItem(
            icon: Icons.settings,
            title: l10n.translate('settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Настройки откроются позже')),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: l10n.translate('help'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Помощь откроется позже')),
              );
            },
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выход из аккаунта')),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}