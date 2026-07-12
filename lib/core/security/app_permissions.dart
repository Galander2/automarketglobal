import '../../models/app_user.dart';

class AppPermissions {
  const AppPermissions();

  bool canViewAdminPanel(AppUser user) {
    return user.role == UserRole.admin || user.role == UserRole.superAdmin;
  }

  bool canViewFullReports(AppUser user) {
    return user.role == UserRole.superAdmin;
  }

  bool canModerateCars(AppUser user) {
    return user.role == UserRole.admin || user.role == UserRole.superAdmin;
  }

  bool canManageUsers(AppUser user) {
    return user.role == UserRole.superAdmin;
  }

  bool canManageDealers(AppUser user) {
    return user.role == UserRole.superAdmin;
  }

  bool canManageMarkets(AppUser user) {
    return user.role == UserRole.superAdmin;
  }

  bool canPublishCar(AppUser user) {
    return user.role == UserRole.seller ||
        user.role == UserRole.dealer ||
        user.role == UserRole.admin ||
        user.role == UserRole.superAdmin;
  }

  bool canImportDealerCatalog(AppUser user) {
    return user.role == UserRole.dealer || user.role == UserRole.superAdmin;
  }
}