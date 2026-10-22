import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/message_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _uuid = Uuid();

class ChatNotifier extends StateNotifier<List<MessageEntity>> {
  final String tripId;
  final Ref _ref;
  StreamSubscription? _subscription;

  ChatNotifier(this.tripId, this._ref) : super([]) {
    _init();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  void _init() {
    state = MockData.getMessages(tripId);

    final client = _client;
    final isDemo = _ref.read(authProvider).isDemo;

    if (!isDemo && client != null && client.auth.currentUser != null) {
      try {
        _subscription = client
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('trip_id', tripId)
            .order('timestamp', ascending: true)
            .listen((data) {
              final messages = data.map((map) {
                final senderId = map['sender_id'] as String? ?? '';
                return MessageEntity(
                  id: map['id'] as String,
                  tripId: tripId,
                  userId: senderId,
                  userName: MockData.userNames[senderId] ?? 'User',
                  content: map['text'] ?? '',
                  messageType: senderId == 'system' ? 'system' : 'text',
                  createdAt: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
                );
              }).toList();

              state = messages;
            }, onError: (err) {
              debugPrint('[ChatNotifier] Error in messages stream: $err');
            });
      } catch (e) {
        debugPrint('[ChatNotifier] Stream initialization error: $e');
      }
    }
  }

  Future<void> sendMessage(String content) async {
    final client = _client;
    final authUser = _ref.read(currentUserProvider);
    final currentUserId = client?.auth.currentUser?.id ?? authUser?.id ?? MockData.currentUser.id;
    final currentUserName = authUser?.displayName ?? MockData.currentUser.displayName;

    final newMessage = MessageEntity(
      id: _uuid.v4(),
      tripId: tripId,
      userId: currentUserId,
      userName: currentUserName,
      content: content,
      messageType: 'text',
      createdAt: DateTime.now(),
    );

    // Optimistically append locally
    state = [...state, newMessage];

    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('messages').insert({
          'trip_id': tripId,
          'sender_id': currentUserId,
          'text': content,
        });
      } catch (e) {
        debugPrint('[ChatNotifier] Error sending message on Supabase: $e');
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, List<MessageEntity>, String>(
  (ref, tripId) => ChatNotifier(tripId, ref),
);
