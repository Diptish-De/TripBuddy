import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/poll_entity.dart';

const _uuid = Uuid();

class VotingNotifier extends StateNotifier<List<PollEntity>> {
  final String tripId;

  VotingNotifier(this.tripId) : super([]) {
    loadPolls();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> loadPolls() async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client
            .from('polls')
            .select('*, options:poll_options(*, votes:poll_votes(*))')
            .eq('trip_id', tripId)
            .order('created_at', ascending: false);

        final polls = (response as List).map((map) {
          final pollId = map['id'] as String;
          final createdBy = map['created_by'] as String? ?? '';
          final options = (map['options'] as List? ?? []).map((o) {
            final optId = o['id'] as String;
            final votes = (o['votes'] as List? ?? []).map((v) {
              final uid = v['user_id'] as String;
              return PollVoteEntity(
                id: v['id'] as String,
                optionId: optId,
                userId: uid,
                userName: MockData.userNames[uid] ?? 'User',
              );
            }).toList();

            return PollOptionEntity(
              id: optId,
              pollId: pollId,
              optionText: o['text'] ?? '',
              sortOrder: 0,
              votes: votes,
            );
          }).toList();

          return PollEntity(
            id: pollId,
            tripId: tripId,
            question: map['question'] ?? '',
            allowMultiple: map['is_multiple_choice'] ?? false,
            isActive: map['is_active'] ?? true,
            createdBy: createdBy,
            createdByName: MockData.userNames[createdBy] ?? 'User',
            createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
            options: options,
          );
        }).toList();

        state = polls;
        return;
      } catch (e) {
        debugPrint('[VotingNotifier] Error loading polls from Supabase: $e');
      }
    }

    state = MockData.getPolls(tripId);
  }

  Future<void> createPoll({
    required String question,
    required List<String> options,
    bool allowMultiple = false,
  }) async {
    final client = _client;
    final currentUserId = client?.auth.currentUser?.id;

    if (client != null && currentUserId != null) {
      try {
        final pollRes = await client.from('polls').insert({
          'trip_id': tripId,
          'question': question,
          'is_multiple_choice': allowMultiple,
          'created_by': currentUserId,
        }).select().single();

        final pollId = pollRes['id'] as String;

        final optionsToInsert = options.map((opt) => {
          'poll_id': pollId,
          'text': opt,
        }).toList();

        await client.from('poll_options').insert(optionsToInsert);
        await loadPolls();
        return;
      } catch (e) {
        debugPrint('[VotingNotifier] Error creating poll on Supabase: $e');
      }
    }

    // Local / Demo Mode write
    final pollId = _uuid.v4();
    final newPoll = PollEntity(
      id: pollId,
      tripId: tripId,
      question: question,
      allowMultiple: allowMultiple,
      isActive: true,
      createdBy: currentUserId ?? MockData.currentUser.id,
      createdByName: MockData.currentUser.displayName,
      createdAt: DateTime.now(),
      options: options.asMap().entries.map((e) => PollOptionEntity(
        id: _uuid.v4(),
        pollId: pollId,
        optionText: e.value,
        sortOrder: e.key,
        votes: [],
      )).toList(),
    );

    state = [newPoll, ...state];
  }

  Future<void> vote(String pollId, String optionId) async {
    final client = _client;
    final currentUserId = client?.auth.currentUser?.id ?? MockData.currentUser.id;
    final currentUserName = MockData.currentUser.displayName;

    // Optimistic local update
    state = state.map((p) {
      if (p.id != pollId) return p;

      final updatedOptions = p.options.map((opt) {
        if (!p.allowMultiple && opt.id != optionId) {
          // Remove previous vote if single choice
          final filtered = opt.votes.where((v) => v.userId != currentUserId).toList();
          return opt.copyWith(votes: filtered);
        }

        if (opt.id == optionId) {
          final alreadyVoted = opt.votes.any((v) => v.userId == currentUserId);
          if (alreadyVoted) {
            final filtered = opt.votes.where((v) => v.userId != currentUserId).toList();
            return opt.copyWith(votes: filtered);
          } else {
            final newVote = PollVoteEntity(
              id: _uuid.v4(),
              optionId: opt.id,
              userId: currentUserId,
              userName: currentUserName,
            );
            return opt.copyWith(votes: [...opt.votes, newVote]);
          }
        }

        return opt;
      }).toList();

      return p.copyWith(options: updatedOptions);
    }).toList();

    if (client != null && client.auth.currentUser != null) {
      try {
        final poll = state.firstWhere((p) => p.id == pollId);
        if (!poll.allowMultiple) {
          final optionIds = poll.options.map((o) => o.id).toList();
          await client
              .from('poll_votes')
              .delete()
              .eq('user_id', currentUserId)
              .inFilter('option_id', optionIds);
        }

        final option = poll.options.firstWhere((o) => o.id == optionId);
        final alreadyVoted = option.votes.any((v) => v.userId == currentUserId);

        if (!alreadyVoted) {
          await client.from('poll_votes').insert({
            'option_id': optionId,
            'user_id': currentUserId,
          });
        }
      } catch (e) {
        debugPrint('[VotingNotifier] Error voting on Supabase: $e');
      }
    }
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
