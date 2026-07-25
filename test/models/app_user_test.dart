import 'package:flutter_application_1_car_sales/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith preserves protected account fields', () {
    final original = AppUser(
      uid: 'user-1',
      firstName: 'Ахмад',
      lastName: 'Давлатов',
      phone: '+992900000000',
      email: 'user@example.com',
      role: UserRole.admin,
      avatar: 'https://example.com/avatar.jpg',
      isVerified: true,
      isBlocked: false,
      rating: 4.8,
    );

    final updated = original.copyWith(
      firstName: 'Ahmad',
      city: 'Dushanbe',
    );

    expect(updated.uid, original.uid);
    expect(updated.email, original.email);
    expect(updated.role, UserRole.admin);
    expect(updated.isVerified, isTrue);
    expect(updated.isBlocked, isFalse);
    expect(updated.rating, 4.8);
    expect(updated.avatar, original.avatar);
  });

  test('copyWith can explicitly clear an avatar', () {
    final original = AppUser(
      uid: 'user-1',
      firstName: 'Ахмад',
      lastName: 'Давлатов',
      phone: '+992900000000',
      email: 'user@example.com',
      avatar: 'https://example.com/avatar.jpg',
    );

    expect(original.copyWith(clearAvatar: true).avatar, isNull);
  });
}
