class PollEntity {
  final String id;
  final String tripId;
  final String question;
  final bool isActive;
  final bool allowMultiple;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? endsAt;
  final List<PollOptionEntity> options;

  const PollEntity({
    required this.id,
    required this.tripId,
    required this.question,
    this.isActive = true,
    this.allowMultiple = false,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.endsAt,
    this.options = const [],
  });

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes.length);

  PollEntity copyWith({
    bool? isActive,
    List<PollOptionEntity>? options,
  }) {
    return PollEntity(
      id: id,
      tripId: tripId,
      question: question,
      isActive: isActive ?? this.isActive,
      allowMultiple: allowMultiple,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: createdAt,
      endsAt: endsAt,
      options: options ?? this.options,
    );
  }
}

class PollOptionEntity {
  final String id;
  final String pollId;
  final String optionText;
  final int sortOrder;
  final List<PollVoteEntity> votes;

  const PollOptionEntity({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.sortOrder,
    this.votes = const [],
  });

  double votePercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return votes.length / totalVotes;
  }
}

class PollVoteEntity {
  final String id;
  final String optionId;
  final String userId;
  final String userName;

  const PollVoteEntity({
    required this.id,
    required this.optionId,
    required this.userId,
    required this.userName,
  });
}
