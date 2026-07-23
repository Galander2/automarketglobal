import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThread {
  final String id;
  final String carId;
  final String carTitle;
  final String carImageUrl;
  final String buyerId;
  final String sellerId;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;
  final List<String> blockedBy;

  const ChatThread({
    required this.id,
    required this.carId,
    required this.carTitle,
    required this.carImageUrl,
    required this.buyerId,
    required this.sellerId,
    required this.participantIds,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCounts = const {},
    this.blockedBy = const [],
  });

  factory ChatThread.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final unreadData =
        data['unreadCounts'] as Map<String, dynamic>? ?? const {};

    return ChatThread(
      id: document.id,
      carId: data['carId'] as String? ?? '',
      carTitle: data['carTitle'] as String? ?? 'Объявление',
      carImageUrl: data['carImageUrl'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      participantIds: List<String>.from(
        data['participantIds'] as List? ?? const [],
      ),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCounts: unreadData.map(
        (key, value) => MapEntry(key, value is int ? value : 0),
      ),
      blockedBy: List<String>.from(data['blockedBy'] as List? ?? const []),
    );
  }

  String otherParticipant(String currentUserId) =>
      currentUserId == buyerId ? sellerId : buyerId;

  int unreadFor(String currentUserId) => unreadCounts[currentUserId] ?? 0;

  bool isBlockedBy(String userId) => blockedBy.contains(userId);
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime? sentAt;
  final List<String> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.sentAt,
    this.readBy = const [],
  });

  factory ChatMessage.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return ChatMessage(
      id: document.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] as List? ?? const []),
    );
  }
}
