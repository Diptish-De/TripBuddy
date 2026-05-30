class ItineraryItemEntity {
  final String id;
  final String tripId;
  final String title;
  final String? description;
  final String? location;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String category; // 'transport' | 'stay' | 'activity' | 'food' | 'other'
  final String addedBy;
  final int sortOrder;
  final DateTime createdAt;

  const ItineraryItemEntity({
    required this.id,
    required this.tripId,
    required this.title,
    this.description,
    this.location,
    required this.date,
    this.startTime,
    this.endTime,
    required this.category,
    required this.addedBy,
    required this.sortOrder,
    required this.createdAt,
  });

  ItineraryItemEntity copyWith({
    String? title,
    String? description,
    String? location,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    int? sortOrder,
  }) {
    return ItineraryItemEntity(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      addedBy: addedBy,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }
}
