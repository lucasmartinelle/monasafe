import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/local/tables/accounts_table.dart';

part 'account_dao.g.dart';

/// DAO pour les opérations CRUD sur les comptes
///
/// Fournit des méthodes optimisées pour :
/// - CRUD basique
/// - Streams réactifs pour l'UI
/// - Calcul du solde réel (solde initial + transactions)
@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  /// Récupère tous les comptes, triés par nom
  Future<List<Account>> getAllAccounts() {
    return (select(accounts)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Stream de tous les comptes pour mise à jour réactive de l'UI
  Stream<List<Account>> watchAllAccounts() {
    return (select(accounts)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  /// Récupère un compte par son ID
  Future<Account?> getAccountById(String id) {
    return (select(accounts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Stream d'un compte spécifique
  Stream<Account?> watchAccountById(String id) {
    return (select(accounts)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Crée un nouveau compte
  Future<void> createAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Met à jour un compte existant
  Future<bool> updateAccount(AccountsCompanion account) {
    return (update(accounts)..where((t) => t.id.equals(account.id.value)))
        .write(account)
        .then((rows) => rows > 0);
  }

  /// Supprime un compte par son ID
  /// Note: Les transactions associées doivent être supprimées avant (contrainte FK)
  Future<int> deleteAccount(String id) {
    return (delete(accounts)..where((t) => t.id.equals(id))).go();
  }

  /// Met à jour le solde d'un compte
  Future<void> updateBalance(String id, double newBalance) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Met à jour la date de dernière synchronisation
  Future<void> updateLastSyncedAt(String id) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        lastSyncedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Compte le nombre total de comptes
  Future<int> countAccounts() async {
    final count = accounts.id.count();
    final query = selectOnly(accounts)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
