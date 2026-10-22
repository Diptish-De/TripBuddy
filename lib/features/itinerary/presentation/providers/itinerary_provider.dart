import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/itinerary_item_entity.dart';

const _uuid = Uuid();

class ItineraryNotifier extends StateNotifier<List<ItineraryItemEntity>> {
  final String tripId;

  ItineraryNotifier(this.tripId) : super([]) {
    loadItinerary();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> loadItinerary() async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client
            .from('itinerary_items')
            .select()
            .eq('trip_id', tripId);

        final items = (response as List).map((map) {
          final date = DateTime.parse(map['date']);
          return ItineraryItemEntity(
            id: map['id'] as String,
            tripId: tripId,
            title: map['title'] ?? '',
            description: map['description'],
            location: map['location'],
            date: date,
            startTime: _parseTime(map['start_time'], date),
            endTime: _parseTime(map['end_time'], date),
            category: map['category'] ?? 'other',
            addedBy: map['created_by'] ?? '',
            sortOrder: 0,
            createdAt: DateTime.now(),
          );
        }).toList();

        state = items;
        return;
      } catch (e) {
        debugPrint('[ItineraryNotifier] Error loading itinerary: $e. Falling back to mock data.');
      }
    }

    // Fallback to mock data
    state = MockData.getItinerary(tripId);
  }

  DateTime? _parseTime(String? timeStr, DateTime date) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String? _formatTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00";
  }

  Future<void> addItem({
    required String title,
    String? description,
    String? location,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
    required String category,
  }) async {
    final client = _client;
    final currentUserId = client?.auth.currentUser?.id;

    if (client != null && currentUserId != null) {
      try {
        await client.from('itinerary_items').insert({
          'trip_id': tripId,
          'title': title,
          'description': description,
          'location': location,
          'date': date.toIso8601String().split('T')[0],
          'start_time': _formatTime(startTime),
          'end_time': _formatTime(endTime),
          'category': category,
          'created_by': currentUserId,
        });

        await loadItinerary();
        return;
      } catch (e) {
        debugPrint('[ItineraryNotifier] Error adding itinerary item to Supabase: $e');
      }
    }

    // Local / Demo mode write
    final newItem = ItineraryItemEntity(
      id: _uuid.v4(),
      tripId: tripId,
      title: title,
      description: description,
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
      category: category,
      addedBy: currentUserId ?? MockData.currentUser.id,
      sortOrder: state.length,
      createdAt: DateTime.now(),
    );
    state = [...state, newItem];
  }

  Future<void> removeItem(String itemId) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('itinerary_items').delete().eq('id', itemId);
        await loadItinerary();
        return;
      } catch (e) {
        debugPrint('[ItineraryNotifier] Error removing item from Supabase: $e');
      }
    }
    state = state.where((i) => i.id != itemId).toList();
  }

  Future<void> updateItem(String itemId, ItineraryItemEntity updated) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('itinerary_items').update({
          'title': updated.title,
          'description': updated.description,
          'location': updated.location,
          'date': updated.date.toIso8601String().split('T')[0],
          'start_time': _formatTime(updated.startTime),
          'end_time': _formatTime(updated.endTime),
          'category': updated.category,
        }).eq('id', itemId);

        await loadItinerary();
        return;
      } catch (e) {
        debugPrint('[ItineraryNotifier] Error updating item on Supabase: $e');
      }
    }
    state = state.map((i) => i.id == itemId ? updated : i).toList();
  }

  Map<DateTime, List<ItineraryItemEntity>> get groupedByDate {
    final map = <DateTime, List<ItineraryItemEntity>>{};
    for (final item in state) {
      final dateKey = DateTime(item.date.year, item.date.month, item.date.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(item);
    }

    for (final list in map.values) {
      list.sort((a, b) {
        if (a.startTime == null && b.startTime == null) return a.title.compareTo(b.title);
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return a.startTime!.compareTo(b.startTime!);
      });
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

final itineraryProvider = StateNotifierProvider.family<ItineraryNotifier, List<ItineraryItemEntity>, String>(
  (ref, tripId) => ItineraryNotifier(tripId),
);
