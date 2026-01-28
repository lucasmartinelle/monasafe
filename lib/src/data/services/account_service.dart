import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:simpleflow/src/data/models/models.dart';

/// Service Supabase pour la gestion des comptes
class AccountService {
  AccountService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Récupère tous les comptes de l'utilisateur
  Future<List<Account>> getAllAccounts() async {
    final response = await _client
        .from('accounts')
        .select()
        .eq('user_id', _userId)
        .order('name');

    return (response as List)
        .map((json) => Account.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream de tous les comptes (réactif via Supabase Realtime)
  Stream<List<Account>> watchAllAccounts() {
    return _client
        .from('accounts')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('name')
        .map((data) =>
            data.map((json) => Account.fromJson(json)).toList());
  }

  /// Récupère un compte par son ID
  Future<Account?> getAccountById(String id) async {
    final response = await _client
        .from('accounts')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return Account.fromJson(response);
  }

  /// Stream d'un compte spécifique
  Stream<Account?> watchAccountById(String id) {
    return _client
        .from('accounts')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isEmpty ? null : Account.fromJson(data.first));
  }

  /// Crée un nouveau compte
  Future<Account> createAccount({
    required String name,
    required AccountType type,
    required double initialBalance,
    required String currency,
    required int color,
  }) async {
    final now = DateTime.now().toIso8601String();
    final data = {
      'user_id': _userId,
      'name': name,
      'type': type.name,
      'balance': initialBalance,
      'currency': currency,
      'color': color,
      'created_at': now,
      'updated_at': now,
    };

    final response = await _client
        .from('accounts')
        .insert(data)
        .select()
        .single();

    return Account.fromJson(response);
  }

  /// Met à jour un compte existant
  Future<Account> updateAccount({
    required String id,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    int? color,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) data['name'] = name;
    if (type != null) data['type'] = type.name;
    if (balance != null) data['balance'] = balance;
    if (currency != null) data['currency'] = currency;
    if (color != null) data['color'] = color;

    final response = await _client
        .from('accounts')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return Account.fromJson(response);
  }

  /// Supprime un compte
  Future<void> deleteAccount(String id) async {
    await _client
        .from('accounts')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  /// Compte le nombre total de comptes
  Future<int> countAccounts() async {
    final response = await _client
        .from('accounts')
        .select()
        .eq('user_id', _userId)
        .count(CountOption.exact);

    return response.count;
  }
}
