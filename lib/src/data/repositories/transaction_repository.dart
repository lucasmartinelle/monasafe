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

/// Repository orchestrateur pour la gestion des transactions.
///
/// Ce repository coordonne plusieurs services pour fournir une API unifiée
/// de gestion des transactions avec validation et statistiques intégrées.
///
/// **Pattern: Orchestrateur**
///
/// Dépend de 4 services avec des responsabilités distinctes :
/// - [TransactionService] : CRUD des transactions (source de données principale)
/// - [AccountService] : Validation des comptes lors de la création/modification
/// - [CategoryService] : Validation des catégories lors de la création/modification
///
/// Cette coordination est nécessaire car :
/// 1. La création d'une transaction nécessite de valider compte ET catégorie
/// 2. Les statistiques dépendent des transactions mais sont calculées différemment
/// 3. L'API retourne des erreurs typées (Either) pour une gestion d'erreur explicite
class TransactionRepository {
  TransactionRepository(
    this._transactionService,
    this._accountService,
    this._categoryService
  );

  final TransactionService _transactionService;
  final AccountService _accountService;
  final CategoryService _categoryService;

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
      );

      return Right(transaction);
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

  // ==================== RECHERCHE ====================

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
