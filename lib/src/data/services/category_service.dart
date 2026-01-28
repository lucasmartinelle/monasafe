import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:simpleflow/src/data/models/models.dart';

/// Service Supabase pour la gestion des catégories
class CategoryService {
  CategoryService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Récupère toutes les catégories (par défaut + personnalisées)
  Future<List<Category>> getAllCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .or('user_id.eq.$_userId,user_id.is.null')
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream de toutes les catégories
  Stream<List<Category>> watchAllCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data
            .where((json) => json['user_id'] == _userId || json['user_id'] == null)
            .map((json) => Category.fromJson(json))
            .toList());
  }

  /// Récupère les catégories de dépenses
  Future<List<Category>> getExpenseCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .or('user_id.eq.$_userId,user_id.is.null')
        .eq('type', CategoryType.expense.name)
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream des catégories de dépenses
  Stream<List<Category>> watchExpenseCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .eq('type', CategoryType.expense.name)
        .order('name')
        .map((data) => data
            .where((json) => json['user_id'] == _userId || json['user_id'] == null)
            .map((json) => Category.fromJson(json))
            .toList());
  }

  /// Récupère les catégories de revenus
  Future<List<Category>> getIncomeCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .or('user_id.eq.$_userId,user_id.is.null')
        .eq('type', CategoryType.income.name)
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream des catégories de revenus
  Stream<List<Category>> watchIncomeCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .eq('type', CategoryType.income.name)
        .order('name')
        .map((data) => data
            .where((json) => json['user_id'] == _userId || json['user_id'] == null)
            .map((json) => Category.fromJson(json))
            .toList());
  }

  /// Récupère une catégorie par son ID
  Future<Category?> getCategoryById(String id) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Category.fromJson(response);
  }

  /// Crée une nouvelle catégorie personnalisée
  Future<Category> createCategory({
    required String name,
    required String iconKey,
    required int color,
    required CategoryType type,
    double? budgetLimit,
  }) async {
    final now = DateTime.now().toIso8601String();
    final data = {
      'user_id': _userId,
      'name': name,
      'icon_key': iconKey,
      'color': color,
      'type': type.name,
      'budget_limit': budgetLimit,
      'is_default': false,
      'created_at': now,
      'updated_at': now,
    };

    final response = await _client
        .from('categories')
        .insert(data)
        .select()
        .single();

    return Category.fromJson(response);
  }

  /// Met à jour une catégorie existante
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? iconKey,
    int? color,
    double? budgetLimit,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) data['name'] = name;
    if (iconKey != null) data['icon_key'] = iconKey;
    if (color != null) data['color'] = color;
    if (budgetLimit != null) data['budget_limit'] = budgetLimit;

    final response = await _client
        .from('categories')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return Category.fromJson(response);
  }

  /// Supprime une catégorie personnalisée
  Future<void> deleteCategory(String id) async {
    await _client
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId)
        .eq('is_default', false);
  }

  /// Met à jour la limite de budget d'une catégorie
  /// Note: Pour les catégories par défaut (user_id IS NULL), cela modifie
  /// la catégorie partagée. Pour une gestion per-user des budgets sur les
  /// catégories par défaut, il faudrait une table séparée user_budgets.
  Future<void> updateBudgetLimit(String id, double? limit) async {
    await _client
        .from('categories')
        .update({
          'budget_limit': limit,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .or('user_id.eq.$_userId,user_id.is.null');
  }

  /// Récupère les catégories avec une limite de budget
  Future<List<Category>> getCategoriesWithBudget() async {
    final response = await _client
        .from('categories')
        .select()
        .or('user_id.eq.$_userId,user_id.is.null')
        .not('budget_limit', 'is', null)
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream des catégories avec limite de budget
  Stream<List<Category>> watchCategoriesWithBudget() {
    return watchAllCategories().map(
      (categories) => categories.where((c) => c.budgetLimit != null).toList(),
    );
  }
}
