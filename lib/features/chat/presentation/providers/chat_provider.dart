import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/message_entity.dart';

const _uuid = Uuid();

class ChatNotifier extends StateNotifier<List<MessageEntity>> {
  final String tripId;

  ChatNotifier(this.tripId) : super(MockData.getMessages(tripId));

  void sendMessage(String content) {
    final message = MessageEntity(
      id: _uuid.v4(),
      tripId: tripId,
      userId: MockData.currentUser.id,
      userName: MockData.currentUser.displayName,
      content: content,
      createdAt: DateTime.now(),
    );
    state = [...state, message];
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, List<MessageEntity>, String>(
  (ref, tripId) => ChatNotifier(tripId),
);
