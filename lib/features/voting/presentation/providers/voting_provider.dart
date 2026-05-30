import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/poll_entity.dart';

const _uuid = Uuid();

class VotingNotifier extends StateNotifier<List<PollEntity>> {
  final String tripId;

  VotingNotifier(this.tripId) : super(MockData.getPolls(tripId));

  void createPoll({
    required String question,
    required List<String> options,
    bool allowMultiple = false,
  }) {
    final pollId = _uuid.v4();
    final poll = PollEntity(
      id: pollId,
      tripId: tripId,
      question: question,
      allowMultiple: allowMultiple,
      createdBy: MockData.currentUser.id,
      createdByName: MockData.currentUser.displayName,
      createdAt: DateTime.now(),
      options: options.asMap().entries.map((e) => PollOptionEntity(
        id: _uuid.v4(),
        pollId: pollId,
        optionText: e.value,
        sortOrder: e.key,
      )).toList(),
    );
    state = [poll, ...state];
  }

  void vote(String pollId, String optionId) {
    state = state.map((poll) {
      if (poll.id != pollId) return poll;

      final updatedOptions = poll.options.map((option) {
        // Remove existing vote from this user on other options (if not multi-select)
        var votes = option.votes.where((v) => v.userId != MockData.currentUser.id).toList();

        if (option.id == optionId) {
          // Check if user already voted for this option
          final alreadyVoted = option.votes.any((v) => v.userId == MockData.currentUser.id);
          if (!alreadyVoted) {
            votes = [
              ...votes,
              PollVoteEntity(
                id: _uuid.v4(),
                optionId: optionId,
                userId: MockData.currentUser.id,
                userName: MockData.currentUser.displayName,
              ),
            ];
          }
        } else if (poll.allowMultiple) {
          // Keep existing votes on other options for multi-select
          votes = option.votes.toList();
          if (option.id == optionId) {
            votes.add(PollVoteEntity(
              id: _uuid.v4(),
              optionId: optionId,
              userId: MockData.currentUser.id,
              userName: MockData.currentUser.displayName,
            ));
          }
        }

        return PollOptionEntity(
          id: option.id,
          pollId: option.pollId,
          optionText: option.optionText,
          sortOrder: option.sortOrder,
          votes: votes,
        );
      }).toList();

      return poll.copyWith(options: updatedOptions);
    }).toList();
  }

  void closePoll(String pollId) {
    state = state.map((p) {
      if (p.id == pollId) return p.copyWith(isActive: false);
      return p;
    }).toList();
  }
}

final votingProvider = StateNotifierProvider.family<VotingNotifier, List<PollEntity>, String>(
  (ref, tripId) => VotingNotifier(tripId),
);
