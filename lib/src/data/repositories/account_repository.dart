import 'package:fpdart/fpdart.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/services/services.dart';

/// Erreurs possibles lors des opérations sur les comptes
sealed class AccountError {
  const AccountError(this.message);
  final String message;
}

class AccountNotFoundError extends AccountError {
  const AccountNotFoundError() : super('Compte non trouvé');
}

class AccountCreationError extends AccountError {
  const AccountCreationError(super.message);
}

class AccountUpdateError extends AccountError {
  const AccountUpdateError(super.message);
}

class AccountDeletionError extends AccountError {
  const AccountDeletionError(super.message);
}

class AccountHasTransactionsError extends AccountError {
  const AccountHasTransactionsError()
      : super('Ce compte contient des transactions et ne peut pas être supprimé');
}

class AccountFetchError extends AccountError {
  const AccountFetchError(super.message);
}

class AccountBalanceError extends AccountError {
  const AccountBalanceError(super.message);
}

/// Repository pour la gestion des comptes
///
/// Fournit une abstraction propre pour l'UI avec :
/// - Gestion d'erreurs via Either (fpdart)
/// - Validation des données
class AccountRepository {
  AccountRepository(this._accountService, this._transactionService, this._statisticsService);

  final AccountService _accountService;
  final TransactionService _transactionService;
  final StatisticsService _statisticsService;

  /// Récupère tous les comptes
  Future<Either<AccountError, List<Account>>> getAllAccounts() async {
    try {
      final accounts = await _accountService.getAllAccounts();
      return Right(accounts);
    } catch (e) {
      return Left(AccountFetchError('Erreur lors de la récupération des comptes: $e'));
    }
  }

  /// Stream de tous les comptes (réactif)
  Stream<List<Account>> watchAllAccounts() {
    return _accountService.watchAllAccounts();
  }

  /// Récupère un compte par son ID
  Future<Either<AccountError, Account>> getAccountById(String id) async {
    try {
      final account = await _accountService.getAccountById(id);
      if (account == null) {
        return const Left(AccountNotFoundError());
      }
      return Right(account);
    } catch (e) {
      return Left(AccountFetchError('Erreur lors de la récupération du compte: $e'));
    }
  }

  /// Stream d'un compte spécifique
  Stream<Account?> watchAccountById(String id) {
    return _accountService.watchAccountById(id);
  }

  /// Crée un nouveau compte
  Future<Either<AccountError, Account>> createAccount({
    required String name,
    required AccountType type,
    required double initialBalance,
    required String currency,
    required int color,
  }) async {
    try {
      final account = await _accountService.createAccount(
        name: name,
        type: type,
        initialBalance: initialBalance,
        currency: currency,
        color: color,
      );
      return Right(account);
    } catch (e) {
      return Left(AccountCreationError('Erreur lors de la création du compte: $e'));
    }
  }

  /// Met à jour un compte existant
  Future<Either<AccountError, Account>> updateAccount({
    required String id,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    int? color,
  }) async {
    try {
      final existing = await _accountService.getAccountById(id);
      if (existing == null) {
        return const Left(AccountNotFoundError());
      }

      final updated = await _accountService.updateAccount(
        id: id,
        name: name,
        type: type,
        balance: balance,
        currency: currency,
        color: color,
      );
      return Right(updated);
    } catch (e) {
      return Left(AccountUpdateError('Erreur lors de la mise à jour du compte: $e'));
    }
  }

  /// Supprime un compte
  Future<Either<AccountError, Unit>> deleteAccount(String id) async {
    try {
      // Vérifie si le compte existe
      final existing = await _accountService.getAccountById(id);
      if (existing == null) {
        return const Left(AccountNotFoundError());
      }

      // Vérifie si le compte a des transactions
      final transactionCount = await _transactionService.countTransactionsByAccount(id);
      if (transactionCount > 0) {
        return const Left(AccountHasTransactionsError());
      }

      await _accountService.deleteAccount(id);
      return const Right(unit);
    } catch (e) {
      return Left(AccountDeletionError('Erreur lors de la suppression du compte: $e'));
    }
  }

  /// Compte le nombre total de comptes
  Future<int> countAccounts() {
    return _accountService.countAccounts();
  }
}
