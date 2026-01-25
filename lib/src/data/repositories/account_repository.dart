import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:uuid/uuid.dart';

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
/// - Génération automatique des UUID
/// - Validation des données
class AccountRepository {

  AccountRepository(this._db);
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  /// Récupère tous les comptes
  Future<Either<AccountError, List<Account>>> getAllAccounts() async {
    try {
      final accounts = await _db.accountDao.getAllAccounts();
      return Right(accounts);
    } catch (e) {
      return Left(AccountFetchError('Erreur lors de la récupération des comptes: $e'));
    }
  }

  /// Stream de tous les comptes (réactif)
  Stream<List<Account>> watchAllAccounts() {
    return _db.accountDao.watchAllAccounts();
  }

  /// Récupère un compte par son ID
  Future<Either<AccountError, Account>> getAccountById(String id) async {
    try {
      final account = await _db.accountDao.getAccountById(id);
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
    return _db.accountDao.watchAccountById(id);
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
      final id = _uuid.v4();
      final now = DateTime.now();

      final companion = AccountsCompanion.insert(
        id: id,
        name: name,
        type: type,
        balance: Value(initialBalance),
        currency: currency,
        color: color,
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await _db.accountDao.createAccount(companion);

      final created = await _db.accountDao.getAccountById(id);
      if (created == null) {
        return const Left(AccountCreationError('Échec de la création du compte'));
      }

      return Right(created);
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
      final existing = await _db.accountDao.getAccountById(id);
      if (existing == null) {
        return const Left(AccountNotFoundError());
      }

      final companion = AccountsCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
        balance: balance != null ? Value(balance) : const Value.absent(),
        currency: currency != null ? Value(currency) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final success = await _db.accountDao.updateAccount(companion);
      if (!success) {
        return const Left(AccountUpdateError('Échec de la mise à jour du compte'));
      }

      final updated = await _db.accountDao.getAccountById(id);
      return Right(updated!);
    } catch (e) {
      return Left(AccountUpdateError('Erreur lors de la mise à jour du compte: $e'));
    }
  }

  /// Supprime un compte
  Future<Either<AccountError, Unit>> deleteAccount(String id) async {
    try {
      // Vérifie si le compte existe
      final existing = await _db.accountDao.getAccountById(id);
      if (existing == null) {
        return const Left(AccountNotFoundError());
      }

      // Vérifie si le compte a des transactions
      final transactionCount =
          await _db.transactionDao.countTransactionsByAccount(id);
      if (transactionCount > 0) {
        return const Left(AccountHasTransactionsError());
      }

      await _db.accountDao.deleteAccount(id);
      return const Right(unit);
    } catch (e) {
      return Left(AccountDeletionError('Erreur lors de la suppression du compte: $e'));
    }
  }

  /// Récupère le solde calculé d'un compte (solde initial + transactions)
  Future<Either<AccountError, double>> getCalculatedBalance(String id) async {
    try {
      final balance = await _db.statisticsDao.calculateAccountBalance(id);
      return Right(balance);
    } catch (e) {
      return Left(AccountBalanceError('Erreur lors du calcul du solde: $e'));
    }
  }

  /// Stream du solde calculé d'un compte
  Stream<double> watchCalculatedBalance(String id) {
    return _db.statisticsDao.watchAccountBalance(id);
  }

  /// Compte le nombre total de comptes
  Future<int> countAccounts() {
    return _db.accountDao.countAccounts();
  }
}
