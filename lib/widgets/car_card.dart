import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppHoverLift(
      enabled: onTap != null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Header
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          OptimizedNetworkImage(url: car.imageUrl),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (car.year > 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
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
                  if (favoriteUserId?.isNotEmpty == true)
                    PositionedDirectional(
                      top: 10,
                      end: 10,
                      child: _FavoriteButton(
                        userId: favoriteUserId!,
                        carId: car.id,
                        repository: favoriteRepository ?? FavoriteRepository(),
                      ),
                    ),
                ],
              ),

              // Info Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${car.price}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: [
                        _SpecItem(
                          icon: Icons.speed_rounded,
                          text: '${car.mileage} км',
                        ),
                        _SpecItem(
                          icon: Icons.location_on_outlined,
                          text: car.city.isNotEmpty ? car.city : '—',
                        ),
                      ],
                    ),
                    if (car.route.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.route_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                car.route,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
