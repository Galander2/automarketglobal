import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../models/car.dart';
import '../repositories/auth_repository.dart';
import '../repositories/favorite_repository.dart';
import '../widgets/car_card.dart';
import '../widgets/app_state_view.dart';

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
        body: AppStateView(
          type: AppStateType.empty,
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
            return const AppStateView(type: AppStateType.loading);
          }
          if (snapshot.hasError) {
            return AppStateView(
              type: AppStateType.error,
              title: 'Не удалось загрузить избранное',
              message: snapshot.error.toString(),
              actionLabel: 'Повторить',
              onAction: () => setState(() {}),
            );
          }

          final cars = snapshot.data ?? const <Car>[];
          if (cars.isEmpty) {
            return const AppStateView(
              type: AppStateType.empty,
              title: 'Избранное пока пусто',
              message:
                  'Нажмите на сердечко в карточке автомобиля, чтобы сохранить его.',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 1260
                  ? 3
                  : constraints.maxWidth >= 760
                  ? 2
                  : 1;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // A car card contains a 16:10 image plus specification
                  // rows. Keeping a portrait ratio prevents overflows on
                  // narrow phones and preserves the same rhythm on desktop.
                  childAspectRatio: count == 1 ? 0.82 : 0.92,
                ),
                itemCount: cars.length,
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
          );
        },
      ),
    );
  }
}
