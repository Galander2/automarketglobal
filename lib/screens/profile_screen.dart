import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../widgets/optimized_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('profile')),
        actions: [
          IconButton(
            tooltip: 'Настройки',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        key: const PageStorageKey('profile-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 22),
          Text(
            'Личный кабинет',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _ProfileGroup(
            children: [
              _ProfileMenuItem(
                icon: Icons.manage_accounts_outlined,
                title: 'Редактировать профиль',
                subtitle: 'Имя, телефон и фотография',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
              ),
              _ProfileMenuItem(
                icon: Icons.directions_car_outlined,
                title: l10n.translate('myPublications'),
                subtitle: 'Ваши объявления и их статусы',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.myPublications),
              ),
              _ProfileMenuItem(
                icon: Icons.forum_outlined,
                title: 'Сообщения',
                subtitle: 'Диалоги с покупателями и продавцами',
                onTap: () => Navigator.pushNamed(context, AppRoutes.chats),
              ),
              _ProfileMenuItem(
                icon: Icons.favorite_border_rounded,
                title: l10n.translate('favorites'),
                subtitle: 'Сохранённые автомобили',
                onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Сервисы',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _ProfileGroup(
            children: [
              _ProfileMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.translate('wallet'),
                subtitle: 'Баланс и история операций',
                onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
              ),
              _ProfileMenuItem(
                icon: Icons.local_shipping_outlined,
                title: l10n.translate('delivery'),
                subtitle: 'Перевозка и отслеживание',
                onTap: () => Navigator.pushNamed(context, AppRoutes.delivery),
              ),
              _ProfileMenuItem(
                icon: Icons.tune_rounded,
                title: 'Настройки',
                subtitle: auth.isAdmin
                    ? 'Аккаунт, приложение и управление'
                    : 'Аккаунт, язык, тема и безопасность',
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
          if (auth.isAdmin) ...[
            const SizedBox(height: 22),
            Text(
              'Управление',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _ProfileGroup(
              accent: AppColors.danger,
              children: [
                _ProfileMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Админ-панель',
                  subtitle: 'Безопасное управление платформой',
                  accent: AppColors.danger,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user?.role);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), AppColors.primaryDark, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final avatar = Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: user?.avatar?.isNotEmpty == true
                  ? OptimizedNetworkImage(
                      url: user!.avatar!,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.white.withValues(alpha: 0.14),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
            ),
          );
          final details = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Гость',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user?.email ?? '',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: roleColor.withValues(alpha: 0.65),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user?.role == UserRole.superAdmin
                          ? Icons.workspace_premium_outlined
                          : Icons.verified_user_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user?.roleTitle ?? 'Пользователь',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          if (compact) {
            return Column(
              children: [avatar, const SizedBox(height: 14), details],
            );
          }
          return Row(
            children: [
              avatar,
              const SizedBox(width: 20),
              Expanded(child: details),
              IconButton.filledTonal(
                tooltip: 'Редактировать профиль',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          );
        },
      ),
    );
  }

  static Color _roleColor(UserRole? role) {
    switch (role) {
      case UserRole.superAdmin:
      case UserRole.admin:
        return const Color(0xFFFF6B6B);
      case UserRole.dealer:
        return const Color(0xFFC084FC);
      case UserRole.seller:
        return const Color(0xFFFBBF24);
      case UserRole.user:
      case null:
        return const Color(0xFF67E8F9);
    }
  }
}

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.children, this.accent});

  final List<Widget> children;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: accent?.withValues(alpha: 0.22) ??
              Theme.of(context).dividerColor,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.accent = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 72,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.muted,
        size: 15,
      ),
      onTap: onTap,
    );
  }
}
