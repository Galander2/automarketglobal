import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import '../models/car.dart';
import '../repositories/favorite_repository.dart';
import 'app_hover_lift.dart';
import 'optimized_network_image.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final String? favoriteUserId;
  final FavoriteRepository? favoriteRepository;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.favoriteUserId,
    this.favoriteRepository,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppHoverLift(
      enabled: onTap != null,
      borderRadius: AppRadii.large,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: OptimizedNetworkImage(url: car.imageUrl),
                  ),
                  if (favoriteUserId?.isNotEmpty == true)
                    PositionedDirectional(
                      top: AppSpacing.sm,
                      end: AppSpacing.sm,
                      child: _FavoriteButton(
                        userId: favoriteUserId!,
                        carId: car.id,
                        repository: favoriteRepository ?? FavoriteRepository(),
                      ),
                    ),
                  PositionedDirectional(
                    start: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.68),
                        borderRadius: AppRadii.small,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        '${car.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '\$${car.price}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _SpecItem(
                          icon: Icons.speed_rounded,
                          text: '${car.mileage} km',
                        ),
                        _SpecItem(
                          icon: Icons.location_on_outlined,
                          text: car.city.isNotEmpty ? car.city : '—',
                        ),
                      ],
                    ),
                    if (car.route.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.09),
                          borderRadius: AppRadii.small,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.route_rounded,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                car.route,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({
    required this.userId,
    required this.carId,
    required this.repository,
  });

  final String userId;
  final String carId;
  final FavoriteRepository repository;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isSaving = false;

  Future<void> _toggle(bool isFavorite) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await widget.repository.setFavorite(
        userId: widget.userId,
        carId: widget.carId,
        isFavorite: !isFavorite,
      );
    } on FavoriteRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 2,
      child: StreamBuilder<bool>(
        stream: widget.repository.watchIsFavorite(
          userId: widget.userId,
          carId: widget.carId,
        ),
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData;
          final isFavorite = snapshot.data ?? false;
          return IconButton(
            tooltip: isFavorite
                ? 'Удалить из избранного'
                : 'Добавить в избранное',
            onPressed: isLoading || snapshot.hasError || _isSaving
                ? null
                : () => _toggle(isFavorite),
            icon: _isSaving || isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF475569),
                  ),
          );
        },
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SpecItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
