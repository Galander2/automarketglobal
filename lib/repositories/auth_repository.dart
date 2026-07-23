import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/authentication_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthenticationService _authService;
  StreamSubscription<firebase_auth.User?>? _authSubscription;

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;

  AuthProvider({AuthenticationService? authService})
    : _authService = authService ?? AuthenticationService() {
    _authSubscription = _authService.authStateChanges.listen(
      (_) => _synchronizeUser(),
      onError: (_) {
        _currentUser = null;
        _isCheckingAuth = false;
        _errorMessage = 'Не удалось проверить авторизацию';
        notifyListeners();
      },
    );
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isAuthenticated => _authService.firebaseUser != null;
  bool get isEmailVerified => _authService.isEmailVerified;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isDealer => _currentUser?.isDealer ?? false;
  String? get errorMessage => _errorMessage;

  Future<void> _synchronizeUser() async {
    try {
      _isCheckingAuth = true;
      notifyListeners();
      _currentUser = await _authService.getCurrentUser();
      _errorMessage = null;
    } catch (error) {
      _currentUser = null;
      _errorMessage = error.toString();
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  Future<AppUser> signInWithEmail(String email, String password) =>
      _run(() async {
        final user = await _authService.signInWithEmail(email, password);
        _currentUser = user;
        return user;
      });

  Future<AppUser> signInWithGoogle() => _run(() async {
    final user = await _authService.signInWithGoogle();
    _currentUser = user;
    return user;
  });

  Future<AppUser> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) => _run(() async {
    final user = await _authService.registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    _currentUser = user;
    return user;
  });

  Future<void> refreshEmailVerification() async {
    await _run(() async {
      await _authService.reloadUser();
      _currentUser = await _authService.getCurrentUser();
    });
  }

  Future<void> resendEmailVerification() =>
      _run(_authService.sendEmailVerification);

  Future<void> signOut() => _run(() async {
    await _authService.signOut();
    _currentUser = null;
  });

  Future<void> resetPassword(String email) =>
      _run(() => _authService.resetPassword(email));

  Future<void> updateUser(AppUser user) => _run(() async {
    await _authService.updateUser(user);
    _currentUser = user;
  });

  Future<bool> checkIsAdmin() => _authService.isAdmin();

  Future<T> _run<T>(Future<T> Function() operation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await operation();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
