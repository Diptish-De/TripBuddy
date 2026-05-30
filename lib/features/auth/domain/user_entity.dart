class UserEntity {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}
