import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/core/router/app_router.dart';
import 'package:flutter_application_1_car_sales/core/router/app_routes.dart';
import 'package:flutter_application_1_car_sales/l10n/app_localizations.dart';
import 'package:flutter_application_1_car_sales/screens/favorites_screen.dart';
import 'package:flutter_application_1_car_sales/screens/home_screen.dart';
import 'package:flutter_application_1_car_sales/screens/profile_screen.dart';
import 'package:flutter_application_1_car_sales/screens/search_screen.dart';

void main() {
  group('AppRouter Tests', () {
    testWidgets('generates home route', (tester) async {
      await _expectRouteBuilds<HomeScreen>(tester, AppRoutes.home);
    });

    testWidgets('generates search route', (tester) async {
      await _expectRouteBuilds<SearchScreen>(tester, AppRoutes.search);
    });

    testWidgets('generates favorites route', (tester) async {
      await _expectRouteBuilds<FavoritesScreen>(tester, AppRoutes.favorites);
    });

    testWidgets('generates profile route', (tester) async {
      await _expectRouteBuilds<ProfileScreen>(tester, AppRoutes.profile);
    });

    testWidgets('generates error route for unknown path', (tester) async {
      await tester.pumpWidget(_createRoutedApp('/unknown-route'));
      await tester.pumpAndSettle();
      expect(find.text('Нет маршрута: /unknown-route'), findsOneWidget);
    });

    testWidgets('handles carDetails with missing arguments', (tester) async {
      await tester.pumpWidget(_createRoutedApp(AppRoutes.carDetails));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Отсутствует или повреждён аргумент car'),
        findsOneWidget,
      );
    });
  });
}

Future<void> _expectRouteBuilds<T extends Widget>(
  WidgetTester tester,
  String routeName,
) async {
  final route = AppRouter.generateRoute(RouteSettings(name: routeName));
  expect(route, isA<MaterialPageRoute<dynamic>>());

  Widget? routedWidget;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          routedWidget = (route as MaterialPageRoute<dynamic>).builder(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  expect(routedWidget, isA<T>());
}

Widget _createRoutedApp(String routeName) {
  return MaterialApp(
    onGenerateRoute: AppRouter.generateRoute,
    initialRoute: routeName,
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}
