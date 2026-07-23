import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/models/car.dart';
import 'package:flutter_application_1_car_sales/screens/home_screen.dart';

void main() {
  testWidgets('home displays cars returned by the data source', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          loadCars: ({required bool forceRefresh}) async => [_testCar],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Auto Market Global'), findsOneWidget);
    expect(find.text('Toyota Camry 2022'), findsOneWidget);
    expect(find.text('Новые автомобили (1)'), findsOneWidget);
  });

  testWidgets('home retries loading after an error', (tester) async {
    var calls = 0;
    Future<List<Car>> loader({required bool forceRefresh}) async {
      calls++;
      if (calls == 1) throw Exception('network error');
      return [_testCar];
    }

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(loadCars: loader)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Не удалось загрузить автомобили'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Toyota Camry 2022'), findsOneWidget);
  });

  testWidgets('home offers publishing when the market is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          loadCars: ({required bool forceRefresh}) async => const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Объявлений пока нет'), findsOneWidget);
    expect(find.text('Продать автомобиль'), findsOneWidget);
  });
}

final _testCar = Car(
  id: 'car-1',
  sellerId: 'seller-1',
  title: 'Toyota Camry 2022',
  price: '25000',
  year: 2022,
  mileage: 24000,
  city: 'Душанбе',
  route: 'Корея → Таджикистан',
  country: 'Таджикистан',
  status: CarStatus.approved,
  imageUrl: '',
  createdAt: DateTime(2026),
);
