import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/note_entity.dart';

const _uuid = Uuid();

class NotesNotifier extends StateNotifier<List<NoteEntity>> {
  final String tripId;

  NotesNotifier(this.tripId) : super([]) {
    loadNotes();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> loadNotes() async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client
            .from('notes')
            .select()
            .eq('trip_id', tripId)
            .order('is_pinned', ascending: false)
            .order('created_at', ascending: false);

        final notes = (response as List).map((map) {
          final addedBy = map['created_by'] as String? ?? '';
          return NoteEntity(
            id: map['id'] as String,
            tripId: tripId,
            title: map['title'] ?? '',
            content: map['content'] ?? '',
            isPinned: map['is_pinned'] ?? false,
            addedBy: addedBy,
            addedByName: MockData.userNames[addedBy] ?? 'User',
            createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
            updatedAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();

        state = notes;
        return;
      } catch (e) {
        debugPrint('[NotesNotifier] Error loading notes from Supabase: $e');
      }
    }

    state = MockData.getNotes(tripId);
  }

  Future<void> addNote({required String title, required String content}) async {
    final client = _client;
    final currentUserId = client?.auth.currentUser?.id;

    if (client != null && currentUserId != null) {
      try {
        await client.from('notes').insert({
          'trip_id': tripId,
          'title': title,
          'content': content,
          'created_by': currentUserId,
          'is_pinned': false,
        });

        await loadNotes();
        return;
      } catch (e) {
        debugPrint('[NotesNotifier] Error adding note to Supabase: $e');
      }
    }

    // Local / Demo Mode write
    final newNote = NoteEntity(
      id: _uuid.v4(),
      tripId: tripId,
      title: title,
      content: content,
      isPinned: false,
      addedBy: currentUserId ?? MockData.currentUser.id,
      addedByName: MockData.currentUser.displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [newNote, ...state];
  }

  Future<void> updateNote(String noteId, {String? title, String? content}) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final updates = <String, dynamic>{};
        if (title != null) updates['title'] = title;
        if (content != null) updates['content'] = content;

        if (updates.isNotEmpty) {
          await client.from('notes').update(updates).eq('id', noteId);
          await loadNotes();
          return;
        }
      } catch (e) {
        debugPrint('[NotesNotifier] Error updating note on Supabase: $e');
      }
    }

    state = state.map((n) {
      if (n.id == noteId) {
        return n.copyWith(
          title: title ?? n.title,
          content: content ?? n.content,
          updatedAt: DateTime.now(),
        );
      }
      return n;
    }).toList();
  }

  Future<void> togglePin(String noteId) async {
    final client = _client;
    final note = state.firstWhere((n) => n.id == noteId);
    final updatedPin = !note.isPinned;

    // Optimistic update
    state = state.map((n) {
      if (n.id == noteId) return n.copyWith(isPinned: updatedPin);
      return n;
    }).toList();

    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('notes').update({
          'is_pinned': updatedPin,
        }).eq('id', noteId);
      } catch (e) {
        debugPrint('[NotesNotifier] Error toggling pin on Supabase: $e');
      }
    }
  }

  Future<void> deleteNote(String noteId) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('notes').delete().eq('id', noteId);
      } catch (e) {
        debugPrint('[NotesNotifier] Error deleting note from Supabase: $e');
      }
    }
    state = state.where((n) => n.id != noteId).toList();
  }
}

final notesProvider = StateNotifierProvider.family<NotesNotifier, List<NoteEntity>, String>(
  (ref, tripId) => NotesNotifier(tripId),
);
