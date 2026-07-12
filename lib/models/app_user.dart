enum UserRole {
  user,
  seller,
  dealer,
  admin,
  superAdmin,
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final bool isVerified;
  final double rating;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.isVerified = false,
    this.rating = 0,
  });

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  bool get isSuperAdmin => role == UserRole.superAdmin;

  bool get canSell {
    return role == UserRole.seller ||
        role == UserRole.dealer ||
        role == UserRole.admin ||
        role == UserRole.superAdmin;
  }

  String get roleTitle {
    switch (role) {
      case UserRole.user:
        return 'Покупатель';
      case UserRole.seller:
        return 'Продавец';
      case UserRole.dealer:
        return 'Крупный дилер';
      case UserRole.admin:
        return 'Администратор';
      case UserRole.superAdmin:
        return 'Владелец платформы';
    }
  }
}