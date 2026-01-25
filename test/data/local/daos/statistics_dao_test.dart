import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('StatisticsDao', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
      // Créer des comptes pour les transactions
      await db.accountDao.createAccount(
        createTestAccount(id: 'acc-1'),
      );
      await db.accountDao.createAccount(
        createTestAccount(id: 'acc-2', balance: 500),
      );
    });

    tearDown(() async {
      await db.close();
    });

    group('getTotalByCategory', () {
      test('should return totals grouped by category', () async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        // Créer des transactions
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: 'acc-1',
            date: now,
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-2',
            accountId: 'acc-1',
            amount: 30,
            date: now,
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-3',
            accountId: 'acc-1',
            categoryId: 'cat_transport',
            amount: 20,
            date: now,
          ),
        );

        final stats = await db.statisticsDao.getTotalByCategory(
          startOfMonth,
          endOfMonth,
        );

        expect(stats.length, equals(2));

        final foodStats = stats.firstWhere((s) => s.categoryId == 'cat_food');
        expect(foodStats.total, equals(80.0));
        expect(foodStats.transactionCount, equals(2));

        final transportStats = stats.firstWhere((s) => s.categoryId == 'cat_transport');
        expect(transportStats.total, equals(20.0));
        expect(transportStats.transactionCount, equals(1));
      });

      test('should filter by date range', () async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        // Transaction dans la période
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: 'acc-1',
            date: now,
          ),
        );

        // Transaction hors période (mois dernier)
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-2',
            accountId: 'acc-1',
            amount: 100,
            date: now.subtract(const Duration(days: 60)),
          ),
        );

        final stats = await db.statisticsDao.getTotalByCategory(
          startOfMonth,
          endOfMonth,
        );

        expect(stats.length, equals(1));
        expect(stats.first.total, equals(50.0));
      });
    });

    group('getTotalByCategoryAndType', () {
      test('should filter by category type', () async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        // Dépense
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: 'acc-1',
            date: now,
          ),
        );

        // Revenu
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-2',
            accountId: 'acc-1',
            categoryId: 'cat_salary', // income
            amount: 2000,
            date: now,
          ),
        );

        final expenseStats = await db.statisticsDao.getTotalByCategoryAndType(
          startOfMonth,
          endOfMonth,
          CategoryType.expense,
        );

        expect(expenseStats.length, equals(1));
        expect(expenseStats.first.categoryId, equals('cat_food'));
        expect(expenseStats.first.total, equals(50.0));

        final incomeStats = await db.statisticsDao.getTotalByCategoryAndType(
          startOfMonth,
          endOfMonth,
          CategoryType.income,
        );

        expect(incomeStats.length, equals(1));
        expect(incomeStats.first.categoryId, equals('cat_salary'));
        expect(incomeStats.first.total, equals(2000.0));
      });
    });

    group('calculateAccountBalance', () {
      test('should calculate balance with income and expenses', () async {
        // Revenu de 500
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-income',
            accountId: 'acc-1',
            categoryId: 'cat_salary', // income
            amount: 500,
            date: DateTime.now(),
          ),
        );

        // Dépense de 200
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-expense',
            accountId: 'acc-1',
            amount: 200,
            date: DateTime.now(),
          ),
        );

        // Balance initiale: 1000 + 500 (income) - 200 (expense) = 1300
        final balance = await db.statisticsDao.calculateAccountBalance('acc-1');
        expect(balance, equals(1300.0));
      });

      test('should return initial balance when no transactions', () async {
        final balance = await db.statisticsDao.calculateAccountBalance('acc-1');
        expect(balance, equals(1000.0)); // Initial balance
      });

      test('should return 0 for non-existent account', () async {
        final balance = await db.statisticsDao.calculateAccountBalance('non-existent');
        expect(balance, equals(0.0));
      });
    });

    group('getMonthlyStatistics', () {
      test('should return monthly breakdown', () async {
        final year = DateTime.now().year;

        // Janvier: income 1000, expense 300
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-jan-income',
            accountId: 'acc-1',
            categoryId: 'cat_salary',
            amount: 1000,
            date: DateTime(year, 1, 15),
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-jan-expense',
            accountId: 'acc-1',
            amount: 300,
            date: DateTime(year, 1, 20),
          ),
        );

        // Février: income 1500, expense 400
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-feb-income',
            accountId: 'acc-1',
            categoryId: 'cat_salary',
            amount: 1500,
            date: DateTime(year, 2, 15),
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-feb-expense',
            accountId: 'acc-1',
            amount: 400,
            date: DateTime(year, 2, 20),
          ),
        );

        final stats = await db.statisticsDao.getMonthlyStatistics(year);

        expect(stats.length, equals(2));

        final janStats = stats.firstWhere((s) => s.month == 1);
        expect(janStats.totalIncome, equals(1000.0));
        expect(janStats.totalExpense, equals(300.0));
        expect(janStats.balance, equals(700.0));

        final febStats = stats.firstWhere((s) => s.month == 2);
        expect(febStats.totalIncome, equals(1500.0));
        expect(febStats.totalExpense, equals(400.0));
        expect(febStats.balance, equals(1100.0));
      });
    });

    group('getFinancialSummary', () {
      test('should return complete financial summary', () async {
        final now = DateTime.now();

        // Ce mois: income 2000, expense 500
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-income',
            accountId: 'acc-1',
            categoryId: 'cat_salary',
            amount: 2000,
            date: now,
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-expense',
            accountId: 'acc-1',
            amount: 500,
            date: now,
          ),
        );

        final summary = await db.statisticsDao.getFinancialSummary();

        expect(summary.totalIncome, equals(2000.0));
        expect(summary.totalExpense, equals(500.0));
        expect(summary.monthlyIncome, equals(2000.0));
        expect(summary.monthlyExpense, equals(500.0));
        // Total balance = accounts balance (1000 + 500) + transactions net (2000 - 500)
        expect(summary.totalBalance, equals(3000.0));
      });
    });

    group('getCategorySpendingThisMonth', () {
      test('should return spending for specific category', () async {
        final now = DateTime.now();

        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: 'acc-1',
            date: now,
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-2',
            accountId: 'acc-1',
            amount: 75,
            date: now,
          ),
        );

        final spending = await db.statisticsDao.getCategorySpendingThisMonth('cat_food');
        expect(spending, equals(125.0));
      });

      test('should return 0 for category with no transactions', () async {
        final spending = await db.statisticsDao.getCategorySpendingThisMonth('cat_transport');
        expect(spending, equals(0.0));
      });
    });
  });
}
