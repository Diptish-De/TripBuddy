import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/trip_entity.dart';


const _uuid = Uuid();

class TripsNotifier extends StateNotifier<List<TripEntity>> {
  TripsNotifier() : super(MockData.trips);

  void addTrip({
    required String name,
    required String destination,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final code = _generateInviteCode();
    final trip = TripEntity(
      id: _uuid.v4(),
      name: name,
      destination: destination,
      description: description,
      startDate: startDate,
      endDate: endDate,
      inviteCode: code,
      createdBy: MockData.currentUser.id,
      createdAt: DateTime.now(),
      members: [
        TripMemberEntity(
          id: _uuid.v4(),
          tripId: '',
          userId: MockData.currentUser.id,
          role: 'admin',
          joinedAt: DateTime.now(),
          user: MockData.currentUser,
        ),
      ],
    );
    state = [trip, ...state];
  }

  TripEntity? joinTrip(String code) {
    final trip = state.firstWhere(
      (t) => t.inviteCode.toUpperCase() == code.toUpperCase(),
      orElse: () => throw Exception('Trip not found'),
    );

    final alreadyMember = trip.members.any((m) => m.userId == MockData.currentUser.id);
    if (alreadyMember) return trip;

    final updated = trip.copyWith(
      members: [
        ...trip.members,
        TripMemberEntity(
          id: _uuid.v4(),
          tripId: trip.id,
          userId: MockData.currentUser.id,
          role: 'member',
          joinedAt: DateTime.now(),
          user: MockData.currentUser,
        ),
      ],
    );

    state = state.map((t) => t.id == trip.id ? updated : t).toList();
    return updated;
  }

  void deleteTrip(String tripId) {
    state = state.where((t) => t.id != tripId).toList();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(random + i * 7) % chars.length]).join();
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, List<TripEntity>>((ref) {
  return TripsNotifier();
});

final selectedTripProvider = StateProvider<TripEntity?>((ref) => null);

final tripByIdProvider = Provider.family<TripEntity?, String>((ref, tripId) {
  final trips = ref.watch(tripsProvider);
  try {
    return trips.firstWhere((t) => t.id == tripId);
  } catch (_) {
    return null;
  }
});
