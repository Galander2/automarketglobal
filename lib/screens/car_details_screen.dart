import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../models/car.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/favorite_repository.dart';
import '../widgets/optimized_network_image.dart';

class CarDetailsScreen extends StatelessWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final gallery = car.images.isNotEmpty ? car.images : [car.imageUrl];
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isOwnListing = currentUser?.uid == car.sellerId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF111827),
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: gallery.length,
                itemBuilder: (context, index) {
                  return OptimizedNetworkImage(
                    url: gallery[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(status: car.status),
                  const SizedBox(height: 14),
                  Text(
                    car.title,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.price,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.calendar_month,
                          title: 'Год',
                          value: car.year.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.speed,
                          title: 'Пробег',
                          value: '${car.mileage} km',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.location_on,
                          title: 'Город',
                          value: car.city,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.local_shipping,
                          title: 'Маршрут',
                          value: car.route,
                        ),
                      ),
                    ],
                  ),
                  if (car.transmission.isNotEmpty ||
                      car.bodyType.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SpecCard(
                            icon: Icons.settings_outlined,
                            title: 'Коробка',
                            value: car.transmission.isEmpty
                                ? 'Не указано'
                                : car.transmission,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SpecCard(
                            icon: Icons.directions_car_filled_outlined,
                            title: 'Кузов',
                            value: car.bodyType.isEmpty
                                ? 'Не указано'
                                : car.bodyType,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (car.fuelType.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SpecCard(
                      icon: Icons.local_gas_station_outlined,
                      title: 'Топливо',
                      value: car.fuelType,
                    ),
                  ],
                  const SizedBox(height: 26),
                  const Text(
                    'Описание',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    car.description.isEmpty
                        ? 'Описание пока не добавлено.'
                        : car.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Проверка автомобиля',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _CheckTile(
                    icon: Icons.confirmation_number,
                    title: 'VIN',
                    value: car.vin.isEmpty ? 'Не указан' : car.vin,
                  ),
                  const _CheckTile(
                    icon: Icons.verified_user,
                    title: 'История автомобиля',
                    value: 'Будет подключена через внешний сервис',
                  ),
                  const _CheckTile(
                    icon: Icons.security,
                    title: 'Модерация',
                    value: 'Проверка документов и продавца',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _FavoriteDetailsButton(
                userId: currentUser?.uid,
                carId: car.id,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isOwnListing
                    ? null
                    : () async {
                        final user = context.read<AuthProvider>().currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Войдите в аккаунт, чтобы написать продавцу',
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          final thread = await ChatRepository().openConversation(
                            car: car,
                            buyer: user,
                          );
                          if (!context.mounted) return;
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.chat,
                            arguments: {'thread': thread},
                          );
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
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(isOwnListing ? 'Ваше объявление' : 'Связаться'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteDetailsButton extends StatefulWidget {
  const _FavoriteDetailsButton({
    required this.userId,
    required this.carId,
  });

  final String? userId;
  final String carId;

  @override
  State<_FavoriteDetailsButton> createState() =>
      _FavoriteDetailsButtonState();
}

class _FavoriteDetailsButtonState extends State<_FavoriteDetailsButton> {
  final FavoriteRepository _repository = FavoriteRepository();
  bool _isSaving = false;

  Future<void> _toggle(bool isFavorite) async {
    final userId = widget.userId;
    if (userId == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _repository.setFavorite(
        userId: userId,
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
    final userId = widget.userId;
    if (userId == null) {
      return const OutlinedButton(
        onPressed: null,
        child: Text('Избранное'),
      );
    }

    return StreamBuilder<bool>(
      stream: _repository.watchIsFavorite(
        userId: userId,
        carId: widget.carId,
      ),
      builder: (context, snapshot) {
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData;
        final isFavorite = snapshot.data ?? false;
        return OutlinedButton.icon(
          onPressed: isLoading || snapshot.hasError || _isSaving
              ? null
              : () => _toggle(isFavorite),
          icon: _isSaving || isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFE11D48) : null,
                ),
          label: Text(
            isFavorite ? 'В избранном' : 'Избранное',
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SpecCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _CheckTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.10),
            child: const Icon(Icons.security, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CarStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;

    switch (status) {
      case CarStatus.pending:
        text = 'На модерации';
        color = Colors.orange;
        break;
      case CarStatus.approved:
        text = 'Проверено';
        color = Colors.green;
        break;
      case CarStatus.rejected:
        text = 'Отклонено';
        color = Colors.red;
        break;
      case CarStatus.sold:
        text = 'Продано';
        color = Colors.blueGrey;
        break;
      case CarStatus.draft:
        text = 'Черновик';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
