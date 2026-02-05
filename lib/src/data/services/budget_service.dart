import 'package:simpleflow/src/data/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service Supabase pour la gestion des budgets utilisateur
class BudgetService {
  BudgetService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Stream de tous les budgets de l'utilisateur
  Stream<List<UserBudget>> watchAllBudgets() {
    return _client
        .from('user_budgets')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at')
        .map((data) => data.map(UserBudget.fromJson).toList());
  }

  /// Crée ou met à jour un budget (upsert)
  Future<UserBudget> upsertBudget({
    required String categoryId,
    required double budgetLimit,
  }) async {
    final response = await _client
        .from('user_budgets')
        .upsert(
          {
            'user_id': _userId,
            'category_id': categoryId,
            'budget_limit': budgetLimit,
          },
          onConflict: 'user_id,category_id',
        )
        .select()
        .single();

    return UserBudget.fromJson(response);
  }

  /// Crée un nouveau budget
  Future<UserBudget> createBudget({
    required String categoryId,
    required double budgetLimit,
  }) async {
    final response = await _client
        .from('user_budgets')
        .insert({
          'user_id': _userId,
          'category_id': categoryId,
          'budget_limit': budgetLimit,
        })
        .select()
        .single();

    return UserBudget.fromJson(response);
  }

  /// Récupère tous les budgets avec les informations de catégorie (jointure)
  Future<List<Map<String, dynamic>>> getBudgetsWithCategories() async {
    final response = await _client
        .from('user_budgets')
        .select('''
          *,
          categories!inner(*)
        ''')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Stream des budgets avec les informations de catégorie
  Stream<List<Map<String, dynamic>>> watchBudgetsWithCategories() {
    // Note: Les streams Supabase ne supportent pas les jointures directement
    // On utilise watchAllBudgets et on fait la jointure côté client
    return watchAllBudgets().asyncMap((budgets) async {
      if (budgets.isEmpty) return [];

      final categoryIds = budgets.map((b) => b.categoryId).toList();

      final categories = await _client
          .from('categories')
          .select()
          .inFilter('id', categoryIds);

      return budgets.map((budget) {
        Map<String, dynamic>? categoryData;
        for (final c in categories) {
          if (c['id'] == budget.categoryId) {
            categoryData = c;
            break;
          }
        }

        return {
          'budget': budget,
          'category':
              categoryData != null ? Category.fromJson(categoryData) : null,
        };
      }).toList();
    });
  }

  /// Supprime un budget par son ID
  Future<void> deleteBudget(String budgetId) async {
    await _client
        .from('user_budgets')
        .delete()
        .eq('id', budgetId)
        .eq('user_id', _userId);
  }

  /// Supprime tous les budgets de l'utilisateur
  Future<void> deleteAllBudgets() async {
    await _client.from('user_budgets').delete().eq('user_id', _userId);
  }
}
