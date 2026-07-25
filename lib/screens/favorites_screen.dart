import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../models/car.dart';
import '../repositories/auth_repository.dart';
import '../repositories/favorite_repository.dart';
import '../widgets/car_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, this.repository});

  final FavoriteRepository? repository;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoriteRepository get _repository =>
      widget.repository ?? FavoriteRepository();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: _FavoritesMessage(
          icon: Icons.lock_outline,
          title: 'Войдите в аккаунт',
          message: 'Авторизация нужна для безопасного хранения избранного.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: StreamBuilder<List<Car>>(
        stream: _repository.watchFavoriteCars(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _FavoritesMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Не удалось загрузить избранное',
              message: snapshot.error.toString(),
              actionLabel: 'Повторить',
              onAction: () => setState(() {}),
            );
          }

          final cars = snapshot.data ?? const <Car>[];
          if (cars.isEmpty) {
            return const _FavoritesMessage(
              icon: Icons.favorite_border,
              title: 'Избранное пока пусто',
              message:
                  'Нажмите на сердечко в карточке автомобиля, чтобы сохранить его.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: cars.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final car = cars[index];
              return CarCard(
                key: ValueKey(car.id),
                car: car,
                favoriteUserId: user.uid,
                favoriteRepository: _repository,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.carDetails,
                  arguments: {'car': car},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoritesMessage extends StatelessWidget {
  const _FavoritesMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
