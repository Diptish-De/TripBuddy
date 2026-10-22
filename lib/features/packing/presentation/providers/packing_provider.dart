import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/packing_item_entity.dart';

const _uuid = Uuid();

class PackingNotifier extends StateNotifier<List<PackingItemEntity>> {
  final String tripId;

  PackingNotifier(this.tripId) : super([]) {
    loadPackingItems();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> loadPackingItems() async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client
            .from('packing_items')
            .select()
            .eq('trip_id', tripId);

        final items = (response as List).map((map) {
          final assignedTo = map['assigned_to'] as String?;
          return PackingItemEntity(
            id: map['id'] as String,
            tripId: tripId,
            itemName: map['name'] ?? '',
            category: map['category'] ?? 'other',
            isPacked: map['is_packed'] ?? false,
            assignedTo: assignedTo,
            assignedToName: assignedTo != null ? MockData.userNames[assignedTo] : null,
            addedBy: '',
            createdAt: DateTime.now(),
          );
        }).toList();

        state = items;
        return;
      } catch (e) {
        debugPrint('[PackingNotifier] Error loading packing items from Supabase: $e');
      }
    }

    state = MockData.getPackingItems(tripId);
  }

  Future<void> addItem({
    required String itemName,
    required String category,
    String? assignedTo,
    String? assignedToName,
  }) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('packing_items').insert({
          'trip_id': tripId,
          'name': itemName,
          'category': category,
          'assigned_to': assignedTo,
          'is_packed': false,
        });

        await loadPackingItems();
        return;
      } catch (e) {
        debugPrint('[PackingNotifier] Error adding packing item to Supabase: $e');
      }
    }

    // Local / Demo Mode
    final newItem = PackingItemEntity(
      id: _uuid.v4(),
      tripId: tripId,
      itemName: itemName,
      category: category,
      isPacked: false,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      addedBy: MockData.currentUser.id,
      createdAt: DateTime.now(),
    );
    state = [...state, newItem];
  }

  Future<void> togglePacked(String itemId) async {
    final client = _client;
    final itemIndex = state.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;

    final currentItem = state[itemIndex];
    final updatedItem = currentItem.copyWith(isPacked: !currentItem.isPacked);

    // Optimistic UI update
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == itemIndex) updatedItem else state[i],
    ];

    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('packing_items').update({
          'is_packed': updatedItem.isPacked,
        }).eq('id', itemId);
      } catch (e) {
        debugPrint('[PackingNotifier] Error toggling packing item on Supabase: $e');
      }
    }
  }

  Future<void> removeItem(String itemId) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('packing_items').delete().eq('id', itemId);
      } catch (e) {
        debugPrint('[PackingNotifier] Error removing packing item from Supabase: $e');
      }
    }
    state = state.where((i) => i.id != itemId).toList();
  }

  int get packedCount => state.where((i) => i.isPacked).length;
  int get totalCount => state.length;
  double get progress => totalCount == 0 ? 0 : packedCount / totalCount;
}

final packingProvider = StateNotifierProvider.family<PackingNotifier, List<PackingItemEntity>, String>(
  (ref, tripId) => PackingNotifier(tripId),
);
