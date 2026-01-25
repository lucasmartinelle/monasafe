import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/database.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('AccountDao', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    group('createAccount', () {
      test('should create account successfully', () async {
        final account = createTestAccount();
        await db.accountDao.createAccount(account);

        final accounts = await db.accountDao.getAllAccounts();
        expect(accounts.length, equals(1));
        expect(accounts.first.name, equals('Compte Test'));
        expect(accounts.first.balance, equals(1000.0));
        expect(accounts.first.currency, equals('EUR'));
      });

      test('should create multiple accounts', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'acc-1', name: 'Compte 1'));
        await db.accountDao.createAccount(createTestAccount(id: 'acc-2', name: 'Compte 2'));
        await db.accountDao.createAccount(createTestAccount(id: 'acc-3', name: 'Compte 3'));

        final accounts = await db.accountDao.getAllAccounts();
        expect(accounts.length, equals(3));
      });
    });

    group('getAccountById', () {
      test('should return account when exists', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'my-account'));

        final account = await db.accountDao.getAccountById('my-account');
        expect(account, isNot(equals(null)));
        expect(account!.id, equals('my-account'));
      });

      test('should return null when account does not exist', () async {
        final account = await db.accountDao.getAccountById('non-existent');
        expect(account, equals(null));
      });
    });

    group('updateAccount', () {
      test('should update account name', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'acc-1'));

        final success = await db.accountDao.updateAccount(
          AccountsCompanion(
            id: const Value('acc-1'),
            name: const Value('Nouveau Nom'),
            updatedAt: Value(DateTime.now()),
          ),
        );

        expect(success, isTrue);

        final updated = await db.accountDao.getAccountById('acc-1');
        expect(updated!.name, equals('Nouveau Nom'));
      });

      test('should update account balance', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'acc-1', balance: 100));

        await db.accountDao.updateBalance('acc-1', 500);

        final updated = await db.accountDao.getAccountById('acc-1');
        expect(updated!.balance, equals(500.0));
      });
    });

    group('deleteAccount', () {
      test('should delete account', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'acc-to-delete'));

        final deleted = await db.accountDao.deleteAccount('acc-to-delete');
        expect(deleted, equals(1));

        final account = await db.accountDao.getAccountById('acc-to-delete');
        expect(account, equals(null));
      });

      test('should return 0 when deleting non-existent account', () async {
        final deleted = await db.accountDao.deleteAccount('non-existent');
        expect(deleted, equals(0));
      });
    });

    group('getAllAccounts', () {
      test('should return accounts sorted by name', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'acc-1', name: 'Zéro'));
        await db.accountDao.createAccount(createTestAccount(id: 'acc-2', name: 'Alpha'));
        await db.accountDao.createAccount(createTestAccount(id: 'acc-3', name: 'Beta'));

        final accounts = await db.accountDao.getAllAccounts();

        expect(accounts[0].name, equals('Alpha'));
        expect(accounts[1].name, equals('Beta'));
        expect(accounts[2].name, equals('Zéro'));
      });
    });

    group('watchAllAccounts', () {
      test('should emit updates when accounts change', () async {
        // Vérifie l'état initial
        final initial = await db.accountDao.watchAllAccounts().first;
        expect(initial, hasLength(0));

        // Crée un compte et vérifie la mise à jour
        await db.accountDao.createAccount(createTestAccount(id: 'acc-1'));
        final afterFirst = await db.accountDao.watchAllAccounts().first;
        expect(afterFirst, hasLength(1));

        // Crée un autre compte et vérifie
        await db.accountDao.createAccount(createTestAccount(id: 'acc-2'));
        final afterSecond = await db.accountDao.watchAllAccounts().first;
        expect(afterSecond, hasLength(2));
      });
    });

    group('countAccounts', () {
      test('should return correct count', () async {
        expect(await db.accountDao.countAccounts(), equals(0));

        await db.accountDao.createAccount(createTestAccount(id: 'acc-1'));
        expect(await db.accountDao.countAccounts(), equals(1));

        await db.accountDao.createAccount(createTestAccount(id: 'acc-2'));
        expect(await db.accountDao.countAccounts(), equals(2));
      });
    });

    group('updateLastSyncedAt', () {
      test('should update last synced timestamp', () async {
        await db.accountDao.createAccount(createTestAccount(id: 'acc-1'));

        final before = await db.accountDao.getAccountById('acc-1');
        expect(before!.lastSyncedAt, equals(null));

        await db.accountDao.updateLastSyncedAt('acc-1');

        final after = await db.accountDao.getAccountById('acc-1');
        expect(after!.lastSyncedAt, isNot(equals(null)));
      });
    });
  });
}
