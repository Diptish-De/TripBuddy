import 'package:flutter_test/flutter_test.dart';
import 'package:trip_buddy/features/expenses/domain/balance_calculator.dart';
import 'package:trip_buddy/features/expenses/domain/expense_entity.dart';

void main() {
  group('BalanceCalculator & Debt Simplification Tests', () {
    final userNames = {
      'u1': 'Alice',
      'u2': 'Bob',
      'u3': 'Charlie',
    };

    test('Two persons equal split: debtor owes creditor half', () {
      final expenses = [
        ExpenseEntity(
          id: 'e1',
          tripId: 't1',
          paidBy: 'u1',
          paidByName: 'Alice',
          title: 'Lunch',
          amount: 100,
          category: 'food',
          splits: [
            ExpenseSplitEntity(id: 's1', expenseId: 'e1', userId: 'u1', userName: 'Alice', amount: 50),
            ExpenseSplitEntity(id: 's2', expenseId: 'e1', userId: 'u2', userName: 'Bob', amount: 50),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      final balances = BalanceCalculator.simplifyDebts(expenses, userNames);
      expect(balances.length, 1);
      expect(balances.first.fromUserId, 'u2');
      expect(balances.first.toUserId, 'u1');
      expect(balances.first.amount, 50.0);
    });

    test('Three persons circular debt simplification', () {
      // Alice paid 60 for Alice, Bob, Charlie (20 each)
      // Bob paid 30 for Alice, Bob, Charlie (10 each)
      // Net:
      // Alice: paid 60 - share 30 = +30 (owed 30)
      // Bob: paid 30 - share 30 = 0
      // Charlie: paid 0 - share 30 = -30 (owes 30)
      // Result: Charlie pays Alice 30 directly (1 transaction instead of 2)
      final List<ExpenseEntity> expenses = [
        ExpenseEntity(
          id: 'e1',
          tripId: 't1',
          paidBy: 'u1',
          paidByName: 'Alice',
          title: 'Dinner',
          amount: 60,
          category: 'food',
          splits: [
            ExpenseSplitEntity(id: 's1', expenseId: 'e1', userId: 'u1', userName: 'Alice', amount: 20),
            ExpenseSplitEntity(id: 's2', expenseId: 'e1', userId: 'u2', userName: 'Bob', amount: 20),
            ExpenseSplitEntity(id: 's3', expenseId: 'e1', userId: 'u3', userName: 'Charlie', amount: 20),
          ],
          createdAt: DateTime.now(),
        ),
        ExpenseEntity(
          id: 'e2',
          tripId: 't1',
          paidBy: 'u2',
          paidByName: 'Bob',
          title: 'Taxi',
          amount: 30,
          category: 'transport',
          splits: [
            ExpenseSplitEntity(id: 's4', expenseId: 'e2', userId: 'u1', userName: 'Alice', amount: 10),
            ExpenseSplitEntity(id: 's5', expenseId: 'e2', userId: 'u2', userName: 'Bob', amount: 10),
            ExpenseSplitEntity(id: 's6', expenseId: 'e2', userId: 'u3', userName: 'Charlie', amount: 10),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      final balances = BalanceCalculator.simplifyDebts(expenses, userNames);
      expect(balances.length, 1);
      expect(balances.first.fromUserId, 'u3');
      expect(balances.first.toUserId, 'u1');
      expect(balances.first.amount, 30.0);
    });

    test('Settlement cancels out debt completely', () {
      // Alice paid 100 for Alice and Bob -> Bob owes Alice 50
      // Bob records a settlement payment of 50 to Alice
      final List<ExpenseEntity> expenses = [
        ExpenseEntity(
          id: 'e1',
          tripId: 't1',
          paidBy: 'u1',
          paidByName: 'Alice',
          title: 'Groceries',
          amount: 100,
          category: 'food',
          splits: [
            ExpenseSplitEntity(id: 's1', expenseId: 'e1', userId: 'u1', userName: 'Alice', amount: 50),
            ExpenseSplitEntity(id: 's2', expenseId: 'e1', userId: 'u2', userName: 'Bob', amount: 50),
          ],
          createdAt: DateTime.now(),
        ),
        ExpenseEntity(
          id: 'e2',
          tripId: 't1',
          paidBy: 'u2',
          paidByName: 'Bob',
          title: 'Settlement: Bob -> Alice',
          amount: 50,
          category: 'settlement',
          splitType: 'settlement',
          splits: [
            ExpenseSplitEntity(id: 's3', expenseId: 'e2', userId: 'u1', userName: 'Alice', amount: 50),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      final balances = BalanceCalculator.simplifyDebts(expenses, userNames);
      // All debts are settled!
      expect(balances.isEmpty, isTrue);
    });

    test('totalTripExpense and expensesByCategory calculation', () {
      final List<ExpenseEntity> expenses = [
        ExpenseEntity(
          id: 'e1',
          tripId: 't1',
          paidBy: 'u1',
          paidByName: 'Alice',
          title: 'Lunch',
          amount: 250,
          category: 'food',
          splits: [],
          createdAt: DateTime.now(),
        ),
        ExpenseEntity(
          id: 'e2',
          tripId: 't1',
          paidBy: 'u2',
          paidByName: 'Bob',
          title: 'Cab',
          amount: 150,
          category: 'transport',
          splits: [],
          createdAt: DateTime.now(),
        ),
        ExpenseEntity(
          id: 'e3',
          tripId: 't1',
          paidBy: 'u1',
          paidByName: 'Alice',
          title: 'Dinner',
          amount: 300,
          category: 'food',
          splits: [],
          createdAt: DateTime.now(),
        ),
      ];

      expect(BalanceCalculator.totalTripExpense(expenses), 700.0);
      final byCat = BalanceCalculator.expensesByCategory(expenses);
      expect(byCat['food'], 550.0);
      expect(byCat['transport'], 150.0);
    });
  });
}
