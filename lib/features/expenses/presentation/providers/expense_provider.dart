import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/expense_entity.dart';
import '../../domain/balance_calculator.dart';

const _uuid = Uuid();

class ExpensesNotifier extends StateNotifier<List<ExpenseEntity>> {
  final String tripId;

  ExpensesNotifier(this.tripId) : super([]) {
    loadExpenses();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> loadExpenses() async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final response = await client
            .from('expenses')
            .select('*, splits:expense_splits(*)')
            .eq('trip_id', tripId)
            .order('created_at', ascending: false);

        final expenses = (response as List).map((map) {
          final expId = map['id'] as String;
          final splits = (map['splits'] as List? ?? []).map((s) {
            final uid = s['user_id'] as String;
            return ExpenseSplitEntity(
              id: s['id'] as String,
              expenseId: expId,
              userId: uid,
              userName: MockData.userNames[uid] ?? 'User',
              amount: (s['amount'] as num).toDouble(),
            );
          }).toList();

          final paidBy = map['paid_by'] as String;
          return ExpenseEntity(
            id: expId,
            tripId: tripId,
            paidBy: paidBy,
            paidByName: MockData.userNames[paidBy] ?? 'User',
            title: map['title'] ?? '',
            amount: (map['amount'] as num).toDouble(),
            category: map['category'] ?? 'other',
            splitType: map['split_type'] ?? 'equal',
            splits: splits,
            createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();

        state = expenses;
        return;
      } catch (e) {
        debugPrint('[ExpensesNotifier] Error loading expenses from Supabase: $e. Falling back to mock data.');
      }
    }

    state = MockData.getExpenses(tripId);
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required String paidByName,
    required List<String> splitAmong,
    String splitType = 'equal',
  }) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        final expenseRes = await client.from('expenses').insert({
          'trip_id': tripId,
          'paid_by': paidBy,
          'title': title,
          'amount': amount,
          'category': category,
          'split_type': splitType,
        }).select().single();

        final expId = expenseRes['id'] as String;
        final splitAmount = amount / splitAmong.length;

        final splitsToInsert = splitAmong.map((uid) => {
          'expense_id': expId,
          'user_id': uid,
          'amount': double.parse(splitAmount.toStringAsFixed(2)),
        }).toList();

        await client.from('expense_splits').insert(splitsToInsert);
        await loadExpenses();
        return;
      } catch (e) {
        debugPrint('[ExpensesNotifier] Error adding expense to Supabase: $e');
      }
    }

    // Local / Demo Mode write
    final expId = _uuid.v4();
    final splitAmount = amount / splitAmong.length;
    final newSplits = splitAmong.map((uid) => ExpenseSplitEntity(
      id: _uuid.v4(),
      expenseId: expId,
      userId: uid,
      userName: MockData.userNames[uid] ?? 'User',
      amount: double.parse(splitAmount.toStringAsFixed(2)),
    )).toList();

    final newExpense = ExpenseEntity(
      id: expId,
      tripId: tripId,
      paidBy: paidBy,
      paidByName: paidByName,
      title: title,
      amount: amount,
      category: category,
      splitType: splitType,
      splits: newSplits,
      createdAt: DateTime.now(),
    );

    state = [newExpense, ...state];
  }

  Future<void> settleDebt({
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
    required double amount,
  }) async {
    await addExpense(
      title: 'Settlement: $fromUserName → $toUserName',
      amount: amount,
      category: 'settlement',
      paidBy: fromUserId,
      paidByName: fromUserName,
      splitAmong: [toUserId],
      splitType: 'settlement',
    );
  }

  Future<void> removeExpense(String expenseId) async {
    final client = _client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('expenses').delete().eq('id', expenseId);
        await loadExpenses();
        return;
      } catch (e) {
        debugPrint('[ExpensesNotifier] Error removing expense from Supabase: $e');
      }
    }
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
  // Filter out settlement records from total trip expenses
  final actualExpenses = expenses.where((e) => e.category != 'settlement').toList();
  return BalanceCalculator.totalTripExpense(actualExpenses);
});

final expensesByCategoryProvider = Provider.family<Map<String, double>, String>((ref, tripId) {
  final expenses = ref.watch(expensesProvider(tripId));
  final actualExpenses = expenses.where((e) => e.category != 'settlement').toList();
  return BalanceCalculator.expensesByCategory(actualExpenses);
});
