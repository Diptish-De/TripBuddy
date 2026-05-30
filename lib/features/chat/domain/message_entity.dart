class MessageEntity {
  final String id;
  final String tripId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final String messageType; // 'text' | 'image' | 'system'
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    this.messageType = 'text',
    required this.createdAt,
  });

  bool isFromUser(String currentUserId) => userId == currentUserId;
  bool get isSystem => messageType == 'system';
}
