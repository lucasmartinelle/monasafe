import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/repositories/account_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  group('AccountRepository', () {
    late AppDatabase db;
    late AccountRepository repository;

    setUp(() async {
      db = createTestDatabase();
      repository = AccountRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('createAccount', () {
      test('should create account and return Right with account', () async {
        final result = await repository.createAccount(
          name: 'Mon Compte',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (account) {
            expect(account.name, equals('Mon Compte'));
            expect(account.type, equals(AccountType.checking));
            expect(account.balance, equals(1000.0));
            expect(account.currency, equals('EUR'));
            expect(account.id, isNotEmpty);
          },
        );
      });

      test('should generate unique UUID for each account', () async {
        final result1 = await repository.createAccount(
          name: 'Compte 1',
          type: AccountType.checking,
          initialBalance: 100,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );

        final result2 = await repository.createAccount(
          name: 'Compte 2',
          type: AccountType.savings,
          initialBalance: 200,
          currency: 'EUR',
          color: 0xFF2196F3,
        );

        final id1 = result1.getOrElse((l) => throw l).id;
        final id2 = result2.getOrElse((l) => throw l).id;

        expect(id1, isNot(equals(id2)));
      });
    });

    group('getAllAccounts', () {
      test('should return empty list when no accounts', () async {
        final result = await repository.getAllAccounts();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (accounts) => expect(accounts, isEmpty),
        );
      });

      test('should return all created accounts', () async {
        await repository.createAccount(
          name: 'Compte 1',
          type: AccountType.checking,
          initialBalance: 100,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        await repository.createAccount(
          name: 'Compte 2',
          type: AccountType.savings,
          initialBalance: 200,
          currency: 'EUR',
          color: 0xFF2196F3,
        );

        final result = await repository.getAllAccounts();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (accounts) => expect(accounts.length, equals(2)),
        );
      });
    });

    group('getAccountById', () {
      test('should return Right with account when exists', () async {
        final created = await repository.createAccount(
          name: 'Mon Compte',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        final result = await repository.getAccountById(accountId);

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (account) => expect(account.name, equals('Mon Compte')),
        );
      });

      test('should return Left with AccountNotFoundError when not exists', () async {
        final result = await repository.getAccountById('non-existent');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<AccountNotFoundError>()),
          (account) => fail('Should be an error'),
        );
      });
    });

    group('updateAccount', () {
      test('should update account name', () async {
        final created = await repository.createAccount(
          name: 'Ancien Nom',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        final result = await repository.updateAccount(
          id: accountId,
          name: 'Nouveau Nom',
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (account) => expect(account.name, equals('Nouveau Nom')),
        );
      });

      test('should return Left when account not found', () async {
        final result = await repository.updateAccount(
          id: 'non-existent',
          name: 'Test',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<AccountNotFoundError>()),
          (account) => fail('Should be an error'),
        );
      });

      test('should only update specified fields', () async {
        final created = await repository.createAccount(
          name: 'Mon Compte',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        final result = await repository.updateAccount(
          id: accountId,
          balance: 2000,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (account) {
            expect(account.name, equals('Mon Compte')); // Unchanged
            expect(account.balance, equals(2000.0)); // Updated
          },
        );
      });
    });

    group('deleteAccount', () {
      test('should delete account successfully', () async {
        final created = await repository.createAccount(
          name: 'À Supprimer',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        final result = await repository.deleteAccount(accountId);

        expect(result.isRight(), isTrue);

        // Vérifier que le compte n'existe plus
        final getResult = await repository.getAccountById(accountId);
        expect(getResult.isLeft(), isTrue);
      });

      test('should return Left when account not found', () async {
        final result = await repository.deleteAccount('non-existent');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<AccountNotFoundError>()),
          (_) => fail('Should be an error'),
        );
      });

      test('should return Left when account has transactions', () async {
        // Créer un compte
        final created = await repository.createAccount(
          name: 'Compte avec Transactions',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        // Ajouter une transaction
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-1',
            accountId: accountId,
          ),
        );

        // Essayer de supprimer
        final result = await repository.deleteAccount(accountId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<AccountHasTransactionsError>()),
          (_) => fail('Should be an error'),
        );
      });
    });

    group('getCalculatedBalance', () {
      test('should return initial balance when no transactions', () async {
        final created = await repository.createAccount(
          name: 'Mon Compte',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        final result = await repository.getCalculatedBalance(accountId);

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (balance) => expect(balance, equals(1000.0)),
        );
      });

      test('should calculate balance with transactions', () async {
        final created = await repository.createAccount(
          name: 'Mon Compte',
          type: AccountType.checking,
          initialBalance: 1000,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );
        final accountId = created.getOrElse((l) => throw l).id;

        // Ajouter un revenu
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-income',
            accountId: accountId,
            categoryId: 'cat_salary',
            amount: 500,
          ),
        );

        // Ajouter une dépense
        await db.transactionDao.createTransaction(
          createTestTransaction(
            id: 'tx-expense',
            accountId: accountId,
            amount: 200,
          ),
        );

        final result = await repository.getCalculatedBalance(accountId);

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (balance) => expect(balance, equals(1300.0)), // 1000 + 500 - 200
        );
      });
    });

    group('watchAllAccounts', () {
      test('should emit updates when accounts change', () async {
        // Vérifie l'état initial
        final initial = await repository.watchAllAccounts().first;
        expect(initial, hasLength(0));

        // Crée un compte et vérifie la mise à jour
        await repository.createAccount(
          name: 'Nouveau Compte',
          type: AccountType.checking,
          initialBalance: 100,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );

        final afterCreate = await repository.watchAllAccounts().first;
        expect(afterCreate, hasLength(1));
      });
    });

    group('countAccounts', () {
      test('should return correct count', () async {
        expect(await repository.countAccounts(), equals(0));

        await repository.createAccount(
          name: 'Compte 1',
          type: AccountType.checking,
          initialBalance: 100,
          currency: 'EUR',
          color: 0xFF4CAF50,
        );

        expect(await repository.countAccounts(), equals(1));
      });
    });
  });
}
