import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/car.dart';
import '../models/chat_thread.dart';

class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => message;
}

class ChatRepository {
  static const int maxMessageLength = 2000;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  String _requireUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const ChatException('Войдите в аккаунт, чтобы открыть сообщения');
    }
    return uid;
  }

  String _chatId(String carId, String buyerId) =>
      '${carId}_$buyerId'.replaceAll('/', '_');

  Stream<List<ChatThread>> watchChats(String userId) {
    if (userId.isEmpty) return const Stream.empty();
    return _chats
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(ChatThread.fromDocument).toList(growable: false),
        );
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    _requireUserId();
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ChatMessage.fromDocument)
              .where((message) => message.senderId.isNotEmpty)
              .toList(growable: false),
        )
        .handleError((Object error) {
          throw ChatException('Не удалось загрузить сообщения: $error');
        });
  }

  Future<ChatThread> openConversation({
    required Car car,
    required AppUser buyer,
  }) async {
    final uid = _requireUserId();
    if (uid != buyer.uid) {
      throw const ChatException('Сессия пользователя устарела. Войдите снова');
    }
    if (buyer.uid == car.sellerId) {
      throw const ChatException('Нельзя написать самому себе');
    }
    if (!car.isApproved) {
      throw const ChatException('Объявление недоступно для переписки');
    }

    final reference = _chats.doc(_chatId(car.id, buyer.uid));
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        final participants = List<String>.from(
          snapshot.data()?['participantIds'] as List? ?? const [],
        );
        if (!participants.contains(uid)) {
          throw const ChatException('Нет доступа к этому диалогу');
        }
        return;
      }

      transaction.set(reference, {
        'carId': car.id,
        'carTitle': car.title,
        'carImageUrl': car.imageUrl,
        'buyerId': buyer.uid,
        'sellerId': car.sellerId,
        'participantIds': [buyer.uid, car.sellerId],
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts': {buyer.uid: 0, car.sellerId: 0},
        'blockedBy': <String>[],
      });
    });

    final snapshot = await reference.get();
    if (!snapshot.exists) {
      throw const ChatException('Не удалось создать диалог');
    }
    return ChatThread.fromDocument(snapshot);
  }

  Future<void> sendMessage(ChatThread thread, String rawText) async {
    final uid = _requireUserId();
    final text = rawText.trim();
    if (!thread.participantIds.contains(uid)) {
      throw const ChatException('Нет доступа к этому диалогу');
    }
    if (thread.blockedBy.isNotEmpty) {
      throw const ChatException('Отправка сообщений в этом диалоге заблокирована');
    }
    if (text.isEmpty) {
      throw const ChatException('Введите сообщение');
    }
    if (text.length > maxMessageLength) {
      throw const ChatException('Сообщение не должно превышать 2000 символов');
    }

    final chatReference = _chats.doc(thread.id);
    final messageReference = chatReference.collection('messages').doc();
    final otherUserId = thread.otherParticipant(uid);

    await _firestore.runTransaction((transaction) async {
      final chatSnapshot = await transaction.get(chatReference);
      if (!chatSnapshot.exists) {
        throw const ChatException('Диалог больше не существует');
      }
      final data = chatSnapshot.data()!;
      final participants = List<String>.from(
        data['participantIds'] as List? ?? const [],
      );
      final blockedBy = List<String>.from(
        data['blockedBy'] as List? ?? const [],
      );
      if (!participants.contains(uid) || blockedBy.isNotEmpty) {
        throw const ChatException('Отправка сообщения запрещена');
      }

      transaction.set(messageReference, {
        'senderId': uid,
        'text': text,
        'type': 'text',
        'sentAt': FieldValue.serverTimestamp(),
        'readBy': [uid],
      });
      transaction.update(chatReference, {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts.$otherUserId': FieldValue.increment(1),
        'unreadCounts.$uid': 0,
      });
    });
  }

  Future<void> markRead(ChatThread thread) async {
    final uid = _requireUserId();
    if (!thread.participantIds.contains(uid)) return;
    await _chats.doc(thread.id).update({
      'unreadCounts.$uid': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setBlocked(ChatThread thread, {required bool blocked}) async {
    final uid = _requireUserId();
    if (!thread.participantIds.contains(uid)) {
      throw const ChatException('Нет доступа к этому диалогу');
    }
    await _chats.doc(thread.id).update({
      'blockedBy': blocked
          ? FieldValue.arrayUnion([uid])
          : FieldValue.arrayRemove([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
