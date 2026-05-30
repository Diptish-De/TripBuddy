class ExpenseEntity {
  final String id;
  final String tripId;
  final String paidBy;
  final String paidByName;
  final String title;
  final double amount;
  final String currency;
  final String category; // 'food' | 'transport' | 'stay' | 'activity' | 'shopping' | 'other'
  final String splitType; // 'equal' | 'custom' | 'percentage'
  final List<ExpenseSplitEntity> splits;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.tripId,
    required this.paidBy,
    required this.paidByName,
    required this.title,
    required this.amount,
    this.currency = 'INR',
    required this.category,
    this.splitType = 'equal',
    this.splits = const [],
    required this.createdAt,
  });
}

class ExpenseSplitEntity {
  final String id;
  final String expenseId;
  final String userId;
  final String userName;
  final double amount;

  const ExpenseSplitEntity({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.userName,
    required this.amount,
  });
}

class BalanceEntry {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;

  const BalanceEntry({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
  });
}
