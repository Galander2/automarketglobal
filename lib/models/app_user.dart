import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, seller, dealer, admin, superAdmin }

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final UserRole role;
  final String? avatar;
  final String? country;
  final String? city;
  final bool isVerified;
  final bool isBlocked;
  final double rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.role = UserRole.user,
    this.avatar,
    this.country,
    this.city,
    this.isVerified = false,
    this.isBlocked = false,
    this.rating = 0,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get id => uid;

  String get roleTitle {
    switch (role) {
      case UserRole.user:
        return 'Пользователь';
      case UserRole.seller:
        return 'Продавец';
      case UserRole.dealer:
        return 'Дилер';
      case UserRole.admin:
        return 'Администратор';
      case UserRole.superAdmin:
        return 'Супер-админ';
    }
  }

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  bool get isDealer => role == UserRole.dealer;

  bool get isSeller => role == UserRole.seller || isDealer;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'role': role.name,
      'avatar': avatar,
      'country': country,
      'city': city,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'rating': rating,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLogin': lastLogin,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      avatar: map['avatar'],
      country: map['country'],
      city: map['city'],
      isVerified: map['isVerified'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      createdAt: _convertToDateTime(map['createdAt']),
      updatedAt: _convertToDateTime(map['updatedAt']),
      lastLogin: _convertToDateTime(map['lastLogin']),
    );
  }

  /// Безопасное преобразование Timestamp или DateTime в DateTime
  static DateTime? _convertToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  AppUser copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    UserRole? role,
    String? avatar,
    String? country,
    String? city,
    bool? isVerified,
    bool? isBlocked,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      country: country ?? this.country,
      city: city ?? this.city,
      isVerified: isVerified ?? this.isVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
