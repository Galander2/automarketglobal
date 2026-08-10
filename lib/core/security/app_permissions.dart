import '../../models/app_user.dart';

class AppPermissions {
  const AppPermissions();

  bool canViewAdminPanel(AppUser user) {
    return !user.isBlocked &&
        (user.role == UserRole.admin || user.role == UserRole.superAdmin);
  }

  bool canViewFullReports(AppUser user) {
    return canViewAdminPanel(user) && user.role == UserRole.superAdmin;
  }

  bool canModerateCars(AppUser user) {
    return canViewAdminPanel(user);
  }

  bool canReviewComplaints(AppUser user) {
    return canViewAdminPanel(user);
  }

  bool canManageUsers(AppUser user) {
    return canViewAdminPanel(user) && user.role == UserRole.superAdmin;
  }

  bool canManageDealers(AppUser user) {
    return canManageUsers(user);
  }

  bool canManageMarkets(AppUser user) {
    return canManageUsers(user);
  }

  bool canPublishCar(AppUser user) {
    return !user.isBlocked &&
        (user.role == UserRole.seller ||
            user.role == UserRole.dealer ||
            user.role == UserRole.admin ||
            user.role == UserRole.superAdmin);
  }

  bool canImportDealerCatalog(AppUser user) {
    return !user.isBlocked &&
        (user.role == UserRole.dealer || user.role == UserRole.superAdmin);
  }
}
