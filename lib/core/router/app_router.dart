import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../screens/home_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/edit_profile_screen.dart';
import '../../screens/user_settings_screen.dart';
import '../../screens/add_car_screen.dart';
import '../../screens/car_details_screen.dart';
import '../../screens/chat_list_screen.dart';
import '../../screens/chat_screen.dart';
import '../../screens/countries_screen.dart';
import '../../screens/dealers_screen.dart';
import '../../screens/wallet_screen.dart';
import '../../screens/delivery_screen.dart';
import '../../screens/my_publications_screen.dart';
import '../../screens/ai_vin_check_screen.dart';
import '../../screens/language_selection_screen.dart';
import '../../screens/search_filters_screen.dart';
import '../../screens/admin_screen.dart';
import '../../screens/admin_users_screen.dart';
import '../../screens/admin_cars_screen.dart';
import '../../screens/admin_dealers_screen.dart';
import '../../screens/admin_reports_screen.dart';
import '../../screens/admin_complaints_screen.dart';
import '../../screens/admin_markets_screen.dart';
import '../../models/car.dart';
import '../../models/car_search_filters.dart';
import '../../models/chat_thread.dart';
import '../../widgets/admin_guard.dart';
import '../security/app_permissions.dart';

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
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const UserSettingsScreen());
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
      case AppRoutes.chats:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case AppRoutes.chat:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          final thread = args['thread'];
          if (thread is ChatThread) {
            return MaterialPageRoute(
              builder: (_) => ChatScreen(thread: thread),
            );
          }
        }
        return _errorRoute('Отсутствует или повреждён аргумент thread');
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
        return _adminRoute(const AdminScreen());
      case AppRoutes.aiVinCheck:
        return MaterialPageRoute(builder: (_) => const AiVinCheckScreen());
      case AppRoutes.languageSelection:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      case AppRoutes.searchFilters:
        final filters = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => SearchFiltersScreen(
            initialFilters: filters is CarSearchFilters
                ? filters
                : const CarSearchFilters(),
          ),
        );
      case AppRoutes.adminUsers:
        return _adminRoute(
          const AdminUsersScreen(),
          permission: const AppPermissions().canManageUsers,
        );
      case AppRoutes.adminCars:
        return _adminRoute(
          const AdminCarsScreen(),
          permission: const AppPermissions().canModerateCars,
        );
      case AppRoutes.adminDealers:
        return _adminRoute(
          const AdminDealersScreen(),
          permission: const AppPermissions().canManageDealers,
        );
      case AppRoutes.adminReports:
        return _adminRoute(
          const AdminReportsScreen(),
          permission: const AppPermissions().canViewFullReports,
        );
      case AppRoutes.adminComplaints:
        return _adminRoute(
          const AdminComplaintsScreen(),
          permission: const AppPermissions().canReviewComplaints,
        );
      case AppRoutes.adminMarkets:
        return _adminRoute(
          const AdminMarketsScreen(),
          permission: const AppPermissions().canManageMarkets,
        );
      default:
        return _errorRoute('Нет маршрута: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }

  static Route<dynamic> _adminRoute(
    Widget child, {
    AdminPermission? permission,
  }) {
    return MaterialPageRoute(
      builder: (_) => AdminGuard(permission: permission, child: child),
    );
  }
}
