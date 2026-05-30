import '../../auth/domain/user_entity.dart';

class TripEntity {
  final String id;
  final String name;
  final String? description;
  final String destination;
  final String? coverImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final List<TripMemberEntity> members;

  const TripEntity({
    required this.id,
    required this.name,
    this.description,
    required this.destination,
    this.coverImageUrl,
    required this.startDate,
    required this.endDate,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.members = const [],
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;
  int get durationNights => endDate.difference(startDate).inDays;

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => endDate.isBefore(DateTime.now());

  TripEntity copyWith({
    String? name,
    String? description,
    String? destination,
    String? coverImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<TripMemberEntity>? members,
  }) {
    return TripEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      inviteCode: inviteCode,
      createdBy: createdBy,
      createdAt: createdAt,
      members: members ?? this.members,
    );
  }
}

class TripMemberEntity {
  final String id;
  final String tripId;
  final String userId;
  final String role; // 'admin' | 'member'
  final DateTime joinedAt;
  final UserEntity? user;

  const TripMemberEntity({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.user,
  });

  bool get isAdmin => role == 'admin';
}
