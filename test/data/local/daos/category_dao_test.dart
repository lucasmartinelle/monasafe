import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('CategoryDao', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    group('getAllCategories', () {
      test('should return all default categories', () async {
        final categories = await db.categoryDao.getAllCategories();

        expect(categories.length, equals(12));
      });

      test('should return categories sorted by name', () async {
        final categories = await db.categoryDao.getAllCategories();

        // Vérifie que c'est trié alphabétiquement
        for (var i = 0; i < categories.length - 1; i++) {
          expect(
            categories[i].name.compareTo(categories[i + 1].name) <= 0,
            isTrue,
            reason: '${categories[i].name} should come before ${categories[i + 1].name}',
          );
        }
      });
    });

    group('getExpenseCategories', () {
      test('should return only expense categories', () async {
        final categories = await db.categoryDao.getExpenseCategories();

        expect(categories.length, equals(7));
        expect(
          categories.every((c) => c.type == CategoryType.expense),
          isTrue,
        );
      });
    });

    group('getIncomeCategories', () {
      test('should return only income categories', () async {
        final categories = await db.categoryDao.getIncomeCategories();

        expect(categories.length, equals(5));
        expect(
          categories.every((c) => c.type == CategoryType.income),
          isTrue,
        );
      });
    });

    group('getCategoryById', () {
      test('should return category when exists', () async {
        final category = await db.categoryDao.getCategoryById('cat_food');

        expect(category, isNot(equals(null)));
        expect(category!.name, equals('Alimentation'));
        expect(category.type, equals(CategoryType.expense));
      });

      test('should return null when category does not exist', () async {
        final category = await db.categoryDao.getCategoryById('non-existent');
        expect(category, equals(null));
      });
    });

    group('createCategory', () {
      test('should create custom category', () async {
        final customCategory = CategoriesCompanion.insert(
          id: 'custom-cat-1',
          name: 'Ma Catégorie',
          iconKey: 'custom',
          color: 0xFF123456,
          type: CategoryType.expense,
        );

        await db.categoryDao.createCategory(customCategory);

        final created = await db.categoryDao.getCategoryById('custom-cat-1');
        expect(created, isNot(equals(null)));
        expect(created!.name, equals('Ma Catégorie'));
      });
    });

    group('updateCategory', () {
      test('should update category name', () async {
        final success = await db.categoryDao.updateCategory(
          CategoriesCompanion(
            id: const Value('cat_food'),
            name: const Value('Nourriture'),
            updatedAt: Value(DateTime.now()),
          ),
        );

        expect(success, isTrue);

        final updated = await db.categoryDao.getCategoryById('cat_food');
        expect(updated!.name, equals('Nourriture'));
      });
    });

    group('deleteCategory', () {
      test('should delete custom category', () async {
        // Créer une catégorie personnalisée
        await db.categoryDao.createCategory(
          CategoriesCompanion.insert(
            id: 'to-delete',
            name: 'À Supprimer',
            iconKey: 'delete',
            color: 0xFFFF0000,
            type: CategoryType.expense,
          ),
        );

        final deleted = await db.categoryDao.deleteCategory('to-delete');
        expect(deleted, equals(1));

        final category = await db.categoryDao.getCategoryById('to-delete');
        expect(category, equals(null));
      });
    });

    group('updateBudgetLimit', () {
      test('should set budget limit', () async {
        await db.categoryDao.updateBudgetLimit('cat_food', 500);

        final category = await db.categoryDao.getCategoryById('cat_food');
        expect(category!.budgetLimit, equals(500.0));
      });

      test('should clear budget limit when set to null', () async {
        // D'abord définir une limite
        await db.categoryDao.updateBudgetLimit('cat_food', 500);

        // Puis la supprimer
        await db.categoryDao.updateBudgetLimit('cat_food', null);

        final category = await db.categoryDao.getCategoryById('cat_food');
        expect(category!.budgetLimit, equals(null));
      });
    });

    group('getCategoriesWithBudget', () {
      test('should return only categories with budget set', () async {
        // Par défaut, aucune catégorie n'a de budget
        var categories = await db.categoryDao.getCategoriesWithBudget();
        expect(categories, isEmpty);

        // Définir des budgets
        await db.categoryDao.updateBudgetLimit('cat_food', 300);
        await db.categoryDao.updateBudgetLimit('cat_transport', 150);

        categories = await db.categoryDao.getCategoriesWithBudget();
        expect(categories.length, equals(2));
        expect(
          categories.map((c) => c.id),
          containsAll(['cat_food', 'cat_transport']),
        );
      });
    });

    group('watchAllCategories', () {
      test('should emit updates when categories change', () async {
        // Vérifie les catégories par défaut
        final initial = await db.categoryDao.watchAllCategories().first;
        expect(initial, hasLength(12));

        // Ajoute une catégorie et vérifie la mise à jour
        await db.categoryDao.createCategory(
          CategoriesCompanion.insert(
            id: 'new-cat',
            name: 'Nouvelle',
            iconKey: 'new',
            color: 0xFF000000,
            type: CategoryType.expense,
          ),
        );

        final afterAdd = await db.categoryDao.watchAllCategories().first;
        expect(afterAdd, hasLength(13));
      });
    });
  });
}
