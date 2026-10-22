import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/trip_entity.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TripsNotifier extends StateNotifier<List<TripEntity>> {
  final Ref _ref;

  TripsNotifier(this._ref) : super([]) {
    loadTrips();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> loadTrips() async {
    try {
      final authState = _ref.read(authProvider);
      final isDemo = authState.isDemo;
      final currentUserId = _client?.auth.currentUser?.id ?? authState.user?.id;

      if (currentUserId == null) {
        state = [];
        return;
      }

      if (!isDemo && _client != null && _client!.auth.currentUser != null) {
        try {
          final list = await _client!
              .from('trip_members')
              .select('trip_id')
              .eq('user_id', currentUserId);

          final tripIds = (list as List).map((item) => item['trip_id'] as String).toList();

          if (tripIds.isEmpty) {
            state = [];
            return;
          }

          final tripsResponse = await _client!
              .from('trips')
              .select('*, members:trip_members(*, user:profiles(*))')
              .inFilter('id', tripIds);

          final trips = (tripsResponse as List).map((map) {
            return TripEntity(
              id: map['id'],
              name: map['name'],
              description: map['description'],
              destination: map['destination'],
              coverImageUrl: map['cover_image_url'],
              startDate: DateTime.parse(map['start_date']),
              endDate: DateTime.parse(map['end_date']),
              inviteCode: map['invite_code'],
              createdBy: map['created_by'],
              createdAt: DateTime.parse(map['created_at']),
              members: (map['members'] as List? ?? []).map((m) {
                final u = m['user'];
                return TripMemberEntity(
                  id: m['id'],
                  tripId: m['trip_id'],
                  userId: m['user_id'],
                  role: m['role'] ?? 'member',
                  joinedAt: DateTime.parse(m['joined_at'] ?? DateTime.now().toIso8601String()),
                  user: u != null
                      ? UserEntity(
                          id: u['id'],
                          displayName: u['display_name'] ?? u['name'] ?? '',
                          email: u['email'] ?? '',
                          avatarUrl: u['avatar_url'],
                          createdAt: DateTime.parse(u['created_at'] ?? DateTime.now().toIso8601String()),
                        )
                      : null,
                );
              }).toList(),
            );
          }).toList();

          // Populate user names cache for references in other screens
          for (final trip in trips) {
            for (final member in trip.members) {
              if (member.user != null) {
                MockData.userNames[member.userId] = member.user!.displayName;
              }
            }
          }

          state = trips;
        } catch (e) {
          debugPrint('[TripsNotifier] Error loading trips from Supabase: $e. Falling back to local MockData.');
          _loadMockTrips(currentUserId);
        }
      } else {
        _loadMockTrips(currentUserId);
      }
    } catch (e) {
      debugPrint('[TripsNotifier] Error loading trips: $e');
    }
  }

  void _loadMockTrips(String currentUserId) {
    // Filter trips that have currentUserId as member or creator
    final userTrips = MockData.trips.where((t) {
      final isMember = t.members.any((m) => m.userId == currentUserId);
      return isMember || t.createdBy == currentUserId;
    }).toList();
    state = userTrips;
  }

  Future<void> addTrip({
    required String name,
    required String destination,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final authState = _ref.read(authProvider);
      final isDemo = authState.isDemo;
      final currentUserId = _client?.auth.currentUser?.id ?? authState.user?.id;
      if (currentUserId == null) return;

      if (!isDemo && _client != null && _client!.auth.currentUser != null) {
        try {
          final code = generateInviteCode();

          // Insert trip
          final tripRes = await _client!.from('trips').insert({
            'name': name,
            'destination': destination,
            'description': description,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'invite_code': code,
            'created_by': currentUserId,
          }).select().single();

          final tripId = tripRes['id'] as String;

          // Insert creator as admin
          await _client!.from('trip_members').insert({
            'trip_id': tripId,
            'user_id': currentUserId,
            'role': 'admin',
          });

          await loadTrips();
        } catch (e) {
          debugPrint('[TripsNotifier] Error adding trip to Supabase: $e. Saving to local MockData.');
          _addMockTrip(currentUserId, name, destination, description, startDate, endDate);
        }
      } else {
        _addMockTrip(currentUserId, name, destination, description, startDate, endDate);
      }
    } catch (e) {
      debugPrint('[TripsNotifier] Error adding trip: $e');
    }
  }

  void _addMockTrip(
    String currentUserId,
    String name,
    String destination,
    String? description,
    DateTime startDate,
    DateTime endDate,
  ) {
    final code = generateInviteCode();
    final tripId = 'trip-mock-${DateTime.now().millisecondsSinceEpoch}';
    final userEntity = _ref.read(authProvider).user ?? MockData.currentUser;

    final newTrip = TripEntity(
      id: tripId,
      name: name,
      description: description ?? '',
      destination: destination,
      coverImageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      startDate: startDate,
      endDate: endDate,
      inviteCode: code,
      createdBy: currentUserId,
      createdAt: DateTime.now(),
      members: [
        TripMemberEntity(
          id: 'member-mock-${DateTime.now().millisecondsSinceEpoch}',
          tripId: tripId,
          userId: currentUserId,
          role: 'admin',
          joinedAt: DateTime.now(),
          user: userEntity,
        ),
      ],
    );

    MockData.trips.insert(0, newTrip);
    loadTrips();
  }

  Future<TripEntity?> joinTrip(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final authState = _ref.read(authProvider);
    final isDemo = authState.isDemo;
    final currentUserId = _client?.auth.currentUser?.id ?? authState.user?.id;

    if (currentUserId == null) throw Exception('Not authenticated. Please sign in to join a trip.');

    if (!isDemo && _client != null && _client!.auth.currentUser != null) {
      try {
        final tripRes = await _client!
            .from('trips')
            .select()
            .eq('invite_code', cleanCode)
            .maybeSingle();

        if (tripRes == null) {
          throw Exception('Trip not found with invite code: $cleanCode');
        }

        final tripId = tripRes['id'] as String;

        final existingMember = await _client!
            .from('trip_members')
            .select()
            .eq('trip_id', tripId)
            .eq('user_id', currentUserId)
            .maybeSingle();

        if (existingMember == null) {
          await _client!.from('trip_members').insert({
            'trip_id': tripId,
            'user_id': currentUserId,
            'role': 'member',
          });
        }

        await loadTrips();

        try {
          return state.firstWhere((t) => t.id == tripId);
        } catch (_) {
          return null;
        }
      } catch (e) {
        debugPrint('[TripsNotifier] Error joining trip on Supabase: $e');
        return _joinMockTrip(currentUserId, cleanCode);
      }
    } else {
      return _joinMockTrip(currentUserId, cleanCode);
    }
  }

  TripEntity? _joinMockTrip(String currentUserId, String cleanCode) {
    try {
      final trip = MockData.trips.firstWhere(
        (t) => t.inviteCode.toUpperCase() == cleanCode,
      );

      final hasMember = trip.members.any((m) => m.userId == currentUserId);
      if (!hasMember) {
        final userEntity = _ref.read(authProvider).user ?? MockData.currentUser;
        trip.members.add(
          TripMemberEntity(
            id: 'member-mock-${DateTime.now().millisecondsSinceEpoch}',
            tripId: trip.id,
            userId: currentUserId,
            role: 'member',
            joinedAt: DateTime.now(),
            user: userEntity,
          ),
        );
      }
      loadTrips();
      return trip;
    } catch (_) {
      throw Exception('Trip not found with invite code: $cleanCode');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      final authState = _ref.read(authProvider);
      final isDemo = authState.isDemo;

      if (!isDemo && _client != null && _client!.auth.currentUser != null) {
        try {
          await _client!.from('trips').delete().eq('id', tripId);
          await loadTrips();
        } catch (e) {
          debugPrint('[TripsNotifier] Error deleting trip on Supabase: $e');
          _deleteMockTrip(tripId);
        }
      } else {
        _deleteMockTrip(tripId);
      }
    } catch (e) {
      debugPrint('[TripsNotifier] Error deleting trip: $e');
    }
  }

  void _deleteMockTrip(String tripId) {
    MockData.trips.removeWhere((t) => t.id == tripId);
    loadTrips();
  }

  static String generateInviteCode() {
    // 6-character high entropy uppercase alphanumeric avoiding ambiguous characters (0, O, 1, I)
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final random = Random.secure();
    return List.generate(6, (i) => chars[random.nextInt(chars.length)]).join();
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, List<TripEntity>>((ref) {
  return TripsNotifier(ref);
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
