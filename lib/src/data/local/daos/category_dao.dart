import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/local/tables/categories_table.dart';

part 'category_dao.g.dart';

/// DAO pour les opérations CRUD sur les catégories
///
/// Utilise l'index idx_categories_type pour les requêtes filtrées par type
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// Récupère toutes les catégories, triées par nom
  Future<List<Category>> getAllCategories() {
    return (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Stream de toutes les catégories
  Stream<List<Category>> watchAllCategories() {
    return (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Récupère les catégories de type dépense
  /// Utilise idx_categories_type pour un accès O(log n)
  Future<List<Category>> getExpenseCategories() {
    return (select(categories)
          ..where((t) => t.type.equals(CategoryType.expense.index))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Stream des catégories de type dépense
  Stream<List<Category>> watchExpenseCategories() {
    return (select(categories)
          ..where((t) => t.type.equals(CategoryType.expense.index))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Récupère les catégories de type revenu
  /// Utilise idx_categories_type pour un accès O(log n)
  Future<List<Category>> getIncomeCategories() {
    return (select(categories)
          ..where((t) => t.type.equals(CategoryType.income.index))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Stream des catégories de type revenu
  Stream<List<Category>> watchIncomeCategories() {
    return (select(categories)
          ..where((t) => t.type.equals(CategoryType.income.index))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Récupère une catégorie par son ID
  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Crée une nouvelle catégorie
  Future<void> createCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  /// Met à jour une catégorie existante
  Future<bool> updateCategory(CategoriesCompanion category) {
    return (update(categories)..where((t) => t.id.equals(category.id.value)))
        .write(category)
        .then((rows) => rows > 0);
  }

  /// Supprime une catégorie par son ID
  /// Note: Les transactions associées doivent être réassignées avant (contrainte FK)
  Future<int> deleteCategory(String id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  /// Met à jour la limite de budget d'une catégorie (Premium)
  Future<void> updateBudgetLimit(String id, double? limit) {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        budgetLimit: Value(limit),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Récupère les catégories avec une limite de budget définie
  Future<List<Category>> getCategoriesWithBudget() {
    return (select(categories)
          ..where((t) => t.budgetLimit.isNotNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }
}
