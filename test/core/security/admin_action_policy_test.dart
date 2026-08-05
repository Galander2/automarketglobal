import 'package:flutter_application_1_car_sales/core/security/admin_action_policy.dart';
import 'package:flutter_application_1_car_sales/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = AdminActionPolicy();

  AppUser user(String id, UserRole role, {bool blocked = false}) {
    return AppUser(
      uid: id,
      firstName: 'Test',
      lastName: 'User',
      phone: '',
      email: '$id@example.com',
      role: role,
      isBlocked: blocked,
    );
  }

  test('only active admins can access admin panel', () {
    expect(policy.canAccessAdmin(user('u', UserRole.user)), isFalse);
    expect(policy.canAccessAdmin(user('a', UserRole.admin)), isTrue);
    expect(
      policy.canAccessAdmin(user('a', UserRole.admin, blocked: true)),
      isFalse,
    );
  });

  test('regular admin cannot change roles', () {
    expect(
      policy.canChangeRole(
        actor: user('admin', UserRole.admin),
        target: user('target', UserRole.user),
        newRole: UserRole.dealer,
      ),
      isFalse,
    );
  });

  test('super admin cannot promote another super admin or change self', () {
    final actor = user('root', UserRole.superAdmin);
    expect(
      policy.canChangeRole(
        actor: actor,
        target: user('target', UserRole.user),
        newRole: UserRole.superAdmin,
      ),
      isFalse,
    );
    expect(
      policy.canChangeRole(
        actor: actor,
        target: actor,
        newRole: UserRole.admin,
      ),
      isFalse,
    );
  });

  test('admin can block regular user but not another admin', () {
    final actor = user('admin', UserRole.admin);
    expect(
      policy.canChangeBlockStatus(
        actor: actor,
        target: user('target', UserRole.user),
      ),
      isTrue,
    );
    expect(
      policy.canChangeBlockStatus(
        actor: actor,
        target: user('other-admin', UserRole.admin),
      ),
      isFalse,
    );
  });
}
