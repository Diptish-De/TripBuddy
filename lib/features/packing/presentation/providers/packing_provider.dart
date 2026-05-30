import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/packing_item_entity.dart';

const _uuid = Uuid();

class PackingNotifier extends StateNotifier<List<PackingItemEntity>> {
  final String tripId;

  PackingNotifier(this.tripId) : super(MockData.getPackingItems(tripId));

  void addItem({
    required String itemName,
    required String category,
    String? assignedTo,
    String? assignedToName,
  }) {
    final item = PackingItemEntity(
      id: _uuid.v4(),
      tripId: tripId,
      itemName: itemName,
      category: category,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      addedBy: MockData.currentUser.id,
      createdAt: DateTime.now(),
    );
    state = [...state, item];
  }

  void togglePacked(String itemId) {
    state = state.map((i) {
      if (i.id == itemId) return i.copyWith(isPacked: !i.isPacked);
      return i;
    }).toList();
  }

  void removeItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
  }

  int get packedCount => state.where((i) => i.isPacked).length;
  int get totalCount => state.length;
  double get progress => totalCount == 0 ? 0 : packedCount / totalCount;
}

final packingProvider = StateNotifierProvider.family<PackingNotifier, List<PackingItemEntity>, String>(
  (ref, tripId) => PackingNotifier(tripId),
);
