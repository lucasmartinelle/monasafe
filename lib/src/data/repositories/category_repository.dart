import 'package:fpdart/fpdart.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/services/services.dart';

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
  CategoryRepository(this._categoryService);

  final CategoryService _categoryService;

  /// Récupère toutes les catégories
  Future<Either<CategoryError, List<Category>>> getAllCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur lors de la récupération des catégories: $e'));
    }
  }

  /// Stream de toutes les catégories
  Stream<List<Category>> watchAllCategories() {
    return _categoryService.watchAllCategories();
  }

  /// Récupère les catégories de dépenses
  Future<Either<CategoryError, List<Category>>> getExpenseCategories() async {
    try {
      final categories = await _categoryService.getExpenseCategories();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Stream des catégories de dépenses
  Stream<List<Category>> watchExpenseCategories() {
    return _categoryService.watchExpenseCategories();
  }

  /// Récupère les catégories de revenus
  Future<Either<CategoryError, List<Category>>> getIncomeCategories() async {
    try {
      final categories = await _categoryService.getIncomeCategories();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Stream des catégories de revenus
  Stream<List<Category>> watchIncomeCategories() {
    return _categoryService.watchIncomeCategories();
  }

  /// Récupère une catégorie par son ID
  Future<Either<CategoryError, Category>> getCategoryById(String id) async {
    try {
      final category = await _categoryService.getCategoryById(id);
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
      final category = await _categoryService.createCategory(
        name: name,
        iconKey: iconKey,
        color: color,
        type: type,
        budgetLimit: budgetLimit,
      );
      return Right(category);
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
      final existing = await _categoryService.getCategoryById(id);
      if (existing == null) {
        return const Left(CategoryNotFoundError());
      }

      final updated = await _categoryService.updateCategory(
        id: id,
        name: name,
        iconKey: iconKey,
        color: color,
        budgetLimit: budgetLimit,
      );
      return Right(updated);
    } catch (e) {
      return Left(CategoryUpdateError('Erreur: $e'));
    }
  }

  /// Supprime une catégorie personnalisée
  Future<Either<CategoryError, Unit>> deleteCategory(String id) async {
    try {
      final existing = await _categoryService.getCategoryById(id);
      if (existing == null) {
        return const Left(CategoryNotFoundError());
      }

      // Vérifie si c'est une catégorie par défaut
      if (existing.isDefault) {
        return const Left(CategoryIsDefaultError());
      }

      await _categoryService.deleteCategory(id);
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
      await _categoryService.updateBudgetLimit(id, limit);
      return const Right(unit);
    } catch (e) {
      return Left(CategoryUpdateError('Erreur: $e'));
    }
  }

  /// Récupère les catégories avec une limite de budget
  Future<Either<CategoryError, List<Category>>> getCategoriesWithBudget() async {
    try {
      final categories = await _categoryService.getCategoriesWithBudget();
      return Right(categories);
    } catch (e) {
      return Left(CategoryFetchError('Erreur: $e'));
    }
  }

  /// Vérifie si une catégorie est une catégorie par défaut
  Future<bool> isDefaultCategory(String id) async {
    final category = await _categoryService.getCategoryById(id);
    return category?.isDefault ?? false;
  }
}
