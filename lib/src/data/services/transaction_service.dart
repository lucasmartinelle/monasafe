import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:simpleflow/src/data/models/models.dart';

/// Service Supabase pour la gestion des transactions
class TransactionService {
  TransactionService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  static const _selectWithDetails = '''
    *,
    accounts!inner(*),
    categories!inner(*)
  ''';

  /// Récupère toutes les transactions avec leurs détails
  Future<List<TransactionWithDetails>> getAllTransactionsWithDetails() async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream de toutes les transactions avec détails
  Stream<List<TransactionWithDetails>> watchAllTransactionsWithDetails() {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .asyncMap((transactions) async {
          if (transactions.isEmpty) return <TransactionWithDetails>[];

          // Récupérer les données complètes avec les relations
          final response = await _client
              .from('transactions')
              .select(_selectWithDetails)
              .eq('user_id', _userId)
              .order('date', ascending: false);

          return (response as List)
              .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
              .toList();
        });
  }

  /// Récupère les transactions d'un compte sur une période
  Future<List<TransactionWithDetails>> getTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .eq('account_id', accountId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream des transactions d'un compte sur une période
  Stream<List<TransactionWithDetails>> watchTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .asyncMap((_) => getTransactionsByAccountAndPeriod(accountId, startDate, endDate));
  }

  /// Récupère les transactions sur une période (tous comptes)
  Future<List<TransactionWithDetails>> getTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream des transactions sur une période
  Stream<List<TransactionWithDetails>> watchTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .asyncMap((_) => getTransactionsByPeriod(startDate, endDate));
  }

  /// Récupère une transaction par son ID
  Future<Transaction?> getTransactionById(String id) async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return Transaction.fromJson(response);
  }

  /// Crée une nouvelle transaction
  Future<Transaction> createTransaction({
    required String accountId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    bool isRecurring = false,
  }) async {
    final now = DateTime.now().toIso8601String();
    final data = {
      'user_id': _userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'is_recurring': isRecurring,
      'sync_status': SyncStatus.synced.name,
      'created_at': now,
      'updated_at': now,
    };

    final response = await _client
        .from('transactions')
        .insert(data)
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  /// Crée plusieurs transactions en batch
  Future<void> createTransactions(
    List<({
      String accountId,
      String categoryId,
      double amount,
      DateTime date,
      String? note,
      bool isRecurring,
    })> items,
  ) async {
    final now = DateTime.now().toIso8601String();
    final data = items.map((item) => {
      'user_id': _userId,
      'account_id': item.accountId,
      'category_id': item.categoryId,
      'amount': item.amount,
      'date': item.date.toIso8601String(),
      'note': item.note,
      'is_recurring': item.isRecurring,
      'sync_status': SyncStatus.synced.name,
      'created_at': now,
      'updated_at': now,
    }).toList();

    await _client.from('transactions').insert(data);
  }

  /// Met à jour une transaction existante
  Future<Transaction> updateTransaction({
    required String id,
    String? accountId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    bool? isRecurring,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (accountId != null) data['account_id'] = accountId;
    if (categoryId != null) data['category_id'] = categoryId;
    if (amount != null) data['amount'] = amount;
    if (date != null) data['date'] = date.toIso8601String();
    if (note != null) data['note'] = note;
    if (isRecurring != null) data['is_recurring'] = isRecurring;

    final response = await _client
        .from('transactions')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return Transaction.fromJson(response);
  }

  /// Supprime une transaction
  Future<void> deleteTransaction(String id) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  /// Récupère les N dernières transactions
  Future<List<TransactionWithDetails>> getRecentTransactions(int limit) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream des N dernières transactions
  Stream<List<TransactionWithDetails>> watchRecentTransactions(int limit) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .limit(limit)
        .asyncMap((_) => getRecentTransactions(limit));
  }

  /// Compte le nombre total de transactions
  Future<int> countTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .count(CountOption.exact);

    return response.count;
  }

  /// Compte les transactions par compte
  Future<int> countTransactionsByAccount(String accountId) async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .eq('account_id', accountId)
        .count(CountOption.exact);

    return response.count;
  }

  /// Recherche les transactions par note
  Future<List<TransactionWithDetails>> searchByNote(
    String query, {
    int limit = 5,
  }) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .ilike('note', '%$query%')
        .order('date', ascending: false)
        .limit(limit * 2);

    final results = (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();

    // Filtrer les doublons par note
    final seen = <String>{};
    final unique = <TransactionWithDetails>[];
    for (final tx in results) {
      final note = tx.transaction.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(tx);
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }

  /// Recherche les transactions par note et type de catégorie
  Future<List<TransactionWithDetails>> searchByNoteAndType(
    String query,
    CategoryType categoryType, {
    int limit = 5,
  }) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .ilike('note', '%$query%')
        .eq('categories.type', categoryType.name)
        .order('date', ascending: false)
        .limit(limit * 2);

    final results = (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();

    final seen = <String>{};
    final unique = <TransactionWithDetails>[];
    for (final tx in results) {
      final note = tx.transaction.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(tx);
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }

  /// Récupère les notes distinctes récentes pour les suggestions
  Future<List<TransactionWithDetails>> getRecentDistinctNotes({
    int limit = 10,
  }) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .not('note', 'is', null)
        .order('date', ascending: false)
        .limit(limit * 3);

    final results = (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();

    final seen = <String>{};
    final unique = <TransactionWithDetails>[];
    for (final tx in results) {
      final note = tx.transaction.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(tx);
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }

  /// Récupère les notes distinctes récentes filtrées par type
  Future<List<TransactionWithDetails>> getRecentDistinctNotesByType(
    CategoryType categoryType, {
    int limit = 10,
  }) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .not('note', 'is', null)
        .eq('categories.type', categoryType.name)
        .order('date', ascending: false)
        .limit(limit * 3);

    final results = (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();

    final seen = <String>{};
    final unique = <TransactionWithDetails>[];
    for (final tx in results) {
      final note = tx.transaction.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(tx);
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }

  /// Récupère les transactions avec pagination
  Future<List<TransactionWithDetails>> getTransactionsPaginated({
    required int limit,
    required int offset,
  }) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Récupère les transactions d'un compte avec pagination
  Future<List<TransactionWithDetails>> getTransactionsByAccountPaginated(
    String accountId, {
    required int limit,
    required int offset,
  }) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .eq('account_id', accountId)
        .order('date', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => TransactionWithDetails.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
