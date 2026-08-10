import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/cars/car_search_engine.dart';
import '../models/car.dart';
import '../models/car_search_filters.dart';

class CarRepositoryException implements Exception {
  const CarRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CarRepository {
  factory CarRepository() => _instance;

  CarRepository.withFirestore(FirebaseFirestore firestore)
    : _firestore = firestore;

  CarRepository._() : _firestore = FirebaseFirestore.instance;

  static final CarRepository _instance = CarRepository._();
  static const Duration _cacheLifetime = Duration(minutes: 2);

  final FirebaseFirestore _firestore;
  final Map<String, _CacheEntry<List<Car>>> _cache = {};
  final Map<String, Future<List<Car>>> _requestsInProgress = {};

  Future<List<Car>> getAllCars({int limit = 50, bool forceRefresh = false}) {
    return _loadCars(
      cacheKey: 'all:$limit',
      forceRefresh: forceRefresh,
      query: _firestore
          .collection('cars')
          .orderBy('createdAt', descending: true)
          .limit(limit),
    );
  }

  Future<List<Car>> getApprovedCars({
    int limit = 50,
    bool forceRefresh = false,
  }) {
    return _loadCars(
      cacheKey: 'approved:$limit',
      forceRefresh: forceRefresh,
      query: _statusQuery('approved', limit),
    );
  }

  Future<List<Car>> getPendingCars({
    int limit = 50,
    bool forceRefresh = false,
  }) {
    return _loadCars(
      cacheKey: 'pending:$limit',
      forceRefresh: forceRefresh,
      query: _statusQuery('pending', limit),
    );
  }

  Future<List<Car>> getRejectedCars({
    int limit = 50,
    bool forceRefresh = false,
  }) {
    return _loadCars(
      cacheKey: 'rejected:$limit',
      forceRefresh: forceRefresh,
      query: _statusQuery('rejected', limit),
    );
  }

  Future<List<Car>> getCarsByCountry(
    String country, {
    int limit = 50,
    bool forceRefresh = false,
  }) {
    final normalizedCountry = country.trim();
    return _loadCars(
      cacheKey: 'country:${normalizedCountry.toLowerCase()}:$limit',
      forceRefresh: forceRefresh,
      query: _firestore
          .collection('cars')
          .where('status', isEqualTo: 'approved')
          .where('country', isEqualTo: normalizedCountry)
          .orderBy('createdAt', descending: true)
          .limit(limit),
    );
  }

  Future<List<Car>> getUserCars(String userId, {bool forceRefresh = false}) {
    return _loadCars(
      cacheKey: 'seller:$userId',
      forceRefresh: forceRefresh,
      query: _firestore
          .collection('cars')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true),
    );
  }

  Future<List<Car>> getCarsBySeller(String sellerId) {
    return getUserCars(sellerId);
  }

  Future<List<Car>> searchCars({
    String? query,
    CarSearchFilters filters = const CarSearchFilters(),
    int limit = 200,
    bool forceRefresh = false,
  }) async {
    final searchQuery = _normalize(query ?? '');

    final cars = await _loadCars(
      // Search and filter operations are performed locally by CarSearchEngine.
      // Reuse the same approved-cars snapshot instead of downloading it again
      // for every typed character or filter combination.
      cacheKey: 'approved-search-source:$limit',
      forceRefresh: forceRefresh,
      query: _statusQuery('approved', limit),
    );

    return CarSearchEngine.apply(cars, query: searchQuery, filters: filters);
  }

  Future<Car?> getCarById(String carId) async {
    try {
      final doc = await _firestore.collection('cars').doc(carId).get();
      return doc.exists ? _docToCar(doc) : null;
    } on FirebaseException catch (error) {
      throw CarRepositoryException(_readError(error));
    }
  }

  Future<String> addCar(Map<String, dynamic> carData) async {
    try {
      final docRef = await _firestore.collection('cars').add({
        ...carData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      clearCache();
      return docRef.id;
    } on FirebaseException catch (error) {
      throw CarRepositoryException(_readError(error));
    }
  }

  Future<void> updateCar(String carId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('cars').doc(carId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      clearCache();
    } on FirebaseException catch (error) {
      throw CarRepositoryException(_readError(error));
    }
  }

  Future<void> updateCarStatus(String carId, String newStatus) {
    return updateCar(carId, {'status': newStatus});
  }

  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('cars').doc(carId).delete();
      clearCache();
    } on FirebaseException catch (error) {
      throw CarRepositoryException(_readError(error));
    }
  }

  void clearCache() {
    _cache.clear();
  }

  Query<Map<String, dynamic>> _statusQuery(String status, int limit) {
    return _firestore
        .collection('cars')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(limit);
  }

  Future<List<Car>> _loadCars({
    required String cacheKey,
    required Query<Map<String, dynamic>> query,
    required bool forceRefresh,
  }) {
    final cached = _cache[cacheKey];
    if (!forceRefresh && cached != null && cached.isFresh) {
      return Future.value(cached.value);
    }

    final existingRequest = _requestsInProgress[cacheKey];
    if (!forceRefresh && existingRequest != null) return existingRequest;

    final request = query
        .get()
        .then((snapshot) {
          final cars = snapshot.docs.map(_docToCar).toList(growable: false);
          _cache[cacheKey] = _CacheEntry(cars, _cacheLifetime);
          return cars;
        })
        .onError<FirebaseException>((error, stackTrace) {
          throw CarRepositoryException(_readError(error));
        })
        .whenComplete(() {
          _requestsInProgress.remove(cacheKey);
        });

    _requestsInProgress[cacheKey] = request;
    return request;
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^a-zа-яқғӣӯҳҷәөұүңһі0-9]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _readError(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Нет доступа к данным. Проверьте правила Firestore.';
    }
    if (error.code == 'failed-precondition') {
      return 'Для этого запроса требуется индекс Firestore.';
    }
    if (error.code == 'unavailable') {
      return 'Сервис временно недоступен. Проверьте интернет и повторите.';
    }
    return 'Не удалось загрузить данные. Повторите попытку.';
  }

  Car _docToCar(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Car(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toString(),
      year: (data['year'] as num?)?.toInt() ?? 0,
      mileage: (data['mileage'] as num?)?.toInt() ?? 0,
      city: data['city'] ?? '',
      route: data['route'] ?? '',
      country: data['country'] ?? '',
      description: data['description'] ?? '',
      vin: data['vin'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      transmission: data['transmission'] ?? '',
      bodyType: data['bodyType'] ?? '',
      fuelType: data['fuelType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: CarStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => CarStatus.pending,
      ),
    );
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value, Duration lifetime)
    : expiresAt = DateTime.now().add(lifetime);

  final T value;
  final DateTime expiresAt;

  bool get isFresh => DateTime.now().isBefore(expiresAt);
}
