import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/models/chat_thread.dart';

void main() {
  const thread = ChatThread(
    id: 'chat-1',
    carId: 'car-1',
    carTitle: 'Toyota Camry',
    carImageUrl: '',
    buyerId: 'buyer-1',
    sellerId: 'seller-1',
    participantIds: ['buyer-1', 'seller-1'],
    unreadCounts: {'buyer-1': 3, 'seller-1': 1},
    blockedBy: ['buyer-1'],
  );

  test('returns the other participant', () {
    expect(thread.otherParticipant('buyer-1'), 'seller-1');
    expect(thread.otherParticipant('seller-1'), 'buyer-1');
  });

  test('returns unread count safely', () {
    expect(thread.unreadFor('buyer-1'), 3);
    expect(thread.unreadFor('unknown'), 0);
  });

  test('detects who blocked the conversation', () {
    expect(thread.isBlockedBy('buyer-1'), isTrue);
    expect(thread.isBlockedBy('seller-1'), isFalse);
  });
}
