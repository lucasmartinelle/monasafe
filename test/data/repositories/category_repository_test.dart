import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/repositories/category_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  group('CategoryRepository', () {
    late AppDatabase db;
    late CategoryRepository repository;

    setUp(() async {
      db = createTestDatabase();
      repository = CategoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('getAllCategories', () {
      test('should return all default categories', () async {
        final result = await repository.getAllCategories();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (categories) => expect(categories.length, equals(12)),
        );
      });
    });

    group('getExpenseCategories', () {
      test('should return only expense categories', () async {
        final result = await repository.getExpenseCategories();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (categories) {
            expect(categories.length, equals(7));
            expect(
              categories.every((c) => c.type == CategoryType.expense),
              isTrue,
            );
          },
        );
      });
    });

    group('getIncomeCategories', () {
      test('should return only income categories', () async {
        final result = await repository.getIncomeCategories();

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (categories) {
            expect(categories.length, equals(5));
            expect(
              categories.every((c) => c.type == CategoryType.income),
              isTrue,
            );
          },
        );
      });
    });

    group('getCategoryById', () {
      test('should return category when exists', () async {
        final result = await repository.getCategoryById('cat_food');

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (category) {
            expect(category.name, equals('Alimentation'));
            expect(category.type, equals(CategoryType.expense));
          },
        );
      });

      test('should return Left when category not found', () async {
        final result = await repository.getCategoryById('non-existent');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CategoryNotFoundError>()),
          (category) => fail('Should be an error'),
        );
      });
    });

    group('createCategory', () {
      test('should create custom category', () async {
        final result = await repository.createCategory(
          name: 'Ma Catégorie',
          iconKey: 'custom',
          color: 0xFF123456,
          type: CategoryType.expense,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (category) {
            expect(category.name, equals('Ma Catégorie'));
            expect(category.iconKey, equals('custom'));
            expect(category.color, equals(0xFF123456));
            expect(category.type, equals(CategoryType.expense));
            expect(category.id, isNotEmpty);
          },
        );
      });

      test('should create category with budget limit', () async {
        final result = await repository.createCategory(
          name: 'Avec Budget',
          iconKey: 'budget',
          color: 0xFF654321,
          type: CategoryType.expense,
          budgetLimit: 500,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (category) => expect(category.budgetLimit, equals(500.0)),
        );
      });
    });

    group('updateCategory', () {
      test('should update category name', () async {
        // Créer une catégorie personnalisée
        final created = await repository.createCategory(
          name: 'Ancien Nom',
          iconKey: 'custom',
          color: 0xFF123456,
          type: CategoryType.expense,
        );
        final categoryId = created.getOrElse((l) => throw l).id;

        final result = await repository.updateCategory(
          id: categoryId,
          name: 'Nouveau Nom',
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not be an error'),
          (category) => expect(category.name, equals('Nouveau Nom')),
        );
      });

      test('should return Left when category not found', () async {
        final result = await repository.updateCategory(
          id: 'non-existent',
          name: 'Test',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CategoryNotFoundError>()),
          (category) => fail('Should be an error'),
        );
      });
    });

    group('deleteCategory', () {
      test('should delete custom category', () async {
        // Créer une catégorie personnalisée
        final created = await repository.createCategory(
          name: 'À Supprimer',
          iconKey: 'delete',
          color: 0xFFFF0000,
          type: CategoryType.expense,
        );
        final categoryId = created.getOrElse((l) => throw l).id;

        final result = await repository.deleteCategory(categoryId);

        expect(result.isRight(), isTrue);

        // Vérifier que la catégorie n'existe plus
        final getResult = await repository.getCategoryById(categoryId);
        expect(getResult.isLeft(), isTrue);
      });

      test('should return Left when trying to delete default category', () async {
        final result = await repository.deleteCategory('cat_food');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CategoryIsDefaultError>()),
          (_) => fail('Should be an error'),
        );
      });

      test('should return Left when category not found', () async {
        final result = await repository.deleteCategory('non-existent');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<CategoryNotFoundError>()),
          (_) => fail('Should be an error'),
        );
      });
    });

    group('updateBudgetLimit', () {
      test('should set budget limit', () async {
        final result = await repository.updateBudgetLimit('cat_food', 300);

        expect(result.isRight(), isTrue);

        final category = await repository.getCategoryById('cat_food');
        category.fold(
          (error) => fail('Should not be an error'),
          (c) => expect(c.budgetLimit, equals(300.0)),
        );
      });

      test('should clear budget limit', () async {
        // D'abord définir une limite
        await repository.updateBudgetLimit('cat_food', 300);

        // Puis la supprimer
        final result = await repository.updateBudgetLimit('cat_food', null);

        expect(result.isRight(), isTrue);

        final category = await repository.getCategoryById('cat_food');
        category.fold(
          (error) => fail('Should not be an error'),
          (c) => expect(c.budgetLimit, equals(null)),
        );
      });
    });

    group('getCategoriesWithBudget', () {
      test('should return only categories with budget', () async {
        // Par défaut, aucune catégorie n'a de budget
        var result = await repository.getCategoriesWithBudget();
        result.fold(
          (error) => fail('Should not be an error'),
          (categories) => expect(categories, isEmpty),
        );

        // Définir des budgets
        await repository.updateBudgetLimit('cat_food', 300);
        await repository.updateBudgetLimit('cat_transport', 150);

        result = await repository.getCategoriesWithBudget();
        result.fold(
          (error) => fail('Should not be an error'),
          (categories) {
            expect(categories.length, equals(2));
            expect(
              categories.map((c) => c.id),
              containsAll(['cat_food', 'cat_transport']),
            );
          },
        );
      });
    });

    group('isDefaultCategory', () {
      test('should return true for default categories', () {
        expect(repository.isDefaultCategory('cat_food'), isTrue);
        expect(repository.isDefaultCategory('cat_salary'), isTrue);
        expect(repository.isDefaultCategory('cat_transport'), isTrue);
      });

      test('should return false for custom categories', () {
        expect(repository.isDefaultCategory('custom-cat'), isFalse);
        expect(repository.isDefaultCategory('my-category'), isFalse);
      });
    });

    group('watchAllCategories', () {
      test('should emit updates when categories change', () async {
        // Vérifie les catégories par défaut
        final initial = await repository.watchAllCategories().first;
        expect(initial, hasLength(12));

        // Ajoute une catégorie et vérifie la mise à jour
        await repository.createCategory(
          name: 'Nouvelle',
          iconKey: 'new',
          color: 0xFF000000,
          type: CategoryType.expense,
        );

        final afterCreate = await repository.watchAllCategories().first;
        expect(afterCreate, hasLength(13));
      });
    });
  });
}
