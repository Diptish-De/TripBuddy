import 'expense_entity.dart';

class BalanceCalculator {
  /// Computes simplified debts from a list of expenses.
  /// Returns a list of BalanceEntry showing who owes whom.
  static List<BalanceEntry> simplifyDebts(
    List<ExpenseEntity> expenses,
    Map<String, String> userNames,
  ) {
    // Step 1: Calculate net balance for each user
    final Map<String, double> netBalances = {};

    for (final expense in expenses) {
      // Add what the payer paid
      netBalances[expense.paidBy] =
          (netBalances[expense.paidBy] ?? 0) + expense.amount;

      // Subtract each person's share
      for (final split in expense.splits) {
        netBalances[split.userId] =
            (netBalances[split.userId] ?? 0) - split.amount;
      }
    }

    // Step 2: Separate into debtors and creditors
    final debtors = <MapEntry<String, double>>[]; // negative balance (owes money)
    final creditors = <MapEntry<String, double>>[]; // positive balance (owed money)

    netBalances.forEach((userId, balance) {
      if (balance < -0.01) {
        debtors.add(MapEntry(userId, -balance)); // make positive
      } else if (balance > 0.01) {
        creditors.add(MapEntry(userId, balance));
      }
    });

    // Sort by amount (largest first) for optimal simplification
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    // Step 3: Greedy algorithm to simplify
    final results = <BalanceEntry>[];
    int di = 0, ci = 0;
    final debtAmounts = debtors.map((e) => e.value).toList();
    final creditAmounts = creditors.map((e) => e.value).toList();

    while (di < debtors.length && ci < creditors.length) {
      final amount =
          debtAmounts[di] < creditAmounts[ci] ? debtAmounts[di] : creditAmounts[ci];

      results.add(BalanceEntry(
        fromUserId: debtors[di].key,
        fromUserName: userNames[debtors[di].key] ?? 'Unknown',
        toUserId: creditors[ci].key,
        toUserName: userNames[creditors[ci].key] ?? 'Unknown',
        amount: double.parse(amount.toStringAsFixed(2)),
      ));

      debtAmounts[di] -= amount;
      creditAmounts[ci] -= amount;

      if (debtAmounts[di] < 0.01) di++;
      if (creditAmounts[ci] < 0.01) ci++;
    }

    return results;
  }

  /// Get total spent per user
  static Map<String, double> totalSpentPerUser(List<ExpenseEntity> expenses) {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.paidBy] = (totals[expense.paidBy] ?? 0) + expense.amount;
    }
    return totals;
  }

  /// Get total trip expense
  static double totalTripExpense(List<ExpenseEntity> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get expenses by category
  static Map<String, double> expensesByCategory(List<ExpenseEntity> expenses) {
    final Map<String, double> categories = {};
    for (final expense in expenses) {
      categories[expense.category] =
          (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }
}
