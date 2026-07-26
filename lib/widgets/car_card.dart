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
    return AppHoverLift(
      enabled: onTap != null,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: OptimizedNetworkImage(url: car.imageUrl),
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

            // Информация
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Заголовок
                Text(
                  car.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Цена
                Text(
                  '\$${car.price}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 10),

                // Характеристики
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _SpecItem(
                      icon: Icons.calendar_month_outlined,
                      text: '${car.year}',
                    ),
                    _SpecItem(icon: Icons.speed, text: '${car.mileage} km'),
                    _SpecItem(
                      icon: Icons.location_on,
                      text: car.city.isNotEmpty ? car.city : '—',
                    ),
                  ],
                ),

                // Страна и статус
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (car.route.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.route_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              car.route,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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
