import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/car.dart';
import 'car_repository.dart';

class FavoriteRepositoryException implements Exception {
  const FavoriteRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FavoriteRepository {
  factory FavoriteRepository() => _instance;

  FavoriteRepository.withFirestore(
    FirebaseFirestore firestore, {
    CarRepository? carRepository,
  }) : _firestore = firestore,
       _carRepository = carRepository ?? CarRepository.withFirestore(firestore);

  FavoriteRepository._()
    : _firestore = FirebaseFirestore.instance,
      _carRepository = CarRepository();

  static final FavoriteRepository _instance = FavoriteRepository._();

  final FirebaseFirestore _firestore;
  final CarRepository _carRepository;

  CollectionReference<Map<String, dynamic>> _favorites(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  Stream<bool> watchIsFavorite({
    required String userId,
    required String carId,
  }) {
    _validateIds(userId: userId, carId: carId);
    return _favorites(userId)
        .doc(carId)
        .snapshots()
        .map((snapshot) => snapshot.exists)
        .handleError((Object error) {
          throw FavoriteRepositoryException(_readError(error));
        });
  }

  Stream<List<Car>> watchFavoriteCars(String userId) {
    if (userId.trim().isEmpty) {
      return Stream<List<Car>>.value(const <Car>[]);
    }

    return _favorites(userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .asyncMap((snapshot) async {
          final cars = await Future.wait(
            snapshot.docs.map(
              (favorite) => _carRepository.getCarById(favorite.id),
            ),
          );
          return cars
              .whereType<Car>()
              .where((car) => car.isApproved)
              .toList(growable: false);
        })
        .handleError((Object error) {
          throw FavoriteRepositoryException(_readError(error));
        });
  }

  Future<void> setFavorite({
    required String userId,
    required String carId,
    required bool isFavorite,
  }) async {
    _validateIds(userId: userId, carId: carId);
    final reference = _favorites(userId).doc(carId);

    try {
      if (isFavorite) {
        await reference.set({
          'carId': carId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await reference.delete();
      }
    } on FirebaseException catch (error) {
      throw FavoriteRepositoryException(_readError(error));
    }
  }

  void _validateIds({required String userId, required String carId}) {
    if (userId.trim().isEmpty || carId.trim().isEmpty) {
      throw const FavoriteRepositoryException(
        'Не удалось определить пользователя или автомобиль.',
      );
    }
  }

  String _readError(Object error) {
    if (error is FavoriteRepositoryException) return error.message;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Нет доступа к избранному. Войдите в аккаунт повторно.';
        case 'unavailable':
          return 'Сервис временно недоступен. Проверьте интернет.';
      }
    }
    return 'Не удалось обновить избранное. Повторите попытку.';
  }
}
