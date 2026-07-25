import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => message;
}

class AuthenticationService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  Future<void>? _googleInitialization;

  AuthenticationService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  firebase_auth.User? get firebaseUser => _auth.currentUser;
  Stream<firebase_auth.User?> get authStateChanges => _auth.idTokenChanges();
  bool get isEmailVerified => firebaseUser?.emailVerified ?? false;

  Future<AppUser?> getCurrentUser() async {
    final authUser = firebaseUser;
    if (authUser == null) return null;

    try {
      final reference = _firestore.collection('users').doc(authUser.uid);
      final snapshot = await reference.get();

      if (!snapshot.exists) {
        final fallback = AppUser(
          uid: authUser.uid,
          firstName: authUser.displayName?.trim() ?? '',
          lastName: '',
          phone: authUser.phoneNumber ?? '',
          email: authUser.email ?? '',
          emailVerified: authUser.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await reference.set(fallback.toMap());
        return fallback;
      }

      final data = snapshot.data()!;
      return AppUser.fromMap(data, authUser.uid).copyWith(
        email: authUser.email ?? data['email'] as String? ?? '',
        emailVerified: authUser.emailVerified,
      );
    } on FirebaseException catch (error) {
      throw AuthenticationException(_firestoreMessage(error));
    }
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final authUser = credential.user;
      if (authUser == null) {
        throw const AuthenticationException('Не удалось выполнить вход');
      }

      final appUser = await getCurrentUser();
      if (appUser == null) {
        throw const AuthenticationException('Профиль пользователя не найден');
      }
      if (appUser.isBlocked) {
        await _auth.signOut();
        throw const AuthenticationException('Аккаунт заблокирован');
      }

      await _firestore.collection('users').doc(authUser.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
        'emailVerified': authUser.emailVerified,
      }, SetOptions(merge: true));
      return appUser.copyWith(lastLogin: DateTime.now());
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthenticationException(_authMessage(error.code));
    } on AuthenticationException {
      rethrow;
    }
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      firebase_auth.UserCredential credential;
      if (kIsWeb) {
        final provider = firebase_auth.GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        credential = await _auth.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await (_googleInitialization ??= googleSignIn.initialize());
        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final googleCredential = firebase_auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(googleCredential);
      }

      final authUser = credential.user;
      if (authUser == null) {
        throw const AuthenticationException('Не удалось войти через Google');
      }
      final appUser = await getCurrentUser();
      if (appUser == null) {
        throw const AuthenticationException('Не удалось создать профиль');
      }
      if (appUser.isBlocked) {
        await _auth.signOut();
        throw const AuthenticationException('Аккаунт заблокирован');
      }
      await _firestore.collection('users').doc(authUser.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
        'emailVerified': authUser.emailVerified,
        'avatar': appUser.avatar ?? authUser.photoURL,
      }, SetOptions(merge: true));
      return appUser.copyWith(
        emailVerified: authUser.emailVerified,
        avatar: appUser.avatar ?? authUser.photoURL,
        lastLogin: DateTime.now(),
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthenticationException('Вход через Google отменён');
      }
      throw const AuthenticationException('Не удалось войти через Google');
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthenticationException(_authMessage(error.code));
    } on AuthenticationException {
      rethrow;
    }
  }

  Future<AppUser> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    firebase_auth.User? createdUser;
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const AuthenticationException('Не удалось создать аккаунт');
      }

      final displayName = '${firstName.trim()} ${lastName.trim()}'.trim();
      await createdUser.updateDisplayName(displayName);

      final appUser = AppUser(
        uid: createdUser.uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        email: normalizedEmail,
        role: UserRole.user,
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore.collection('users').doc(createdUser.uid).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      await createdUser.sendEmailVerification();
      return appUser;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthenticationException(_authMessage(error.code));
    } on AuthenticationException {
      rethrow;
    } on FirebaseException catch (error) {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          await _auth.signOut();
        }
      }
      throw AuthenticationException(_firestoreMessage(error));
    }
  }

  Future<void> reloadUser() async {
    final user = firebaseUser;
    if (user == null) {
      throw const AuthenticationException('Сначала войдите');
    }
    try {
      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        throw const AuthenticationException('Сессия завершена. Войдите снова');
      }
      await refreshedUser.getIdToken(true);
      await _firestore.collection('users').doc(refreshedUser.uid).update({
        'emailVerified': refreshedUser.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthenticationException(_authMessage(error.code));
    } on FirebaseException catch (error) {
      throw AuthenticationException(_firestoreMessage(error));
    }
  }

  Future<void> sendEmailVerification() async {
    final user = firebaseUser;
    if (user == null) throw const AuthenticationException('Сначала войдите');
    if (!user.emailVerified) await user.sendEmailVerification();
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthenticationException(_authMessage(error.code));
    }
  }

  Future<AppUser> updateUser(AppUser user) async {
    final current = firebaseUser;
    if (current == null || current.uid != user.uid) {
      throw const AuthenticationException('Нет доступа к этому профилю');
    }
    final firstName = user.firstName.trim();
    final lastName = user.lastName.trim();
    final phone = user.phone.trim().replaceAll(RegExp(r'[\s()\-]'), '');
    final country = user.country?.trim() ?? '';
    final city = user.city?.trim() ?? '';
    final avatar = user.avatar?.trim();
    final storedAvatar = avatar == null || avatar.isEmpty ? null : avatar;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'avatar': storedAvatar,
        'country': country,
        'city': city,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return user.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        country: country,
        city: city,
        updatedAt: DateTime.now(),
        clearAvatar: storedAvatar == null,
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthenticationException(_authMessage(error.code));
    } on FirebaseException catch (error) {
      throw AuthenticationException(_firestoreMessage(error));
    }
  }

  Future<bool> isAdmin() async => (await getCurrentUser())?.isAdmin ?? false;

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'weak-password':
        return 'Пароль слишком простой';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Нет соединения с интернетом';
      case 'operation-not-allowed':
        return 'Этот способ входа не включён в Firebase';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Вход через Google отменён';
      case 'popup-blocked':
        return 'Браузер заблокировал окно Google. Разрешите всплывающие окна';
      case 'account-exists-with-different-credential':
        return 'Аккаунт с таким email уже использует другой способ входа';
      default:
        return 'Ошибка авторизации. Попробуйте ещё раз';
    }
  }

  String _firestoreMessage(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Недостаточно прав для выполнения операции';
    }
    if (error.code == 'unavailable') return 'Сервис временно недоступен';
    return 'Не удалось сохранить профиль. Попробуйте ещё раз';
  }
}
