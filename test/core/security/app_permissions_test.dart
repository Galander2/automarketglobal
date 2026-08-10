import 'package:flutter_application_1_car_sales/core/security/app_permissions.dart';
import 'package:flutter_application_1_car_sales/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const permissions = AppPermissions();

  AppUser user(UserRole role, {bool blocked = false}) {
    return AppUser(
      uid: role.name,
      firstName: 'Test',
      lastName: 'User',
      phone: '',
      email: '${role.name}@example.com',
      role: role,
      isBlocked: blocked,
    );
  }

  test('regular admin receives moderation permissions only', () {
    final admin = user(UserRole.admin);

    expect(permissions.canViewAdminPanel(admin), isTrue);
    expect(permissions.canModerateCars(admin), isTrue);
    expect(permissions.canReviewComplaints(admin), isTrue);
    expect(permissions.canManageUsers(admin), isFalse);
    expect(permissions.canManageDealers(admin), isFalse);
    expect(permissions.canManageMarkets(admin), isFalse);
    expect(permissions.canViewFullReports(admin), isFalse);
  });

  test('super admin receives all management permissions', () {
    final superAdmin = user(UserRole.superAdmin);

    expect(permissions.canViewAdminPanel(superAdmin), isTrue);
    expect(permissions.canManageUsers(superAdmin), isTrue);
    expect(permissions.canManageDealers(superAdmin), isTrue);
    expect(permissions.canManageMarkets(superAdmin), isTrue);
    expect(permissions.canViewFullReports(superAdmin), isTrue);
  });

  test('blocked privileged account cannot use privileged capabilities', () {
    final blocked = user(UserRole.superAdmin, blocked: true);

    expect(permissions.canViewAdminPanel(blocked), isFalse);
    expect(permissions.canManageUsers(blocked), isFalse);
    expect(permissions.canPublishCar(blocked), isFalse);
    expect(permissions.canImportDealerCatalog(blocked), isFalse);
  });
}
