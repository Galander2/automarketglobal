import 'package:flutter/material.dart';
import 'package:flutter_application_1_car_sales/models/car.dart';
import 'package:flutter_application_1_car_sales/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await _scrollUntilVisible(tester, find.text('Toyota Camry 2022'));

    expect(find.text('Toyota Camry 2022'), findsOneWidget);
    expect(find.text('Новые объявления (1)'), findsOneWidget);
  });

  testWidgets('home retries loading after an error', (tester) async {
    var calls = 0;
    Future<List<Car>> loader({required bool forceRefresh}) async {
      calls++;
      if (calls == 1) throw Exception('network error');
      return [_testCar];
    }

    await tester.pumpWidget(MaterialApp(home: HomeScreen(loadCars: loader)));
    await tester.pumpAndSettle();

    final errorText = find.text('Не удалось загрузить автомобили');
    await _scrollUntilVisible(tester, errorText);
    expect(errorText, findsOneWidget);

    final retryButton = find.text('Повторить');
    expect(retryButton, findsOneWidget);
    await tester.ensureVisible(retryButton);
    await tester.pumpAndSettle();
    await tester.tap(retryButton);
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('Toyota Camry 2022'));
    expect(calls, 2);
    expect(find.text('Toyota Camry 2022'), findsOneWidget);
  });

  testWidgets('home offers publishing when the market is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          loadCars: ({required bool forceRefresh}) async => const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollUntilVisible(tester, find.text('Объявлений пока нет'));
    expect(find.text('Объявлений пока нет'), findsOneWidget);
    expect(find.text('Продать автомобиль'), findsOneWidget);
  });
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(CustomScrollView);
  expect(scrollable, findsOneWidget);

  for (var attempt = 0; attempt < 10 && target.evaluate().isEmpty; attempt++) {
    await tester.drag(scrollable, const Offset(0, -220));
    await tester.pump();
  }
  await tester.pumpAndSettle();
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
