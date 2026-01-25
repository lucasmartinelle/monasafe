import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/database.dart';

import '../../helpers/test_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('should create database successfully', () {
      expect(db, isNot(equals(null)));
      expect(db.schemaVersion, equals(1));
    });

    test('should seed default categories on creation', () async {
      final categories = await db.categoryDao.getAllCategories();

      // 7 dépenses + 5 revenus = 12 catégories par défaut
      expect(categories.length, equals(12));
    });

    test('should have expense categories', () async {
      final expenseCategories = await db.categoryDao.getExpenseCategories();

      expect(expenseCategories.length, equals(7));
      expect(
        expenseCategories.map((c) => c.name),
        containsAll([
          'Alimentation',
          'Transport',
          'Shopping',
          'Loisirs',
          'Santé',
          'Factures',
          'Autres dépenses',
        ]),
      );
    });

    test('should have income categories', () async {
      final incomeCategories = await db.categoryDao.getIncomeCategories();

      expect(incomeCategories.length, equals(5));
      expect(
        incomeCategories.map((c) => c.name),
        containsAll([
          'Salaire',
          'Freelance',
          'Investissements',
          'Cadeaux',
          'Autres revenus',
        ]),
      );
    });

    test('should enforce foreign key constraints', () async {
      // Essayer de créer une transaction avec un compte inexistant
      final transaction = createTestTransaction(
        accountId: 'non-existent-account',
      );

      expect(
        () => db.transactionDao.createTransaction(transaction),
        throwsA(isA<Exception>()),
      );
    });
  });
}
