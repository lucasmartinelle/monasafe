import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('TransactionDao', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
      // Créer un compte pour les transactions
      await db.accountDao.createAccount(createTestAccount(id: 'acc-1'));
      await db.accountDao.createAccount(createTestAccount(id: 'acc-2'));
    });

    tearDown(() async {
      await db.close();
    });

    group('createTransaction', () {
      test('should create transaction successfully', () async {
        final transaction = createTestTransaction(
          id: 'tx-1',
          accountId: 'acc-1',
          amount: 25.50,
        );

        await db.transactionDao.createTransaction(transaction);

        final tx = await db.transactionDao.getTransactionById('tx-1');
        expect(tx, isNot(equals(null)));
        expect(tx!.amount, equals(25.50));
        expect(tx.accountId, equals('acc-1'));
        expect(tx.categoryId, equals('cat_food'));
      });

      test('should set default sync status to pending', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );

        final tx = await db.transactionDao.getTransactionById('tx-1');
        expect(tx!.syncStatus, equals(SyncStatus.pending));
      });
    });

    group('createTransactions (batch)', () {
      test('should create multiple transactions in batch', () async {
        final transactions = [
          createTestTransaction(id: 'tx-1', accountId: 'acc-1', amount: 10),
          createTestTransaction(id: 'tx-2', accountId: 'acc-1', amount: 20),
          createTestTransaction(id: 'tx-3', accountId: 'acc-1', amount: 30),
        ];

        await db.transactionDao.createTransactions(transactions);

        final count = await db.transactionDao.countTransactions();
        expect(count, equals(3));
      });
    });

    group('getTransactionById', () {
      test('should return transaction when exists', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );

        final tx = await db.transactionDao.getTransactionById('tx-1');
        expect(tx, isNot(equals(null)));
        expect(tx!.id, equals('tx-1'));
      });

      test('should return null when not found', () async {
        final tx = await db.transactionDao.getTransactionById('non-existent');
        expect(tx, equals(null));
      });
    });

    group('getAllTransactionsWithDetails', () {
      test('should return transactions with account and category', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: 'acc-1',
          ),
        );

        final transactions = await db.transactionDao.getAllTransactionsWithDetails();

        expect(transactions.length, equals(1));
        expect(transactions.first.transaction.id, equals('tx-1'));
        expect(transactions.first.account.id, equals('acc-1'));
        expect(transactions.first.category.id, equals('cat_food'));
        expect(transactions.first.category.name, equals('Alimentation'));
      });

      test('should return transactions sorted by date descending', () async {
        final now = DateTime.now();

        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-old',
            accountId: 'acc-1',
            date: now.subtract(const Duration(days: 10)),
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-new',
            accountId: 'acc-1',
            date: now,
          ),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-mid',
            accountId: 'acc-1',
            date: now.subtract(const Duration(days: 5)),
          ),
        );

        final transactions = await db.transactionDao.getAllTransactionsWithDetails();

        expect(transactions[0].transaction.id, equals('tx-new'));
        expect(transactions[1].transaction.id, equals('tx-mid'));
        expect(transactions[2].transaction.id, equals('tx-old'));
      });
    });

    group('getTransactionsByAccountAndPeriod', () {
      test('should filter by account and date range', () async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        // Transaction dans la période pour acc-1
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: 'acc-1',
            date: now,
          ),
        );

        // Transaction hors période
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-2',
            accountId: 'acc-1',
            date: now.subtract(const Duration(days: 60)),
          ),
        );

        // Transaction pour un autre compte
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-3',
            accountId: 'acc-2',
            date: now,
          ),
        );

        final transactions = await db.transactionDao.getTransactionsByAccountAndPeriod(
          'acc-1',
          startOfMonth,
          endOfMonth,
        );

        expect(transactions.length, equals(1));
        expect(transactions.first.transaction.id, equals('tx-1'));
      });
    });

    group('getRecentTransactions', () {
      test('should return limited number of transactions', () async {
        // Créer 10 transactions
        for (var i = 0; i < 10; i++) {
          await db.transactionDao.createTransaction(
            createTestTransaction(
              id: 'tx-$i',
              accountId: 'acc-1',
              date: DateTime.now().subtract(Duration(days: i)),
            ),
          );
        }

        final recent = await db.transactionDao.getRecentTransactions(5);
        expect(recent.length, equals(5));
      });
    });

    group('updateTransaction', () {
      test('should update transaction amount', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1', amount: 100),
        );

        final success = await db.transactionDao.updateTransaction(
          TransactionsCompanion(
            id: const Value('tx-1'),
            amount: const Value(200),
            updatedAt: Value(DateTime.now()),
          ),
        );

        expect(success, isTrue);

        final updated = await db.transactionDao.getTransactionById('tx-1');
        expect(updated!.amount, equals(200.0));
      });
    });

    group('deleteTransaction', () {
      test('should delete transaction', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );

        final deleted = await db.transactionDao.deleteTransaction('tx-1');
        expect(deleted, equals(1));

        final tx = await db.transactionDao.getTransactionById('tx-1');
        expect(tx, equals(null));
      });
    });

    group('getPendingTransactions', () {
      test('should return only pending transactions', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-2', accountId: 'acc-1'),
        );

        // Marquer une comme synchronisée
        await db.transactionDao.markAsSynced('tx-1');

        final pending = await db.transactionDao.getPendingTransactions();
        expect(pending.length, equals(1));
        expect(pending.first.id, equals('tx-2'));
      });
    });

    group('markAsSynced', () {
      test('should update sync status to synced', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );

        await db.transactionDao.markAsSynced('tx-1');

        final tx = await db.transactionDao.getTransactionById('tx-1');
        expect(tx!.syncStatus, equals(SyncStatus.synced));
      });
    });

    group('markMultipleAsSynced', () {
      test('should mark multiple transactions as synced', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-2', accountId: 'acc-1'),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-3', accountId: 'acc-1'),
        );

        await db.transactionDao.markMultipleAsSynced(['tx-1', 'tx-2']);

        final pending = await db.transactionDao.getPendingTransactions();
        expect(pending.length, equals(1));
        expect(pending.first.id, equals('tx-3'));
      });
    });

    group('countTransactions', () {
      test('should return correct count', () async {
        expect(await db.transactionDao.countTransactions(), equals(0));

        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );
        expect(await db.transactionDao.countTransactions(), equals(1));
      });
    });

    group('countTransactionsByAccount', () {
      test('should count only transactions for specific account', () async {
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-1', accountId: 'acc-1'),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-2', accountId: 'acc-1'),
        );
        await db.transactionDao.createTransaction(
          createTestTransaction(id: 'tx-3', accountId: 'acc-2'),
        );

        expect(await db.transactionDao.countTransactionsByAccount('acc-1'), equals(2));
        expect(await db.transactionDao.countTransactionsByAccount('acc-2'), equals(1));
      });
    });
  });
}
