class PackingItemEntity {
  final String id;
  final String tripId;
  final String itemName;
  final String category; // 'clothing' | 'toiletries' | 'electronics' | 'documents' | 'medicine' | 'other'
  final String? assignedTo;
  final String? assignedToName;
  final bool isPacked;
  final String addedBy;
  final DateTime createdAt;

  const PackingItemEntity({
    required this.id,
    required this.tripId,
    required this.itemName,
    required this.category,
    this.assignedTo,
    this.assignedToName,
    this.isPacked = false,
    required this.addedBy,
    required this.createdAt,
  });

  PackingItemEntity copyWith({
    String? itemName,
    String? category,
    String? assignedTo,
    String? assignedToName,
    bool? isPacked,
  }) {
    return PackingItemEntity(
      id: id,
      tripId: tripId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      isPacked: isPacked ?? this.isPacked,
      addedBy: addedBy,
      createdAt: createdAt,
    );
  }

  static IconCategory get packingCategories => const IconCategory._();
}

class IconCategory {
  const IconCategory._();

  static const Map<String, String> labels = {
    'clothing': '👕 Clothing',
    'toiletries': '🧴 Toiletries',
    'electronics': '📱 Electronics',
    'documents': '📄 Documents',
    'medicine': '💊 Medicine',
    'food': '🍫 Snacks',
    'other': '📦 Other',
  };
}
