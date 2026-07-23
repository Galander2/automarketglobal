import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../screens/home_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/edit_profile_screen.dart';
import '../../screens/add_car_screen.dart';
import '../../screens/car_details_screen.dart';
import '../../screens/countries_screen.dart';
import '../../screens/dealers_screen.dart';
import '../../screens/wallet_screen.dart';
import '../../screens/delivery_screen.dart';
import '../../screens/my_publications_screen.dart';
import '../../screens/ai_vin_check_screen.dart';
import '../../screens/language_selection_screen.dart';
import '../../screens/search_filters_screen.dart';
import '../../screens/admin_dashboard_screen.dart';
import '../../screens/admin_users_screen.dart';
import '../../screens/admin_cars_screen.dart';
import '../../screens/admin_dealers_screen.dart';
import '../../screens/admin_reports_screen.dart';
import '../../screens/admin_complaints_screen.dart';
import '../../screens/admin_markets_screen.dart';
import '../../screens/admin_settings_screen.dart';
import '../../models/car.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case AppRoutes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.profileEdit:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case AppRoutes.addCar:
        return MaterialPageRoute(builder: (_) => const AddCarScreen());
      case AppRoutes.carDetails:
        final args = settings.arguments;
        if (args == null) {
          return _errorRoute('Отсутствует или повреждён аргумент car');
        }
        if (args is Map<String, dynamic>) {
          final car = args['car'];
          if (car is! Car) {
            return _errorRoute('Отсутствует или повреждён аргумент car');
          }
          return MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car));
        }
        return _errorRoute('Неверный тип аргументов для carDetails');
      case AppRoutes.countries:
        return MaterialPageRoute(builder: (_) => const CountriesScreen());
      case AppRoutes.dealers:
        return MaterialPageRoute(builder: (_) => const DealersScreen());
      case AppRoutes.wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case AppRoutes.delivery:
        return MaterialPageRoute(builder: (_) => const DeliveryScreen());
      case AppRoutes.myPublications:
        return MaterialPageRoute(builder: (_) => const MyPublicationsScreen());
      case AppRoutes.admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case AppRoutes.aiVinCheck:
        return MaterialPageRoute(builder: (_) => const AiVinCheckScreen());
      case AppRoutes.languageSelection:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      case AppRoutes.searchFilters:
        return MaterialPageRoute(builder: (_) => const SearchFiltersScreen());
      case AppRoutes.adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
      case AppRoutes.adminCars:
        return MaterialPageRoute(builder: (_) => const AdminCarsScreen());
      case AppRoutes.adminDealers:
        return MaterialPageRoute(builder: (_) => const AdminDealersScreen());
      case AppRoutes.adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      case AppRoutes.adminComplaints:
        return MaterialPageRoute(builder: (_) => const AdminComplaintsScreen());
      case AppRoutes.adminMarkets:
        return MaterialPageRoute(builder: (_) => const AdminMarketsScreen());
      case AppRoutes.adminSettings:
        return MaterialPageRoute(builder: (_) => const AdminSettingsScreen());
      default:
        return _errorRoute('Нет маршрута: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }
}
