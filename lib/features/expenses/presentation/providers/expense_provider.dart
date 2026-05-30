import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/expense_entity.dart';
import '../../domain/balance_calculator.dart';

const _uuid = Uuid();

class ExpensesNotifier extends StateNotifier<List<ExpenseEntity>> {
  final String tripId;

  ExpensesNotifier(this.tripId) : super(MockData.getExpenses(tripId));

  void addExpense({
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required String paidByName,
    required List<String> splitAmong,
    String splitType = 'equal',
  }) {
    final expId = _uuid.v4();
    final splitAmount = amount / splitAmong.length;

    final expense = ExpenseEntity(
      id: expId,
      tripId: tripId,
      paidBy: paidBy,
      paidByName: paidByName,
      title: title,
      amount: amount,
      category: category,
      splitType: splitType,
      splits: splitAmong.map((uid) => ExpenseSplitEntity(
        id: _uuid.v4(),
        expenseId: expId,
        userId: uid,
        userName: MockData.userNames[uid] ?? '',
        amount: double.parse(splitAmount.toStringAsFixed(2)),
      )).toList(),
      createdAt: DateTime.now(),
    );
    state = [expense, ...state];
  }

  void removeExpense(String expenseId) {
    state = state.where((e) => e.id != expenseId).toList();
  }
}

final expensesProvider = StateNotifierProvider.family<ExpensesNotifier, List<ExpenseEntity>, String>(
  (ref, tripId) => ExpensesNotifier(tripId),
);

final balancesProvider = Provider.family<List<BalanceEntry>, String>((ref, tripId) {
  final expenses = ref.watch(expensesProvider(tripId));
  return BalanceCalculator.simplifyDebts(expenses, MockData.userNames);
});

final totalExpenseProvider = Provider.family<double, String>((ref, tripId) {
  final expenses = ref.watch(expensesProvider(tripId));
  return BalanceCalculator.totalTripExpense(expenses);
});

final expensesByCategoryProvider = Provider.family<Map<String, double>, String>((ref, tripId) {
  final expenses = ref.watch(expensesProvider(tripId));
  return BalanceCalculator.expensesByCategory(expenses);
});
