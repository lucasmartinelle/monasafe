import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/repositories/transaction_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  group('TransactionRepository', () {
    late AppDatabase db;
    late TransactionRepository repository;
    late String accountId;

    setUp(() async {
      db = createTestDatabase();
      repository = TransactionRepository(db);

      // Créer un compte pour les transactions
      await db.accountDao.createAccount(
        createTestAccount(id: 'test-account'),
      );
      accountId = 'test-account';
    });

    tearDown(() async {
      await db.close();
    });

    group('createTransaction', () {
      test('should create transaction successfully', () async {
        final result = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
          note: 'Courses',
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transaction) {
            expect(transaction.amount, equals(50.0));
            expect(transaction.accountId, equals(accountId));
            expect(transaction.categoryId, equals('cat_food'));
            expect(transaction.note, equals('Courses'));
            expect(transaction.syncStatus, equals(SyncStatus.pending));
          },
        );
      });

      test('should return Left when account does not exist', () async {
        final result = await repository.createTransaction(
          accountId: 'non-existent',
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<InvalidAccountError>()),
          (transaction) => fail('Should be an error'),
        );
      });

      test('should return Left when category does not exist', () async {
        final result = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'non-existent',
          amount: 50,
          date: DateTime.now(),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<InvalidCategoryError>()),
          (transaction) => fail('Should be an error'),
        );
      });

      test('should create recurring transaction', () async {
        final result = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_salary',
          amount: 2000,
          date: DateTime.now(),
          isRecurring: true,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transaction) => expect(transaction.isRecurring, isTrue),
        );
      });
    });

    group('createTransactions (batch)', () {
      test('should create multiple transactions', () async {
        final items = [
          (
            accountId: accountId,
            categoryId: 'cat_food',
            amount: 10.0,
            date: DateTime.now(),
            note: null as String?,
            isRecurring: false,
          ),
          (
            accountId: accountId,
            categoryId: 'cat_transport',
            amount: 20.0,
            date: DateTime.now(),
            note: 'Metro',
            isRecurring: false,
          ),
        ];

        final result = await repository.createTransactions(items);

        expect(result.isRight(), isTrue);
        expect(await repository.countTransactions(), equals(2));
      });
    });

    group('getAllTransactions', () {
      test('should return all transactions with details', () async {
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_transport',
          amount: 20,
          date: DateTime.now(),
        );

        final result = await repository.getAllTransactions();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transactions) {
            expect(transactions.length, equals(2));
            // Vérifie que les détails sont inclus
            expect(transactions.first.account, isNot(equals(null)));
            expect(transactions.first.category, isNot(equals(null)));
          },
        );
      });
    });

    group('getTransactionsByPeriod', () {
      test('should filter transactions by date range', () async {
        final now = DateTime.now();

        // Transaction dans la période
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: now,
        );

        // Transaction hors période
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 100,
          date: now.subtract(const Duration(days: 60)),
        );

        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        final result = await repository.getTransactionsByPeriod(
          startOfMonth,
          endOfMonth,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transactions) => expect(transactions.length, equals(1)),
        );
      });
    });

    group('getRecentTransactions', () {
      test('should return limited number of transactions', () async {
        // Créer 10 transactions
        for (var i = 0; i < 10; i++) {
          await repository.createTransaction(
            accountId: accountId,
            categoryId: 'cat_food',
            amount: 10.0 * i,
            date: DateTime.now().subtract(Duration(days: i)),
          );
        }

        final result = await repository.getRecentTransactions(5);

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transactions) => expect(transactions.length, equals(5)),
        );
      });
    });

    group('updateTransaction', () {
      test('should update transaction amount', () async {
        final created = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
        final transactionId = created.getOrElse((l) => throw l).id;

        final result = await repository.updateTransaction(
          id: transactionId,
          amount: 75,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transaction) {
            expect(transaction.amount, equals(75.0));
            expect(transaction.syncStatus, equals(SyncStatus.pending));
          },
        );
      });

      test('should return Left when transaction not found', () async {
        final result = await repository.updateTransaction(
          id: 'non-existent',
          amount: 100,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<TransactionNotFoundError>()),
          (transaction) => fail('Should be an error'),
        );
      });

      test('should validate new account when updating', () async {
        final created = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
        final transactionId = created.getOrElse((l) => throw l).id;

        final result = await repository.updateTransaction(
          id: transactionId,
          accountId: 'non-existent',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<InvalidAccountError>()),
          (transaction) => fail('Should be an error'),
        );
      });
    });

    group('deleteTransaction', () {
      test('should delete transaction', () async {
        final created = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
        final transactionId = created.getOrElse((l) => throw l).id;

        final result = await repository.deleteTransaction(transactionId);

        expect(result.isRight(), isTrue);
        expect(await repository.countTransactions(), equals(0));
      });

      test('should return Left when transaction not found', () async {
        final result = await repository.deleteTransaction('non-existent');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<TransactionNotFoundError>()),
          (_) => fail('Should be an error'),
        );
      });
    });

    group('getPendingTransactions', () {
      test('should return only pending transactions', () async {
        // Créer deux transactions
        final tx1 = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_transport',
          amount: 20,
          date: DateTime.now(),
        );

        // Marquer une comme synchronisée
        final tx1Id = tx1.getOrElse((l) => throw l).id;
        await repository.markAsSynced(tx1Id);

        final result = await repository.getPendingTransactions();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (transactions) => expect(transactions.length, equals(1)),
        );
      });
    });

    group('markAsSynced', () {
      test('should mark transaction as synced', () async {
        final created = await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
        final transactionId = created.getOrElse((l) => throw l).id;

        final result = await repository.markAsSynced(transactionId);

        expect(result.isRight(), isTrue);

        // Vérifier le statut
        final tx = await db.transactionDao.getTransactionById(transactionId);
        expect(tx!.syncStatus, equals(SyncStatus.synced));
      });
    });

    group('getTotalByCategory', () {
      test('should return category totals', () async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: now,
        );
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 30,
          date: now,
        );

        final result = await repository.getTotalByCategory(
          startOfMonth,
          endOfMonth,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (stats) {
            expect(stats.length, equals(1));
            expect(stats.first.total, equals(80.0));
            expect(stats.first.transactionCount, equals(2));
          },
        );
      });
    });

    group('getMonthlyStatistics', () {
      test('should return monthly breakdown', () async {
        final year = DateTime.now().year;

        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_salary',
          amount: 2000,
          date: DateTime(year, 1, 15),
        );
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 300,
          date: DateTime(year, 1, 20),
        );

        final result = await repository.getMonthlyStatistics(year);

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (stats) {
            expect(stats.length, equals(1));
            expect(stats.first.month, equals(1));
            expect(stats.first.totalIncome, equals(2000.0));
            expect(stats.first.totalExpense, equals(300.0));
            expect(stats.first.balance, equals(1700.0));
          },
        );
      });
    });

    group('getFinancialSummary', () {
      test('should return complete summary', () async {
        final now = DateTime.now();

        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_salary',
          amount: 2000,
          date: now,
        );
        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 500,
          date: now,
        );

        final result = await repository.getFinancialSummary();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (summary) {
            expect(summary.totalIncome, equals(2000.0));
            expect(summary.totalExpense, equals(500.0));
            expect(summary.monthlyIncome, equals(2000.0));
            expect(summary.monthlyExpense, equals(500.0));
          },
        );
      });
    });

    group('watchRecentTransactions', () {
      test('should emit updates when transactions change', () async {
        final stream = repository.watchRecentTransactions(10);

        expectLater(
          stream,
          emitsInOrder([
            hasLength(0),
            hasLength(1),
          ]),
        );

        await repository.createTransaction(
          accountId: accountId,
          categoryId: 'cat_food',
          amount: 50,
          date: DateTime.now(),
        );
      });
    });
  });
}
