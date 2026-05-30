import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/note_entity.dart';

const _uuid = Uuid();

class NotesNotifier extends StateNotifier<List<NoteEntity>> {
  final String tripId;

  NotesNotifier(this.tripId) : super(MockData.getNotes(tripId));

  void addNote({required String title, required String content}) {
    final note = NoteEntity(
      id: _uuid.v4(),
      tripId: tripId,
      title: title,
      content: content,
      addedBy: MockData.currentUser.id,
      addedByName: MockData.currentUser.displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [note, ...state];
  }

  void updateNote(String noteId, {String? title, String? content}) {
    state = state.map((n) {
      if (n.id == noteId) {
        return n.copyWith(
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        );
      }
      return n;
    }).toList();
  }

  void togglePin(String noteId) {
    state = state.map((n) {
      if (n.id == noteId) return n.copyWith(isPinned: !n.isPinned);
      return n;
    }).toList();
  }

  void deleteNote(String noteId) {
    state = state.where((n) => n.id != noteId).toList();
  }
}

final notesProvider = StateNotifierProvider.family<NotesNotifier, List<NoteEntity>, String>(
  (ref, tripId) => NotesNotifier(tripId),
);
