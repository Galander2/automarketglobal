import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

abstract class IAuthRepository {
  ValueListenable<AppUser?> get userState;
  AppUser? get currentUser;
  
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();
  Future<AppUser> signInWithPhone(String phone, String smsCode);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<AppUser> registerUser(String email, String password, String fullName, String phone);
}

class AuthRepository implements IAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<AppUser?> _userNotifier = ValueNotifier<AppUser?>(null);

  AuthRepository() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _userNotifier.value = null;
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _userNotifier.value = AppUser(
          id: uid,
          fullName: data['fullName'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          role: UserRole.values.firstWhere(
            (e) => e.name == data['role'],
            orElse: () => UserRole.user,
          ),
          isVerified: data['isVerified'] ?? false,
          rating: (data['rating'] ?? 0).toDouble(),
        );
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  ValueListenable<AppUser?> get userState => _userNotifier;

  @override
  AppUser? get currentUser => _userNotifier.value;

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        return _userNotifier.value!;
      }
      throw Exception('User not found');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  @override
  Future<AppUser> registerUser(String email, String password, String fullName, String phone) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = AppUser(
        id: credential.user!.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: UserRole.user,
        isVerified: false,
        rating: 0,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.name,
        'isVerified': false,
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _userNotifier.value = user;
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _userNotifier.value = null;
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  @override
  Future<AppUser> signInWithGoogle() {
    throw UnimplementedError('Google sign-in not implemented yet');
  }

  @override
  Future<AppUser> signInWithApple() {
    throw UnimplementedError('Apple sign-in not implemented yet');
  }

  @override
  Future<AppUser> signInWithPhone(String phone, String smsCode) {
    throw UnimplementedError('Phone sign-in not implemented yet');
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
      default:
        return 'Произошла ошибка. Попробуйте снова';
    }
  }
}