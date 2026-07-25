import '../../models/app_user.dart';

class AdminActionPolicy {
  const AdminActionPolicy();

  bool canAccessAdmin(AppUser? actor) {
    return actor != null && actor.isAdmin && !actor.isBlocked;
  }

  bool canManageUsers(AppUser? actor) {
    return canAccessAdmin(actor) && actor!.role == UserRole.superAdmin;
  }

  bool canModerate(AppUser? actor) => canAccessAdmin(actor);

  bool canChangeRole({
    required AppUser? actor,
    required AppUser target,
    required UserRole newRole,
  }) {
    if (!canManageUsers(actor) || actor!.uid == target.uid) return false;
    if (target.role == UserRole.superAdmin) return false;
    return newRole != UserRole.superAdmin;
  }

  bool canChangeBlockStatus({
    required AppUser? actor,
    required AppUser target,
  }) {
    if (!canAccessAdmin(actor) || actor!.uid == target.uid) return false;
    if (target.role == UserRole.superAdmin) return false;
    if (target.role == UserRole.admin) {
      return actor.role == UserRole.superAdmin;
    }
    return true;
  }
}
