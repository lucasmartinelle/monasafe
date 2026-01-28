import 'package:fpdart/fpdart.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/services/services.dart';

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
  TransactionRepository(
    this._transactionService,
    this._accountService,
    this._categoryService,
    this._statisticsService,
  );

  final TransactionService _transactionService;
  final AccountService _accountService;
  final CategoryService _categoryService;
  final StatisticsService _statisticsService;

  /// Récupère toutes les transactions avec leurs détails
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getAllTransactions() async {
    try {
      final transactions = await _transactionService.getAllTransactionsWithDetails();
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream de toutes les transactions
  Stream<List<TransactionWithDetails>> watchAllTransactions() {
    return _transactionService.watchAllTransactionsWithDetails();
  }

  /// Récupère les transactions d'un compte sur une période
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getTransactionsByAccountAndPeriod(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await _transactionService
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
    return _transactionService
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
          await _transactionService.getTransactionsByPeriod(startDate, endDate);
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
    return _transactionService.watchTransactionsByPeriod(startDate, endDate);
  }

  /// Récupère les N dernières transactions
  Future<Either<TransactionError, List<TransactionWithDetails>>>
      getRecentTransactions(int limit) async {
    try {
      final transactions = await _transactionService.getRecentTransactions(limit);
      return Right(transactions);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des N dernières transactions
  Stream<List<TransactionWithDetails>> watchRecentTransactions(int limit) {
    return _transactionService.watchRecentTransactions(limit);
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
      final account = await _accountService.getAccountById(accountId);
      if (account == null) {
        return const Left(InvalidAccountError());
      }

      // Valide la catégorie
      final category = await _categoryService.getCategoryById(categoryId);
      if (category == null) {
        return const Left(InvalidCategoryError());
      }

      final transaction = await _transactionService.createTransaction(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
        isRecurring: isRecurring,
      );

      return Right(transaction);
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
      await _transactionService.createTransactions(items);
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
      final existing = await _transactionService.getTransactionById(id);
      if (existing == null) {
        return const Left(TransactionNotFoundError());
      }

      // Valide le compte si modifié
      if (accountId != null) {
        final account = await _accountService.getAccountById(accountId);
        if (account == null) {
          return const Left(InvalidAccountError());
        }
      }

      // Valide la catégorie si modifiée
      if (categoryId != null) {
        final category = await _categoryService.getCategoryById(categoryId);
        if (category == null) {
          return const Left(InvalidCategoryError());
        }
      }

      final updated = await _transactionService.updateTransaction(
        id: id,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: date,
        note: note,
        isRecurring: isRecurring,
      );

      return Right(updated);
    } catch (e) {
      return Left(TransactionUpdateError('Erreur: $e'));
    }
  }

  /// Supprime une transaction
  Future<Either<TransactionError, Unit>> deleteTransaction(String id) async {
    try {
      final existing = await _transactionService.getTransactionById(id);
      if (existing == null) {
        return const Left(TransactionNotFoundError());
      }

      await _transactionService.deleteTransaction(id);
      return const Right(unit);
    } catch (e) {
      return Left(TransactionDeletionError('Erreur: $e'));
    }
  }

  /// Compte le nombre total de transactions
  Future<int> countTransactions() {
    return _transactionService.countTransactions();
  }

  // ==================== STATISTIQUES ====================

  /// Récupère le total par catégorie sur une période
  Future<Either<TransactionError, List<CategoryStatistics>>> getTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final stats = await _statisticsService.getTotalByCategory(startDate, endDate);
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
    return _statisticsService.watchTotalByCategory(startDate, endDate);
  }

  /// Récupère le total par catégorie et type
  Future<Either<TransactionError, List<CategoryStatistics>>>
      getTotalByCategoryAndType(
    DateTime startDate,
    DateTime endDate,
    CategoryType type,
  ) async {
    try {
      final stats = await _statisticsService.getTotalByCategoryAndType(
        startDate, endDate, type);
      return Right(stats);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Récupère les statistiques mensuelles d'une année
  Future<Either<TransactionError, List<MonthlyStatistics>>>
      getMonthlyStatistics(int year) async {
    try {
      final stats = await _statisticsService.getMonthlyStatistics(year);
      return Right(stats);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des statistiques mensuelles
  Stream<List<MonthlyStatistics>> watchMonthlyStatistics(int year) {
    return _statisticsService.watchMonthlyStatistics(year);
  }

  /// Récupère le résumé financier global
  Future<Either<TransactionError, FinancialSummary>>
      getFinancialSummary() async {
    try {
      final summary = await _statisticsService.getFinancialSummary();
      return Right(summary);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream du résumé financier
  Stream<FinancialSummary> watchFinancialSummary() {
    return _statisticsService.watchFinancialSummary();
  }

  /// Récupère les dépenses d'une catégorie ce mois
  Future<Either<TransactionError, double>> getCategorySpendingThisMonth(
    String categoryId,
  ) async {
    try {
      final spending =
          await _statisticsService.getCategorySpendingThisMonth(categoryId);
      return Right(spending);
    } catch (e) {
      return Left(TransactionFetchError('Erreur: $e'));
    }
  }

  /// Stream des dépenses d'une catégorie ce mois
  Stream<double> watchCategorySpendingThisMonth(String categoryId) {
    return _statisticsService.watchCategorySpendingThisMonth(categoryId);
  }

  // ==================== RECHERCHE ====================

  /// Recherche les transactions par note (pour les suggestions)
  Future<Either<TransactionError, List<TransactionWithDetails>>> searchByNote(
    String query, {
    int limit = 5,
  }) async {
    try {
      final results = await _transactionService.searchByNote(query, limit: limit);
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
      final results = await _transactionService
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
          await _transactionService.getRecentDistinctNotes(limit: limit);
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
      final results = await _transactionService
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
      final results = await _transactionService.getTransactionsPaginated(
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
      final results = await _transactionService.getTransactionsByAccountPaginated(
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
