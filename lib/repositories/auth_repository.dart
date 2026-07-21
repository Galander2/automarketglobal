import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/authentication_service.dart';

/// Provider для управления состоянием аутентификации и данными пользователя
class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();

  AppUser? _currentUser;
  bool _isLoading = true;
  bool _isCheckingAuth = true;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isDealer => _currentUser?.isDealer ?? false;

  AuthProvider() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authService.authStateChanges.listen((_) async {
      await _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      _isCheckingAuth = true;
      notifyListeners();

      _currentUser = await _authService.getCurrentUser();

      _isCheckingAuth = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isCheckingAuth = false;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Войти по email и паролю
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.signInWithEmail(email, password);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Зарегистрировать нового пользователя
  Future<AppUser> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      _currentUser = user;

      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Выйти из аккаунта
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Сбросить пароль
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  /// Обновить данные пользователя
  Future<void> updateUser(AppUser user) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateUser(user);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Проверить, является ли пользователь администратором
  Future<bool> checkIsAdmin() async {
    return await _authService.isAdmin();
  }
}
