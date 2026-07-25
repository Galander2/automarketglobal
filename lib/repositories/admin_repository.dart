import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_stats.dart';
import '../models/app_user.dart';
import '../models/car.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _actorId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Требуется авторизация администратора');
    return uid;
  }

  Future<AdminStats> loadStats() async {
    final results = await Future.wait([
      _firestore.collection('users').count().get(),
      _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.dealer.name)
          .count()
          .get(),
      _firestore.collection('cars').count().get(),
      _firestore
          .collection('cars')
          .where('status', isEqualTo: CarStatus.pending.name)
          .count()
          .get(),
      _firestore
          .collection('cars')
          .where('status', isEqualTo: CarStatus.approved.name)
          .count()
          .get(),
      _firestore
          .collection('cars')
          .where('status', isEqualTo: CarStatus.sold.name)
          .count()
          .get(),
    ]);

    return AdminStats(
      totalUsers: results[0].count ?? 0,
      totalDealers: results[1].count ?? 0,
      totalCars: results[2].count ?? 0,
      pendingCars: results[3].count ?? 0,
      approvedCars: results[4].count ?? 0,
      soldCars: results[5].count ?? 0,
      platformRevenue: 0,
      todayVisits: 0,
    );
  }

  Future<void> changeUserRole(AppUser target, UserRole newRole) {
    return _writeWithAudit(
      action: 'user.role_changed',
      targetType: 'user',
      targetId: target.uid,
      changes: {
        'role': newRole.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      metadata: {'from': target.role.name, 'to': newRole.name},
    );
  }

  Future<void> setUserBlocked(AppUser target, bool blocked) {
    return _writeWithAudit(
      action: blocked ? 'user.blocked' : 'user.unblocked',
      targetType: 'user',
      targetId: target.uid,
      changes: {
        'isBlocked': blocked,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> setUserBlockedById(String userId, bool blocked) {
    return _writeWithAudit(
      action: blocked ? 'user.blocked' : 'user.unblocked',
      targetType: 'user',
      targetId: userId,
      changes: {
        'isBlocked': blocked,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> setCarStatus(Car car, CarStatus status) {
    return _writeWithAudit(
      action: 'car.status_changed',
      targetType: 'car',
      targetId: car.id,
      changes: {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      metadata: {'from': car.status.name, 'to': status.name},
    );
  }

  Future<void> deleteCar(String carId) {
    return _deleteWithAudit(
      action: 'car.deleted',
      targetType: 'car',
      targetId: carId,
    );
  }

  Future<void> resolveComplaint(String complaintId) {
    return _writeWithAudit(
      action: 'complaint.resolved',
      targetType: 'complaint',
      targetId: complaintId,
      changes: {
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': _actorId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> _writeWithAudit({
    required String action,
    required String targetType,
    required String targetId,
    required Map<String, dynamic> changes,
    Map<String, dynamic> metadata = const {},
  }) async {
    final actorId = _actorId;
    final target = _firestore
        .collection(_collectionFor(targetType))
        .doc(targetId);
    final audit = _firestore.collection('admin_audit_logs').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(target);
      if (!snapshot.exists) {
        throw StateError('Целевой документ не найден');
      }
      transaction.update(target, changes);
      transaction.set(audit, {
        'actorId': actorId,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'metadata': metadata,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _deleteWithAudit({
    required String action,
    required String targetType,
    required String targetId,
  }) async {
    final actorId = _actorId;
    final target = _firestore
        .collection(_collectionFor(targetType))
        .doc(targetId);
    final audit = _firestore.collection('admin_audit_logs').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(target);
      if (!snapshot.exists) {
        throw StateError('Целевой документ не найден');
      }
      transaction.delete(target);
      transaction.set(audit, {
        'actorId': actorId,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'metadata': <String, dynamic>{},
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String _collectionFor(String targetType) {
    switch (targetType) {
      case 'user':
        return 'users';
      case 'car':
        return 'cars';
      case 'complaint':
        return 'complaints';
      default:
        throw ArgumentError.value(targetType, 'targetType');
    }
  }
}
