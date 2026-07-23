import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../models/car.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';

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
                  return Image.network(
                    gallery[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.directions_car,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
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
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
                label: const Text('Избранное'),
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
