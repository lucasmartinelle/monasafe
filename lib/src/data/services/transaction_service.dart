import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/core/middleware/vault_middleware.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service Supabase pour la gestion des transactions
class TransactionService {
  TransactionService(this._client, {VaultMiddleware? vaultMiddleware})
      : _vaultMiddleware = vaultMiddleware;

  final SupabaseClient _client;
  final VaultMiddleware? _vaultMiddleware;

  /// Vérifie si le chiffrement est actif
  bool get isEncryptionEnabled => _vaultMiddleware != null;

  String get _userId => _client.auth.currentUser!.id;

  static const _selectWithDetails = '''
    *,
    accounts!inner(*),
    categories!inner(*)
  ''';

  // ==================== HELPERS CHIFFREMENT ====================

  /// Déchiffre une transaction si nécessaire
  Future<Transaction> _decryptTransaction(Transaction tx) async {
    if (!tx.isEncrypted || _vaultMiddleware == null) return tx;

    try {
      final decrypted = await _vaultMiddleware.decryptTransactionData(
        tx.rawAmount,
        tx.rawNote,
      );

      return tx.withDecrypted(
        amount: decrypted.amount,
        note: decrypted.note,
      );
    } catch (_) {
      // Si le déchiffrement échoue, retourner la transaction telle quelle
      // L'UI affichera un indicateur de données chiffrées
      return tx;
    }
  }

  /// Déchiffre une liste de TransactionWithDetails
  Future<List<TransactionWithDetails>> _decryptTransactionsList(
    List<Map<String, dynamic>> jsonList,
  ) async {
    final results = <TransactionWithDetails>[];
    for (final json in jsonList) {
      final txWithDetails = TransactionWithDetails.fromJson(json);

      if (!txWithDetails.transaction.isEncrypted || _vaultMiddleware == null) {
        results.add(txWithDetails);
        continue;
      }

      final decryptedTx = await _decryptTransaction(txWithDetails.transaction);
      results.add(TransactionWithDetails(
        transaction: decryptedTx,
        account: txWithDetails.account,
        category: txWithDetails.category,
      ));
    }
    return results;
  }

  // ==================== RÉCUPÉRATION ====================

  /// Stream de toutes les transactions avec détails
  Stream<List<TransactionWithDetails>> watchAllTransactionsWithDetails() {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date')
        .asyncMap((transactions) async {
          if (transactions.isEmpty) return <TransactionWithDetails>[];

          final response = await _client
              .from('transactions')
              .select(_selectWithDetails)
              .eq('user_id', _userId)
              .order('date', ascending: false);

          return _decryptTransactionsList(response);
        });
  }

  /// Récupère toutes les transactions d'un compte
  Future<List<TransactionWithDetails>> getTransactionsByAccount(
    String accountId,
  ) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .eq('account_id', accountId)
        .order('date', ascending: false);

    return _decryptTransactionsList(response);
  }

  /// Stream des transactions d'un compte
  Stream<List<TransactionWithDetails>> watchTransactionsByAccount(
    String accountId,
  ) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date')
        .asyncMap((_) => getTransactionsByAccount(accountId));
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

    return _decryptTransactionsList(response);
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
        .order('date')
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

    return _decryptTransactionsList(response);
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
        .order('date')
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
    final tx = Transaction.fromJson(response);
    return _decryptTransaction(tx);
  }

  // ==================== CRÉATION ====================

  /// Crée une nouvelle transaction
  Future<Transaction> createTransaction({
    required String accountId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? recurringId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      'user_id': _userId,
      'account_id': accountId,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'recurring_id': recurringId,
      'sync_status': SyncStatus.synced.name,
      'created_at': now,
      'updated_at': now,
    };

    // Chiffrer si le vault est actif
    if (_vaultMiddleware != null) {
      final encrypted = await _vaultMiddleware.encryptTransactionData(amount, note);
      data['amount'] = encrypted.encryptedAmount; // Base64 chiffré
      data['note'] = encrypted.encryptedNote; // Base64 chiffré ou null
      data['is_encrypted'] = true;
    } else {
      data['amount'] = amount.toString(); // Nombre en string
      data['note'] = note;
      data['is_encrypted'] = false;
    }

    final response = await _client
        .from('transactions')
        .insert(data)
        .select()
        .single();

    final tx = Transaction.fromJson(response);
    return _decryptTransaction(tx);
  }

  // ==================== MISE À JOUR ====================

  /// Met à jour une transaction existante
  Future<Transaction> updateTransaction({
    required String id,
    String? accountId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) async {
    // Récupérer la transaction existante pour vérifier son état de chiffrement
    final existing = await _client
        .from('transactions')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .single();

    final wasEncrypted = existing['is_encrypted'] as bool? ?? false;

    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (accountId != null) data['account_id'] = accountId;
    if (categoryId != null) data['category_id'] = categoryId;
    if (date != null) data['date'] = date.toIso8601String();

    // Gérer le chiffrement pour amount et note
    if (amount != null || note != null) {
      // Si le vault est actif, chiffrer les nouvelles valeurs
      if (_vaultMiddleware != null) {
        // Récupérer les valeurs actuelles si pas fournies
        var finalAmount = amount ?? 0;
        var finalNote = note;

        if (amount == null && wasEncrypted) {
          // Déchiffrer l'ancien montant
          finalAmount = await _vaultMiddleware.decryptAmount(
            existing['amount'] as String,
          );
        } else if (amount == null) {
          finalAmount = double.tryParse(existing['amount'].toString()) ?? 0;
        }

        if (note == null && wasEncrypted && existing['note'] != null) {
          finalNote = await _vaultMiddleware.decryptNote(existing['note'] as String);
        } else if (note == null) {
          finalNote = existing['note'] as String?;
        }

        final encrypted = await _vaultMiddleware.encryptTransactionData(
          finalAmount,
          finalNote,
        );
        data['amount'] = encrypted.encryptedAmount;
        data['note'] = encrypted.encryptedNote;
        data['is_encrypted'] = true;
      } else {
        // Vault non actif, stocker en clair
        if (amount != null) data['amount'] = amount.toString();
        if (note != null) data['note'] = note;
        data['is_encrypted'] = false;
      }
    }

    final response = await _client
        .from('transactions')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    final tx = Transaction.fromJson(response);
    return _decryptTransaction(tx);
  }

  /// Supprime une transaction
  Future<void> deleteTransaction(String id) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // ==================== CHIFFREMENT/DÉCHIFFREMENT EN MASSE ====================

  /// Chiffre toutes les transactions non chiffrées.
  /// Utilisé lors de l'activation du vault.
  Future<void> encryptAllTransactions() async {
    if (_vaultMiddleware == null) return;

    final unencrypted = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .eq('is_encrypted', false);

    for (final row in unencrypted) {
      final id = row['id'] as String;
      final rawAmount = row['amount']?.toString() ?? '0';
      final rawNote = row['note'] as String?;

      try {
        // Parser le montant
        final amount = double.tryParse(rawAmount) ?? 0.0;

        // Chiffrer
        final encrypted = await _vaultMiddleware.encryptTransactionData(amount, rawNote);

        // Mettre à jour avec valeurs chiffrées
        await _client
            .from('transactions')
            .update({
              'amount': encrypted.encryptedAmount,
              'note': encrypted.encryptedNote,
              'is_encrypted': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id);
      } catch (e) {
        // Ignorer les transactions qui ne peuvent pas être chiffrées
      }
    }
  }

  /// Déchiffre toutes les transactions chiffrées et les met à jour en clair.
  /// Utilisé lors de la désactivation du vault.
  Future<void> decryptAllTransactions() async {
    if (_vaultMiddleware == null) return;

    final encrypted = await _client
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .eq('is_encrypted', true);

    for (final row in encrypted) {
      final id = row['id'] as String;
      final rawAmount = row['amount'] as String;
      final rawNote = row['note'] as String?;

      try {
        // Déchiffrer
        final amount = await _vaultMiddleware.decryptAmount(rawAmount);
        final note = await _vaultMiddleware.decryptNote(rawNote);

        // Mettre à jour avec valeurs en clair
        await _client
            .from('transactions')
            .update({
              'amount': amount.toString(),
              'note': note,
              'is_encrypted': false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id);
      } catch (e) {
        // Ignorer les transactions qui ne peuvent pas être déchiffrées
        // (clé différente, données corrompues, etc.)
      }
    }
  }

  // ==================== REQUÊTES DIVERSES ====================

  /// Récupère les N dernières transactions
  Future<List<TransactionWithDetails>> getRecentTransactions(int limit) async {
    final response = await _client
        .from('transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .order('date', ascending: false)
        .limit(limit);

    return _decryptTransactionsList(response);
  }

  /// Stream des N dernières transactions
  Stream<List<TransactionWithDetails>> watchRecentTransactions(int limit) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date')
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
        .not('note', 'is', null)
        .eq('categories.type', categoryType.name)
        .order('date', ascending: false)
        .limit(limit * 10);

    final results = await _decryptTransactionsList(response);
    final queryLower = query.toLowerCase();

    final seen = <String>{};
    final unique = <TransactionWithDetails>[];
    for (final tx in results) {
      final note = tx.transaction.note ?? '';
      final noteLower = note.toLowerCase();
      if (note.isNotEmpty &&
          noteLower.contains(queryLower) &&
          !seen.contains(noteLower)) {
        seen.add(noteLower);
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

    final results = await _decryptTransactionsList(response);

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

    return _decryptTransactionsList(response);
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

    return _decryptTransactionsList(response);
  }
}
