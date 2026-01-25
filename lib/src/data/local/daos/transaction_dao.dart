import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/local/tables/accounts_table.dart';
import 'package:simpleflow/src/data/local/tables/categories_table.dart';
import 'package:simpleflow/src/data/local/tables/transactions_table.dart';

part 'transaction_dao.g.dart';

/// DTO pour une transaction avec ses relations
class TransactionWithDetails {

  TransactionWithDetails({
    required this.transaction,
    required this.account,
    required this.category,
  });
  final Transaction transaction;
  final Account account;
  final Category category;
}

/// DAO pour les opérations CRUD sur les transactions
///
/// Index utilisés :
/// - idx_transactions_account_id : JOIN avec Accounts
/// - idx_transactions_category_id : JOIN avec Categories
/// - idx_transactions_date : Filtrage par période
/// - idx_transactions_account_date : Requêtes combinées compte + période
/// - idx_transactions_sync_status : Identification des transactions pending
@DriftAccessor(tables: [Transactions, Accounts, Categories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Récupère toutes les transactions avec leurs détails, triées par date décroissante
  Future<List<TransactionWithDetails>> getAllTransactionsWithDetails() async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    final results = await query.get();
    return results.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        account: row.readTable(accounts),
        category: row.readTable(categories),
      );
    }).toList();
  }

  /// Stream de toutes les transactions avec détails
  Stream<List<TransactionWithDetails>> watchAllTransactionsWithDetails() {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map((results) {
      return results.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          account: row.readTable(accounts),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  /// Récupère les transactions d'un compte sur une période
  /// Utilise l'index composite idx_transactions_account_date (très optimisé)
  Future<List<TransactionWithDetails>> getTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.accountId.equals(accountId) &
          transactions.date.isBetweenValues(startDate, endDate))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    final results = await query.get();
    return results.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        account: row.readTable(accounts),
        category: row.readTable(categories),
      );
    }).toList();
  }

  /// Stream des transactions d'un compte sur une période
  Stream<List<TransactionWithDetails>> watchTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.accountId.equals(accountId) &
          transactions.date.isBetweenValues(startDate, endDate))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map((results) {
      return results.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          account: row.readTable(accounts),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  /// Récupère les transactions par période (tous comptes)
  /// Utilise idx_transactions_date
  Future<List<TransactionWithDetails>> getTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.date.isBetweenValues(startDate, endDate))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    final results = await query.get();
    return results.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        account: row.readTable(accounts),
        category: row.readTable(categories),
      );
    }).toList();
  }

  /// Stream des transactions par période
  Stream<List<TransactionWithDetails>> watchTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.date.isBetweenValues(startDate, endDate))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map((results) {
      return results.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          account: row.readTable(accounts),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  /// Récupère une transaction par son ID
  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Crée une nouvelle transaction
  Future<void> createTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Crée plusieurs transactions en batch (optimisé)
  Future<void> createTransactions(List<TransactionsCompanion> items) {
    return batch((batch) {
      batch.insertAll(transactions, items);
    });
  }

  /// Met à jour une transaction existante
  Future<bool> updateTransaction(TransactionsCompanion transaction) {
    return (update(transactions)
            ..where((t) => t.id.equals(transaction.id.value)))
        .write(transaction)
        .then((rows) => rows > 0);
  }

  /// Supprime une transaction par son ID
  Future<int> deleteTransaction(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Récupère les transactions en attente de synchronisation
  /// Utilise idx_transactions_sync_status
  Future<List<Transaction>> getPendingTransactions() {
    return (select(transactions)
          ..where((t) => t.syncStatus.equals(SyncStatus.pending.index))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Marque une transaction comme synchronisée
  Future<void> markAsSynced(String id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        syncStatus: const Value(SyncStatus.synced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marque plusieurs transactions comme synchronisées (batch)
  Future<void> markMultipleAsSynced(List<String> ids) {
    return (update(transactions)..where((t) => t.id.isIn(ids))).write(
      TransactionsCompanion(
        syncStatus: const Value(SyncStatus.synced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Récupère les N dernières transactions
  Future<List<TransactionWithDetails>> getRecentTransactions(int limit) async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit);

    final results = await query.get();
    return results.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        account: row.readTable(accounts),
        category: row.readTable(categories),
      );
    }).toList();
  }

  /// Stream des N dernières transactions
  Stream<List<TransactionWithDetails>> watchRecentTransactions(int limit) {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit);

    return query.watch().map((results) {
      return results.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          account: row.readTable(accounts),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  /// Compte le nombre total de transactions
  Future<int> countTransactions() async {
    final count = transactions.id.count();
    final query = selectOnly(transactions)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Compte les transactions par compte
  Future<int> countTransactionsByAccount(String accountId) async {
    final count = transactions.id.count();
    final query = selectOnly(transactions)
      ..addColumns([count])
      ..where(transactions.accountId.equals(accountId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Recherche les transactions par note (LIKE %query%)
  /// Retourne les transactions distinctes par note pour les suggestions
  Future<List<TransactionWithDetails>> searchByNote(
    String query, {
    int limit = 5,
  }) async {
    if (query.isEmpty) return [];

    final searchQuery = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.note.like('%$query%'))
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit * 2); // Get more to filter duplicates

    final results = await searchQuery.get();
    final seen = <String>{};
    final unique = <TransactionWithDetails>[];

    for (final row in results) {
      final tx = row.readTable(transactions);
      final note = tx.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(TransactionWithDetails(
          transaction: tx,
          account: row.readTable(accounts),
          category: row.readTable(categories),
        ));
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

    final searchQuery = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.note.like('%$query%') &
          categories.type.equals(categoryType.index))
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit * 2);

    final results = await searchQuery.get();
    final seen = <String>{};
    final unique = <TransactionWithDetails>[];

    for (final row in results) {
      final tx = row.readTable(transactions);
      final note = tx.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(TransactionWithDetails(
          transaction: tx,
          account: row.readTable(accounts),
          category: row.readTable(categories),
        ));
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }

  /// Récupère les notes distinctes récentes pour les suggestions
  Future<List<TransactionWithDetails>> getRecentDistinctNotes({
    int limit = 10,
  }) async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.note.isNotNull() & transactions.note.length.isBiggerThanValue(0))
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit * 3); // Get more to filter duplicates

    final results = await query.get();
    final seen = <String>{};
    final unique = <TransactionWithDetails>[];

    for (final row in results) {
      final tx = row.readTable(transactions);
      final note = tx.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(TransactionWithDetails(
          transaction: tx,
          account: row.readTable(accounts),
          category: row.readTable(categories),
        ));
        if (unique.length >= limit) break;
      }
    }

    return unique;
  }

  /// Récupère les notes distinctes récentes filtrées par type de catégorie
  Future<List<TransactionWithDetails>> getRecentDistinctNotesByType(
    CategoryType categoryType, {
    int limit = 10,
  }) async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.note.isNotNull() &
          transactions.note.length.isBiggerThanValue(0) &
          categories.type.equals(categoryType.index))
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit * 3);

    final results = await query.get();
    final seen = <String>{};
    final unique = <TransactionWithDetails>[];

    for (final row in results) {
      final tx = row.readTable(transactions);
      final note = tx.note ?? '';
      if (note.isNotEmpty && !seen.contains(note.toLowerCase())) {
        seen.add(note.toLowerCase());
        unique.add(TransactionWithDetails(
          transaction: tx,
          account: row.readTable(accounts),
          category: row.readTable(categories),
        ));
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
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit, offset: offset);

    final results = await query.get();
    return results.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        account: row.readTable(accounts),
        category: row.readTable(categories),
      );
    }).toList();
  }

  /// Récupère les transactions d'un compte avec pagination
  Future<List<TransactionWithDetails>> getTransactionsByAccountPaginated(
    String accountId, {
    required int limit,
    required int offset,
  }) async {
    final query = select(transactions).join([
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..where(transactions.accountId.equals(accountId))
      ..orderBy([OrderingTerm.desc(transactions.date)])
      ..limit(limit, offset: offset);

    final results = await query.get();
    return results.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        account: row.readTable(accounts),
        category: row.readTable(categories),
      );
    }).toList();
  }
}
