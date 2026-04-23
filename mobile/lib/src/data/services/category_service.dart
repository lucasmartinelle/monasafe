import 'package:monasafe/src/data/constants/default_categories.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service Supabase pour la gestion des catégories
class CategoryService {
  CategoryService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Récupère toutes les catégories de l'utilisateur
  Future<List<Category>> getAllCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', _userId)
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
            .where((json) => json['user_id'] == _userId)
            .map(Category.fromJson)
            .toList());
  }

  /// Stream des catégories de dépenses
  Stream<List<Category>> watchExpenseCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .eq('type', CategoryType.expense.name)
        .order('name')
        .map((data) => data
            .where((json) => json['user_id'] == _userId)
            .map(Category.fromJson)
            .toList());
  }

  /// Stream des catégories de revenus
  Stream<List<Category>> watchIncomeCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .eq('type', CategoryType.income.name)
        .order('name')
        .map((data) => data
            .where((json) => json['user_id'] == _userId)
            .map(Category.fromJson)
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

  /// Supprime une catégorie de l'utilisateur
  Future<void> deleteCategory(String id) async {
    await _client
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  /// Supprime toutes les catégories de l'utilisateur
  Future<void> deleteAllCategories() async {
    await _client
        .from('categories')
        .delete()
        .eq('user_id', _userId);
  }

  /// Injecte le set de catégories par défaut dans le compte de l'utilisateur.
  /// Idempotent : ne fait rien si l'utilisateur a déjà au moins une catégorie.
  Future<void> seedDefaultCategories() async {
    final existing = await _client
        .from('categories')
        .select('id')
        .eq('user_id', _userId)
        .limit(1);

    if ((existing as List).isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    final rows = kDefaultCategories
        .map((c) => {
              'user_id': _userId,
              'name': c.name,
              'icon_key': c.iconKey,
              'color': c.color,
              'type': c.type.name,
              'budget_limit': null,
              'is_default': true,
              'created_at': now,
              'updated_at': now,
            })
        .toList();

    await _client.from('categories').insert(rows);
  }

  /// Migre les catégories globales (`user_id IS NULL`) vers le scope perso.
  ///
  /// Pour chaque catégorie globale référencée par les transactions /
  /// récurrences / budgets de l'utilisateur, crée une copie perso et
  /// re-pointe les références. Complète ensuite avec les catégories du
  /// set par défaut qui ne sont pas déjà couvertes.
  Future<void> migrateGlobalCategories() async {
    // 1. Catégories globales référencées
    final referencedIds = <String>{};
    for (final table in [
      'transactions',
      'recurring_transactions',
      'user_budgets',
    ]) {
      final rows = await _client
          .from(table)
          .select('category_id')
          .eq('user_id', _userId);
      for (final row in rows as List) {
        final id = (row as Map<String, dynamic>)['category_id'];
        if (id is String) referencedIds.add(id);
      }
    }

    final referencedGlobals = <Map<String, dynamic>>[];
    if (referencedIds.isNotEmpty) {
      final raw = await _client
          .from('categories')
          .select()
          .filter('user_id', 'is', null)
          .inFilter('id', referencedIds.toList()) as List;
      referencedGlobals.addAll(raw.cast<Map<String, dynamic>>());
    }

    // 2. Crée les copies perso et re-pointe les références
    if (referencedGlobals.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      final rows = referencedGlobals
          .map((g) => {
                'user_id': _userId,
                'name': g['name'],
                'icon_key': g['icon_key'],
                'color': g['color'],
                'type': g['type'],
                'budget_limit': g['budget_limit'],
                'is_default': true,
                'created_at': now,
                'updated_at': now,
              })
          .toList();

      final inserted = (await _client
          .from('categories')
          .insert(rows)
          .select() as List)
          .cast<Map<String, dynamic>>();

      for (var i = 0; i < referencedGlobals.length; i++) {
        final oldId = referencedGlobals[i]['id'] as String;
        final newId = inserted[i]['id'] as String;

        await Future.wait([
          _client
              .from('transactions')
              .update({'category_id': newId})
              .eq('user_id', _userId)
              .eq('category_id', oldId),
          _client
              .from('recurring_transactions')
              .update({'category_id': newId})
              .eq('user_id', _userId)
              .eq('category_id', oldId),
          _client
              .from('user_budgets')
              .update({'category_id': newId})
              .eq('user_id', _userId)
              .eq('category_id', oldId),
        ]);
      }
    }

    // 3. Complète avec les défauts non couverts (par nom + type)
    final existing = await _client
        .from('categories')
        .select('name, type')
        .eq('user_id', _userId) as List;

    final have = <String>{};
    for (final row in existing) {
      final m = row as Map<String, dynamic>;
      have.add('${m['type']}::${(m['name'] as String).toLowerCase()}');
    }

    final now = DateTime.now().toIso8601String();
    final toAdd = kDefaultCategories
        .where((c) => !have.contains('${c.type.name}::${c.name.toLowerCase()}'))
        .map((c) => {
              'user_id': _userId,
              'name': c.name,
              'icon_key': c.iconKey,
              'color': c.color,
              'type': c.type.name,
              'budget_limit': null,
              'is_default': true,
              'created_at': now,
              'updated_at': now,
            })
        .toList();

    if (toAdd.isNotEmpty) {
      await _client.from('categories').insert(toAdd);
    }
  }

  /// Retourne la catégorie "Virement" du type donné, en la créant si nécessaire.
  ///
  /// Utilisé lors de la création d'un virement entre comptes.
  Future<Category> getOrCreateVirementCategory(CategoryType type) async {
    final categories = await getAllCategories();
    final existing = categories
        .where((c) => c.name == 'Virement' && c.type == type)
        .firstOrNull;

    if (existing != null) return existing;

    return createCategory(
      name: 'Virement',
      iconKey: 'arrow-left-right',
      color: 0xFF607D8B,
      type: type,
    );
  }
}
