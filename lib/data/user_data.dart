import '../models/app_user.dart';

const AppUser currentUser = AppUser(
  id: 'owner_001',
  fullName: 'Ahmad Davlatov',
  email: 'ahmad@example.com',
  phone: '+992000000000',
  role: UserRole.superAdmin,
  isVerified: true,
  rating: 5.0,
);