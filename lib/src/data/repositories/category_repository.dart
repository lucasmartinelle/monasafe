import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:uuid/uuid.dart';

/// Erreurs possibles lors des opérations sur les catégories
sealed class CategoryError {
  const CategoryError(this.message);
  final String message;
}

class CategoryNotFoundError extends CategoryError {
  const CategoryNotFoundError() : super('Catégorie non trouvée');
}

class CategoryCreationError extends CategoryError {
  const CategoryCreationError(super.message);
}

class CategoryUpdateError extends CategoryError {
  const CategoryUpdateError(super.message);
}

class CategoryDeletionError extends CategoryError {
  const CategoryDeletionError(super.message);
}

class CategoryIsDefaultError extends CategoryError {
  const CategoryIsDefaultError()
      : super('Les catégories par défaut ne peuvent pas être supprimées');
}

class CategoryFetchError extends CategoryError {
  const CategoryFetchError(super.message);
}

/// Repository pour la gestion des catégories
class CategoryRepository {

  CategoryRepository(this._db);
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  /// Liste des IDs des catégories par défaut (non supprimables)
  static const defaultCategoryIds = [
    'cat_food',
    'cat_transport',
    'cat_shopping',
    'cat_entertainment',
    'cat_health',
    'cat_bills',
    'cat_other_expense',
    'cat_salary',
    'cat_freelance',
    'cat_investment',
    'cat_gift',
    'cat_other_income',
  ];

  /// Récupère toutes les catégories
  Future<Either<CategoryError, List<Category>>> getAllCategories() async {
    try {
      final categories = await _db.categoryDao.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur lors de la récupération des catégories: $e'));
    }
  }

  /// Stream de toutes les catégories
  Stream<List<Category>> watchAllCategories() {
    return _db.categoryDao.watchAllCategories();
  }

  /// Récupère les catégories de dépenses
  Future<Either<CategoryError, List<Category>>> getExpenseCategories() async {
    try {
      final categories = await _db.categoryDao.getExpenseCategories();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Stream des catégories de dépenses
  Stream<List<Category>> watchExpenseCategories() {
    return _db.categoryDao.watchExpenseCategories();
  }

  /// Récupère les catégories de revenus
  Future<Either<CategoryError, List<Category>>> getIncomeCategories() async {
    try {
      final categories = await _db.categoryDao.getIncomeCategories();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Stream des catégories de revenus
  Stream<List<Category>> watchIncomeCategories() {
    return _db.categoryDao.watchIncomeCategories();
  }

  /// Récupère une catégorie par son ID
  Future<Either<CategoryError, Category>> getCategoryById(String id) async {
    try {
      final category = await _db.categoryDao.getCategoryById(id);
      if (category == null) {
        return const Left(CategoryNotFoundError());
      }
      return Right(category);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Crée une nouvelle catégorie personnalisée
  Future<Either<CategoryError, Category>> createCategory({
    required String name,
    required String iconKey,
    required int color,
    required CategoryType type,
    double? budgetLimit,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();

      final companion = CategoriesCompanion.insert(
        id: id,
        name: name,
        iconKey: iconKey,
        color: color,
        type: type,
        budgetLimit: Value(budgetLimit),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await _db.categoryDao.createCategory(companion);

      final created = await _db.categoryDao.getCategoryById(id);
      if (created == null) {
        return const Left(CategoryCreationError('Échec de la création'));
      }

      return Right(created);
    } catch (e) {
      return Left(CategoryCreationError('Erreur: $e'));
    }
  }

  /// Met à jour une catégorie existante
  Future<Either<CategoryError, Category>> updateCategory({
    required String id,
    String? name,
    String? iconKey,
    int? color,
    double? budgetLimit,
  }) async {
    try {
      final existing = await _db.categoryDao.getCategoryById(id);
      if (existing == null) {
        return const Left(CategoryNotFoundError());
      }

      final companion = CategoriesCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        iconKey: iconKey != null ? Value(iconKey) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        budgetLimit: budgetLimit != null ? Value(budgetLimit) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final success = await _db.categoryDao.updateCategory(companion);
      if (!success) {
        return const Left(CategoryUpdateError('Échec de la mise à jour'));
      }

      final updated = await _db.categoryDao.getCategoryById(id);
      return Right(updated!);
    } catch (e) {
      return Left(CategoryUpdateError('Erreur: $e'));
    }
  }

  /// Supprime une catégorie personnalisée
  Future<Either<CategoryError, Unit>> deleteCategory(String id) async {
    try {
      // Vérifie si c'est une catégorie par défaut
      if (defaultCategoryIds.contains(id)) {
        return const Left(CategoryIsDefaultError());
      }

      final existing = await _db.categoryDao.getCategoryById(id);
      if (existing == null) {
        return const Left(CategoryNotFoundError());
      }

      await _db.categoryDao.deleteCategory(id);
      return const Right(unit);
    } catch (e) {
      return Left(CategoryDeletionError('Erreur: $e'));
    }
  }

  /// Met à jour la limite de budget d'une catégorie (Premium)
  Future<Either<CategoryError, Unit>> updateBudgetLimit(
    String id,
    double? limit,
  ) async {
    try {
      await _db.categoryDao.updateBudgetLimit(id, limit);
      return const Right(unit);
    } catch (e) {
      return Left(CategoryUpdateError('Erreur: $e'));
    }
  }

  /// Récupère les catégories avec une limite de budget
  Future<Either<CategoryError, List<Category>>> getCategoriesWithBudget() async {
    try {
      final categories = await _db.categoryDao.getCategoriesWithBudget();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Vérifie si une catégorie est une catégorie par défaut
  bool isDefaultCategory(String id) {
    return defaultCategoryIds.contains(id);
  }
}
