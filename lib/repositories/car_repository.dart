import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class CarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получить все автомобили
  Future<List<Car>> getAllCars({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _docToCar(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить одобренные автомобили (для главной)
  Future<List<Car>> getApprovedCars({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _docToCar(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить автомобили на модерации (для админа)
  Future<List<Car>> getPendingCars({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _docToCar(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить отклоненные автомобили
  Future<List<Car>> getRejectedCars({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .where('status', isEqualTo: 'rejected')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _docToCar(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить автомобили по стране
  Future<List<Car>> getCarsByCountry(String country, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .where('status', isEqualTo: 'approved')
          .where('country', isEqualTo: country)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _docToCar(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить автомобили пользователя (для my_publications_screen)
  Future<List<Car>> getUserCars(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => _docToCar(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить автомобили продавца (getCarsBySeller - для my_publications_screen)
  Future<List<Car>> getCarsBySeller(String sellerId) async {
    return getUserCars(sellerId);
  }

  // Поиск автомобилей (для search_screen)
  Future<List<Car>> searchCars({
    String? query,
    String? country,
    String? city,
    int? minPrice,
    int? maxPrice,
    int? minYear,
    int? maxYear,
    int limit = 50,
  }) async {
    try {
      Query queryRef = _firestore
          .collection('cars')
          .where('status', isEqualTo: 'approved');

      if (country != null && country.isNotEmpty) {
        queryRef = queryRef.where('country', isEqualTo: country);
      }

      if (city != null && city.isNotEmpty) {
        queryRef = queryRef.where('city', isEqualTo: city);
      }

      queryRef = queryRef.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await queryRef.get();
      final cars = snapshot.docs.map((doc) => _docToCar(doc)).toList();

      // Фильтрация по текстовому запросу (если есть)
      if (query != null && query.isNotEmpty) {
        return cars.where((car) {
          final title = car.title.toLowerCase();
          final description = car.description.toLowerCase();
          final searchQuery = query.toLowerCase();
          return title.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();
      }

      return cars;
    } catch (e) {
      return [];
    }
  }

  // Получить один автомобиль по ID
  Future<Car?> getCarById(String carId) async {
    try {
      final doc = await _firestore.collection('cars').doc(carId).get();
      if (doc.exists) {
        return _docToCar(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Добавить новый автомобиль
  Future<String> addCar(Map<String, dynamic> carData) async {
    try {
      final docRef = await _firestore.collection('cars').add({
        ...carData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Не удалось опубликовать автомобиль');
    }
  }

  // Обновить автомобиль
  Future<void> updateCar(String carId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('cars').doc(carId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Не удалось обновить автомобиль');
    }
  }

  // Обновить статус автомобиля
  Future<void> updateCarStatus(String carId, String newStatus) async {
    try {
      await _firestore.collection('cars').doc(carId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Не удалось обновить статус');
    }
  }

  // Удалить автомобиль
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('cars').doc(carId).delete();
    } catch (e) {
      throw Exception('Не удалось удалить автомобиль');
    }
  }

  // Вспомогательный метод: DocumentSnapshot -> Car
  Car _docToCar(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toString(),
      year: (data['year'] ?? 0).toInt(),
      mileage: (data['mileage'] ?? 0).toInt(),
      city: data['city'] ?? '',
      route: data['route'] ?? '',
      country: data['country'] ?? '',
      description: data['description'] ?? '',
      vin: data['vin'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: CarStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CarStatus.pending,
      ),
    );
  }
}
