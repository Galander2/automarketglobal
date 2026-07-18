import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../../lib/core/router/app_router.dart';
import '../../../lib/core/router/app_routes.dart';
import '../../../lib/services/language_service.dart';
import '../../../lib/l10n/app_localizations.dart';

void main() {
  group('AppRouter Tests', () {
    testWidgets('generates home route', (tester) async {
      await tester.pumpWidget(
        _createTestApp(AppRoutes.home),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('generates search route', (tester) async {
      await tester.pumpWidget(
        _createTestApp(AppRoutes.search),
      );
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('generates favorites route', (tester) async {
      await tester.pumpWidget(
        _createTestApp(AppRoutes.favorites),
      );
      expect(find.byType(FavoritesScreen), findsOneWidget);
    });

    testWidgets('generates profile route', (tester) async {
      await tester.pumpWidget(
        _createTestApp(AppRoutes.profile),
      );
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('generates error route for unknown path', (tester) async {
      await tester.pumpWidget(
        _createTestApp('/unknown-route'),
      );
      expect(find.text('Нет маршрута: /unknown-route'), findsOneWidget);
    });

    testWidgets('handles carDetails with missing arguments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRoutes.carDetails,
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
        ),
      );
      expect(find.textContaining('Отсутствует аргумент car'), findsOneWidget);
    });
  });
}

MaterialApp _createTestApp(String routeName) {
  return MaterialApp(
    onGenerateRoute: AppRouter.generateRoute,
    initialRoute: routeName,
    localizationsDelegates: const [
      AppLocalizations.delegate,
    ],
    home: Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          body: Center(
            child: Text(languageService.locale.languageCode),
          ),
        );
      },
    ),
  );
}
