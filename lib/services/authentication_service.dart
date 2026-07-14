import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Сервис аутентификации для работы с Firebase Auth
class AuthenticationService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Текущий пользователь Firebase
  firebase_auth.User? get firebaseUser => _auth.currentUser;

  /// Поток изменений состояния аутентификации
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Получить текущего пользователя из Firestore
  Future<AppUser?> getCurrentUser() async {
    final user = firebaseUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Ошибка загрузки данных пользователя: $e');
    }
  }

  /// Войти по email и паролю
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Пользователь не найден');
      }

      // Обновить lastLogin
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      final appUser = await getCurrentUser();
      if (appUser == null) {
        throw Exception('Данные пользователя не найдены в Firestore');
      }

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final now = DateTime.now();

      final appUser = AppUser(
        uid: uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        email: email.trim(),
        role: UserRole.user,
        isVerified: false,
        createdAt: now,
        updatedAt: now,
        lastLogin: now,
      );

      await _firestore.collection('users').doc(uid).set(appUser.toMap());

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  /// Выйти из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Сбросить пароль по email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  /// Обновить данные пользователя в Firestore
  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        ...user.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Ошибка обновления данных пользователя: $e');
    }
  }

  /// Проверить, является ли текущий пользователь администратором
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'weak-password':
        return 'Пароль должен быть не менее 6 символов';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'operation-not-allowed':
        return 'Операция не разрешена';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение';
      default:
        return 'Произошла ошибка. Попробуйте снова';
    }
  }
}
