import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/itinerary_item_entity.dart';

const _uuid = Uuid();

class ItineraryNotifier extends StateNotifier<List<ItineraryItemEntity>> {
  final String tripId;

  ItineraryNotifier(this.tripId) : super(MockData.getItinerary(tripId));

  void addItem({
    required String title,
    String? description,
    String? location,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
    required String category,
  }) {
    final item = ItineraryItemEntity(
      id: _uuid.v4(),
      tripId: tripId,
      title: title,
      description: description,
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
      category: category,
      addedBy: MockData.currentUser.id,
      sortOrder: state.length,
      createdAt: DateTime.now(),
    );
    state = [...state, item];
  }

  void removeItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
  }

  void updateItem(String itemId, ItineraryItemEntity updated) {
    state = state.map((i) => i.id == itemId ? updated : i).toList();
  }

  Map<DateTime, List<ItineraryItemEntity>> get groupedByDate {
    final map = <DateTime, List<ItineraryItemEntity>>{};
    for (final item in state) {
      final dateKey = DateTime(item.date.year, item.date.month, item.date.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(item);
    }
    // Sort each group by sort order
    for (final list in map.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

final itineraryProvider = StateNotifierProvider.family<ItineraryNotifier, List<ItineraryItemEntity>, String>(
  (ref, tripId) => ItineraryNotifier(tripId),
);
