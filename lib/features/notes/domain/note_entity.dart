class NoteEntity {
  final String id;
  final String tripId;
  final String title;
  final String content;
  final bool isPinned;
  final String addedBy;
  final String addedByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.content,
    this.isPinned = false,
    required this.addedBy,
    required this.addedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteEntity copyWith({
    String? title,
    String? content,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      addedBy: addedBy,
      addedByName: addedByName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
