import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/daos/statistics_dao.dart';
import 'package:simpleflow/src/data/local/daos/transaction_dao.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:uuid/uuid.dart';

/// Erreurs possibles lors des opérations sur les transactions
sealed class TransactionError {
  const TransactionError(this.message);
  final String message;
}

class TransactionNotFoundError extends TransactionError {
  const TransactionNotFoundError() : super('Transaction non trouvée');
}

class TransactionCreationError extends TransactionError {
  const TransactionCreationError(super.message);
}

class TransactionUpdateError extends TransactionError {
  const TransactionUpdateError(super.message);
}

class TransactionDeletionError extends TransactionError {
  const TransactionDeletionError(super.message);
}

class InvalidAccountError extends TransactionError {
  const InvalidAccountError() : super('Compte invalide');
}

class InvalidCategoryError extends TransactionError {
  const InvalidCategoryError() : super('Catégorie invalide');
}

class TransactionFetchError extends TransactionError {
  const TransactionFetchError(super.message);
}

class TransactionSyncError extends TransactionError {
  const TransactionSyncError(super.message);
}

class TransactionStatisticsError extends TransactionError {
  const TransactionStatisticsError(super.message);
}

/// Repository pour la gestion des transactions
class TransactionRepository {

  TransactionRepository(this._db);
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  /// Récupère toutes les transactions avec leurs détails
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getAllTransactions() async {
    try {
      final transactions =
          await _db.transactionDao.getAllTransactionsWithDetails();
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream de toutes les transactions
  Stream<List<TransactionWithDetails>> watchAllTransactions() {
    return _db.transactionDao.watchAllTransactionsWithDetails();
  }

  /// Récupère les transactions d'un compte sur une période
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await _db.transactionDao
          .getTransactionsByAccountAndPeriod(accountId, startDate, endDate);
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des transactions d'un compte sur une période
  Stream<List<TransactionWithDetails>> watchTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _db.transactionDao
        .watchTransactionsByAccountAndPeriod(accountId, startDate, endDate);
  }

  /// Récupère les transactions sur une période (tous comptes)
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions =
          await _db.transactionDao.getTransactionsByPeriod(startDate, endDate);
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des transactions sur une période
  Stream<List<TransactionWithDetails>> watchTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _db.transactionDao.watchTransactionsByPeriod(startDate, endDate);
  }

  /// Récupère les N dernières transactions
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getRecentTransactions(int limit) async {
    try {
      final transactions =
          await _db.transactionDao.getRecentTransactions(limit);
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des N dernières transactions
  Stream<List<TransactionWithDetails>> watchRecentTransactions(int limit) {
    return _db.transactionDao.watchRecentTransactions(limit);
  }

  /// Crée une nouvelle transaction
  Future<Either<TransactionError, Transaction>> createTransaction({
    required String accountId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    bool isRecurring = false,
  }) async {
    try {
      // Valide le compte
      final account = await _db.accountDao.getAccountById(accountId);
      if (account == null) {
        return const Left(InvalidAccountError());
      }

      // Valide la catégorie
      final category = await _db.categoryDao.getCategoryById(categoryId);
      if (category == null) {
        return const Left(InvalidCategoryError());
      }

      final id = _uuid.v4();
      final now = DateTime.now();

      final companion = TransactionsCompanion.insert(
        id: id,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: Value(note),
        isRecurring: Value(isRecurring),
        syncStatus: const Value(SyncStatus.pending),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await _db.transactionDao.createTransaction(companion);

      final created = await _db.transactionDao.getTransactionById(id);
      if (created == null) {
        return const Left(TransactionCreationError('Échec de la création'));
      }

      return Right(created);
    } catch (e) {
      return Left(TransactionCreationError('Erreur: $e'));
    }
  }

  /// Crée plusieurs transactions en batch
  Future<Either<TransactionError, Unit>> createTransactions(
    List<({
      String accountId,
      String categoryId,
      double amount,
      DateTime date,
      String? note,
      bool isRecurring,
    })> items,
  ) async {
    try {
      final now = DateTime.now();
      final companions = items.map((item) {
        return TransactionsCompanion.insert(
          id: _uuid.v4(),
          accountId: item.accountId,
          categoryId: item.categoryId,
          amount: item.amount,
          date: item.date,
          note: Value(item.note),
          isRecurring: Value(item.isRecurring),
          syncStatus: const Value(SyncStatus.pending),
          createdAt: Value(now),
          updatedAt: Value(now),
        );
      }).toList();

      await _db.transactionDao.createTransactions(companions);
      return const Right(unit);
    } catch (e) {
      return Left(TransactionCreationError('Erreur: $e'));
    }
  }

  /// Met à jour une transaction existante
  Future<Either<TransactionError, Transaction>> updateTransaction({
    required String id,
    String? accountId,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    bool? isRecurring,
  }) async {
    try {
      final existing = await _db.transactionDao.getTransactionById(id);
      if (existing == null) {
        return const Left(TransactionNotFoundError());
      }

      // Valide le compte si modifié
      if (accountId != null) {
        final account = await _db.accountDao.getAccountById(accountId);
        if (account == null) {
          return const Left(InvalidAccountError());
        }
      }

      // Valide la catégorie si modifiée
      if (categoryId != null) {
        final category = await _db.categoryDao.getCategoryById(categoryId);
        if (category == null) {
          return const Left(InvalidCategoryError());
        }
      }

      final companion = TransactionsCompanion(
        id: Value(id),
        accountId: accountId != null ? Value(accountId) : const Value.absent(),
        categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
        amount: amount != null ? Value(amount) : const Value.absent(),
        date: date != null ? Value(date) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        isRecurring: isRecurring != null ? Value(isRecurring) : const Value.absent(),
        syncStatus: const Value(SyncStatus.pending), // Reset sync status on update
        updatedAt: Value(DateTime.now()),
      );

      final success = await _db.transactionDao.updateTransaction(companion);
      if (!success) {
        return const Left(TransactionUpdateError('Échec de la mise à jour'));
      }

      final updated = await _db.transactionDao.getTransactionById(id);
      return Right(updated!);
    } catch (e) {
      return Left(TransactionUpdateError('Erreur: $e'));
    }
  }

  /// Supprime une transaction
  Future<Either<TransactionError, Unit>> deleteTransaction(String id) async {
    try {
      final existing = await _db.transactionDao.getTransactionById(id);
      if (existing == null) {
        return const Left(TransactionNotFoundError());
      }

      await _db.transactionDao.deleteTransaction(id);
      return const Right(unit);
    } catch (e) {
      return Left(TransactionDeletionError('Erreur: $e'));
    }
  }

  /// Récupère les transactions en attente de synchronisation
  Future<Either<TransactionError, List<Transaction>>>
      getPendingTransactions() async {
    try {
      final transactions = await _db.transactionDao.getPendingTransactions();
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Marque une transaction comme synchronisée
  Future<Either<TransactionError, Unit>> markAsSynced(String id) async {
    try {
      await _db.transactionDao.markAsSynced(id);
      return const Right(unit);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Marque plusieurs transactions comme synchronisées
  Future<Either<TransactionError, Unit>> markMultipleAsSynced(
    List<String> ids,
  ) async {
    try {
      await _db.transactionDao.markMultipleAsSynced(ids);
      return const Right(unit);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Compte le nombre total de transactions
  Future<int> countTransactions() {
    return _db.transactionDao.countTransactions();
  }

  // ==================== STATISTIQUES ====================

  /// Récupère le total par catégorie sur une période
  Future<Either<TransactionError, List<CategoryStatistics>>> getTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final stats =
          await _db.statisticsDao.getTotalByCategory(startDate, endDate);
      return Right(stats);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream du total par catégorie
  Stream<List<CategoryStatistics>> watchTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _db.statisticsDao.watchTotalByCategory(startDate, endDate);
  }

  /// Récupère le total par catégorie et type
  Future<Either<TransactionError, List<CategoryStatistics>>>
      getTotalByCategoryAndType(
    DateTime startDate,
    DateTime endDate,
    CategoryType type,
  ) async {
    try {
      final stats = await _db.statisticsDao
          .getTotalByCategoryAndType(startDate, endDate, type);
      return Right(stats);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Récupère les statistiques mensuelles d'une année
  Future<Either<TransactionError, List<MonthlyStatistics>>>
      getMonthlyStatistics(int year) async {
    try {
      final stats = await _db.statisticsDao.getMonthlyStatistics(year);
      return Right(stats);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des statistiques mensuelles
  Stream<List<MonthlyStatistics>> watchMonthlyStatistics(int year) {
    return _db.statisticsDao.watchMonthlyStatistics(year);
  }

  /// Récupère le résumé financier global
  Future<Either<TransactionError, FinancialSummary>>
      getFinancialSummary() async {
    try {
      final summary = await _db.statisticsDao.getFinancialSummary();
      return Right(summary);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream du résumé financier
  Stream<FinancialSummary> watchFinancialSummary() {
    return _db.statisticsDao.watchFinancialSummary();
  }

  /// Récupère les dépenses d'une catégorie ce mois
  Future<Either<TransactionError, double>> getCategorySpendingThisMonth(
    String categoryId,
  ) async {
    try {
      final spending =
          await _db.statisticsDao.getCategorySpendingThisMonth(categoryId);
      return Right(spending);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des dépenses d'une catégorie ce mois
  Stream<double> watchCategorySpendingThisMonth(String categoryId) {
    return _db.statisticsDao.watchCategorySpendingThisMonth(categoryId);
  }

  // ==================== RECHERCHE ====================

  /// Recherche les transactions par note (pour les suggestions)
  Future<Either<TransactionError, List<TransactionWithDetails>>> searchByNote(
    String query, {
    int limit = 5,
  }) async {
    try {
      final results = await _db.transactionDao.searchByNote(query, limit: limit);
      return Right(results);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Recherche les transactions par note et type de catégorie
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      searchByNoteAndType(
    String query,
    CategoryType categoryType, {
    int limit = 5,
  }) async {
    try {
      final results = await _db.transactionDao
          .searchByNoteAndType(query, categoryType, limit: limit);
      return Right(results);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Récupère les notes distinctes récentes pour les suggestions
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getRecentDistinctNotes({int limit = 10}) async {
    try {
      final results =
          await _db.transactionDao.getRecentDistinctNotes(limit: limit);
      return Right(results);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Récupère les notes distinctes récentes filtrées par type
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getRecentDistinctNotesByType(CategoryType categoryType,
          {int limit = 10}) async {
    try {
      final results = await _db.transactionDao
          .getRecentDistinctNotesByType(categoryType, limit: limit);
      return Right(results);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Récupère les transactions avec pagination
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getTransactionsPaginated({
    required int limit,
    required int offset,
  }) async {
    try {
      final results = await _db.transactionDao.getTransactionsPaginated(
        limit: limit,
        offset: offset,
      );
      return Right(results);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Récupère les transactions d'un compte avec pagination
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getTransactionsByAccountPaginated(
    String accountId, {
    required int limit,
    required int offset,
  }) async {
    try {
      final results = await _db.transactionDao.getTransactionsByAccountPaginated(
        accountId,
        limit: limit,
        offset: offset,
      );
      return Right(results);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }
}
