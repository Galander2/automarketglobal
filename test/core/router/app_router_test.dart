import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1_car_sales/core/router/app_router.dart';
import 'package:flutter_application_1_car_sales/core/router/app_routes.dart';
import 'package:flutter_application_1_car_sales/l10n/app_localizations.dart';
import 'package:flutter_application_1_car_sales/screens/favorites_screen.dart';
import 'package:flutter_application_1_car_sales/screens/home_screen.dart';
import 'package:flutter_application_1_car_sales/screens/profile_screen.dart';
import 'package:flutter_application_1_car_sales/screens/search_screen.dart';
import 'package:flutter_application_1_car_sales/services/language_service.dart';

void main() {
  group('AppRouter Tests', () {
    testWidgets('generates home route', (tester) async {
      await tester.pumpWidget(_createTestApp(AppRoutes.home));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('generates search route', (tester) async {
      await tester.pumpWidget(_createTestApp(AppRoutes.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('generates favorites route', (tester) async {
      await tester.pumpWidget(_createTestApp(AppRoutes.favorites));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesScreen), findsOneWidget);
    });

    testWidgets('generates profile route', (tester) async {
      await tester.pumpWidget(_createTestApp(AppRoutes.profile));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('generates error route for unknown path', (tester) async {
      await tester.pumpWidget(_createTestApp('/unknown-route'));
      await tester.pumpAndSettle();
      expect(find.text('Нет маршрута: /unknown-route'), findsOneWidget);
    });

    testWidgets('handles carDetails with missing arguments', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRoutes.carDetails,
          localizationsDelegates: [AppLocalizations.delegate],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Отсутствует или повреждён аргумент car'),
        findsOneWidget,
      );
    });
  });
}

Widget _createTestApp(String routeName) {
  return ChangeNotifierProvider(
    create: (_) => LanguageService(),
    child: MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: routeName,
      localizationsDelegates: const [AppLocalizations.delegate],
      builder: (context, child) => Consumer<LanguageService>(
        builder: (context, languageService, _) => Localizations.override(
          context: context,
          locale: languageService.locale,
          child: child,
        ),
      ),
    ),
  );
}
