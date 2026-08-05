import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/design_tokens.dart';
import 'app_motion.dart';

enum AppStateType { loading, empty, error, offline }

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final AppStateType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final data = _data(type);
    final color = type == AppStateType.error
        ? Theme.of(context).colorScheme.error
        : type == AppStateType.offline
        ? AppColors.warning
        : AppColors.primary;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: MotionReveal(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (type == AppStateType.loading)
                  const AppShimmer(
                    child: Column(
                      children: [
                        AppSkeletonBlock(
                          height: 76,
                          width: 76,
                          borderRadius: AppRadii.large,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        AppSkeletonBlock(height: 24, width: 210),
                        SizedBox(height: AppSpacing.sm),
                        AppSkeletonBlock(height: 16, width: 300),
                      ],
                    ),
                  )
                else
                  Container(
                    width: compact ? 60 : 76,
                    height: compact ? 60 : 76,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: color.withValues(alpha: 0.18)),
                    ),
                    child: Icon(data.$1, color: color, size: compact ? 30 : 38),
                  ),
                if (type != AppStateType.loading) ...[
                  SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
                  Text(
                    title ?? data.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message ?? data.$3,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, String, String) _data(AppStateType value) => switch (value) {
    AppStateType.loading => (
      Icons.hourglass_top_rounded,
      'Загружаем данные',
      'Это займёт всего несколько секунд.',
    ),
    AppStateType.empty => (
      Icons.inbox_outlined,
      'Здесь пока пусто',
      'Новые данные появятся здесь автоматически.',
    ),
    AppStateType.error => (
      Icons.error_outline_rounded,
      'Что-то пошло не так',
      'Повторите попытку. Ваши данные не были потеряны.',
    ),
    AppStateType.offline => (
      Icons.wifi_off_rounded,
      'Нет подключения',
      'Проверьте интернет и попробуйте ещё раз.',
    ),
  };
}
