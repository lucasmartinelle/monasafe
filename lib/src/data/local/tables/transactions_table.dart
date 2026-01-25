import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/tables/accounts_table.dart';
import 'package:simpleflow/src/data/local/tables/categories_table.dart';

/// Table des transactions financières
///
/// Index stratégiques pour optimisation des requêtes :
/// - idx_transactions_account_id : JOIN rapide avec Accounts
/// - idx_transactions_category_id : JOIN rapide avec Categories
/// - idx_transactions_date : Filtrage par période
/// - idx_transactions_account_date : Index composite pour requêtes
///   "transactions d'un compte sur une période" (cas d'usage principal)
/// - idx_transactions_sync_status : Identification rapide des transactions
///   en attente de synchronisation
@TableIndex(name: 'idx_transactions_account_id', columns: {#accountId})
@TableIndex(name: 'idx_transactions_category_id', columns: {#categoryId})
@TableIndex(name: 'idx_transactions_date', columns: {#date})
@TableIndex(name: 'idx_transactions_account_date', columns: {#accountId, #date})
@TableIndex(name: 'idx_transactions_sync_status', columns: {#syncStatus})
class Transactions extends Table {
  /// Identifiant unique (UUID v4)
  TextColumn get id => text()();

  /// Référence vers le compte associé
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Référence vers la catégorie associée
  TextColumn get categoryId => text().references(Categories, #id)();

  /// Montant de la transaction (toujours positif, le type de catégorie
  /// détermine si c'est un revenu ou une dépense)
  RealColumn get amount => real()();

  /// Date de la transaction
  DateTimeColumn get date => dateTime()();

  /// Note optionnelle
  TextColumn get note => text().nullable()();

  /// Indique si c'est une transaction récurrente
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// Statut de synchronisation (pending ou synced)
  IntColumn get syncStatus => integer()
      .map(const SyncStatusConverter())
      .withDefault(Constant(SyncStatus.pending.index))();

  /// Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
