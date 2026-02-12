import 'package:monasafe/src/core/middleware/vault_middleware.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service Supabase pour la gestion des transactions recurrentes
class RecurringTransactionService {
  RecurringTransactionService(this._client, {VaultMiddleware? vaultMiddleware})
      : _vaultMiddleware = vaultMiddleware;

  final SupabaseClient _client;
  final VaultMiddleware? _vaultMiddleware;

  /// Verifie si le chiffrement est actif
  bool get isEncryptionEnabled => _vaultMiddleware != null;

  String get _userId => _client.auth.currentUser!.id;

  static const _selectWithDetails = '''
    *,
    accounts!inner(*),
    categories(*)
  ''';

  // ==================== HELPERS CHIFFREMENT ====================

  /// Dechiffre une transaction recurrente si necessaire
  Future<RecurringTransaction> _decryptRecurring(
    RecurringTransaction recurring,
  ) async {
    if (!recurring.isEncrypted || _vaultMiddleware == null) return recurring;

    try {
      final decrypted = await _vaultMiddleware.decryptTransactionData(
        recurring.rawAmount,
        recurring.rawNote,
      );

      return recurring.withDecrypted(
        amount: decrypted.amount,
        note: decrypted.note,
      );
    } catch (_) {
      return recurring;
    }
  }

  /// Dechiffre une liste de RecurringTransactionWithDetails
  Future<List<RecurringTransactionWithDetails>> _decryptRecurringList(
    List<Map<String, dynamic>> jsonList,
  ) async {
    final results = <RecurringTransactionWithDetails>[];
    for (final json in jsonList) {
      final withDetails = RecurringTransactionWithDetails.fromJson(json);

      if (!withDetails.recurring.isEncrypted || _vaultMiddleware == null) {
        results.add(withDetails);
        continue;
      }

      final decrypted = await _decryptRecurring(withDetails.recurring);
      results.add(withDetails.withDecryptedRecurring(decrypted));
    }
    return results;
  }

  // ==================== RECUPERATION ====================

  /// Stream de toutes les recurrences actives
  Stream<List<RecurringTransaction>> watchActiveRecurring() {
    return _client
        .from('recurring_transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at')
        .asyncMap((list) async {
      final recurrings =
          list.map(RecurringTransaction.fromJson).where((r) => r.isActive);
      final results = <RecurringTransaction>[];
      for (final recurring in recurrings) {
        results.add(await _decryptRecurring(recurring));
      }
      return results;
    });
  }

  /// Recupere toutes les recurrences avec details
  Future<List<RecurringTransactionWithDetails>> getAllWithDetails() async {
    final response = await _client
        .from('recurring_transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return _decryptRecurringList(response);
  }

  /// Recupere les recurrences actives avec details
  Future<List<RecurringTransactionWithDetails>> getActiveWithDetails() async {
    final response = await _client
        .from('recurring_transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return _decryptRecurringList(response);
  }

  /// Recupere les recurrences a generer.
  ///
  /// Retourne les recurrences actives dont :
  /// - last_generated est NULL (jamais generee apres start_date)
  /// - OU last_generated < today (nouvelles occurrences a generer)
  Future<List<RecurringTransactionWithDetails>> getRecurringsToGenerate() async {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T').first;

    final response = await _client
        .from('recurring_transactions')
        .select(_selectWithDetails)
        .eq('user_id', _userId)
        .eq('is_active', true)
        .or('last_generated.is.null,last_generated.lt.$todayStr');

    return _decryptRecurringList(response);
  }

  // ==================== CREATION ====================

  /// Cree une nouvelle recurrence
  Future<RecurringTransaction> create({
    required String accountId,
    required String categoryId,
    required double amount,
    String? note,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    // Preparer les donnees (chiffrement si actif)
    String amountStr;
    String? noteStr;
    bool isEncrypted = false;

    if (_vaultMiddleware != null) {
      final encrypted = await _vaultMiddleware.encryptTransactionData(
        amount,
        note,
      );
      amountStr = encrypted.encryptedAmount;
      noteStr = encrypted.encryptedNote;
      isEncrypted = true;
    } else {
      amountStr = amount.toString();
      noteStr = note;
    }

    final data = <String, dynamic>{
      'user_id': _userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amountStr,
      'note': noteStr,
      'original_day': startDate.day,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'is_active': true,
      'is_encrypted': isEncrypted,
    };

    final response = await _client
        .from('recurring_transactions')
        .insert(data)
        .select()
        .single();

    final recurring = RecurringTransaction.fromJson(response);

    // Retourner avec valeurs dechiffrees
    if (isEncrypted) {
      return recurring.withDecrypted(amount: amount, note: note);
    }
    return recurring;
  }

  // ==================== MODIFICATION ====================

  /// Met a jour une recurrence (pour futures occurrences)
  Future<RecurringTransaction> update({
    required String id,
    String? accountId,
    String? categoryId,
    double? amount,
    String? note,
    DateTime? endDate,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (accountId != null) data['account_id'] = accountId;
    if (categoryId != null) data['category_id'] = categoryId;
    if (endDate != null) {
      data['end_date'] = endDate.toIso8601String().split('T').first;
    }

    // Gestion du montant et de la note avec chiffrement
    if (amount != null || note != null) {
      // Recuperer la recurrence existante pour les valeurs non modifiees
      final existing = await _client
          .from('recurring_transactions')
          .select()
          .eq('id', id)
          .single();
      final existingRecurring = RecurringTransaction.fromJson(existing);
      final decrypted = await _decryptRecurring(existingRecurring);

      final newAmount = amount ?? decrypted.amount;
      final newNote = note ?? decrypted.note;

      if (_vaultMiddleware != null) {
        final encrypted = await _vaultMiddleware.encryptTransactionData(
          newAmount,
          newNote,
        );
        data['amount'] = encrypted.encryptedAmount;
        data['note'] = encrypted.encryptedNote;
        data['is_encrypted'] = true;
      } else {
        data['amount'] = newAmount.toString();
        data['note'] = newNote;
        data['is_encrypted'] = false;
      }
    }

    final response = await _client
        .from('recurring_transactions')
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return _decryptRecurring(RecurringTransaction.fromJson(response));
  }

  /// Met a jour last_generated apres generation d'une occurrence
  Future<void> updateLastGenerated(String id, DateTime date) async {
    await _client
        .from('recurring_transactions')
        .update({
          'last_generated': date.toIso8601String().split('T').first,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // ==================== DESACTIVATION / SUPPRESSION ====================

  /// Desactive une recurrence (ne supprime pas les transactions existantes)
  Future<void> deactivate(String id) async {
    await _client
        .from('recurring_transactions')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId);
  }

  /// Reactive une recurrence
  Future<void> reactivate(String id) async {
    await _client
        .from('recurring_transactions')
        .update({
          'is_active': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _userId);
  }

  /// Supprime une recurrence.
  ///
  /// Les transactions liees sont conservees mais leur recurring_id est mis a null.
  Future<void> delete(String id) async {
    // 1. Detacher les transactions liees (mettre recurring_id a null)
    await _client
        .from('transactions')
        .update({'recurring_id': null})
        .eq('recurring_id', id)
        .eq('user_id', _userId);

    // 2. Supprimer la recurrence
    await _client
        .from('recurring_transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  /// Supprime toutes les recurrences de l'utilisateur.
  ///
  /// Les transactions liees sont conservees mais leur recurring_id est mis a null.
  Future<void> deleteAll() async {
    // 1. Detacher toutes les transactions liees
    await _client
        .from('transactions')
        .update({'recurring_id': null})
        .eq('user_id', _userId)
        .not('recurring_id', 'is', null);

    // 2. Supprimer toutes les recurrences
    await _client
        .from('recurring_transactions')
        .delete()
        .eq('user_id', _userId);
  }
}
