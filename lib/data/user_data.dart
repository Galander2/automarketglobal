import '../models/app_user.dart';

const AppUser currentUser = AppUser(
  uid: 'owner_001',
  firstName: 'Ahmad',
  lastName: 'Davlatov',
  phone: '+992000000000',
  email: 'ahmad@example.com',
  role: UserRole.superAdmin,
  isVerified: true,
);
