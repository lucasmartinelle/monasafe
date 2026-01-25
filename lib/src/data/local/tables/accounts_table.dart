import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';

/// Table des comptes bancaires/portefeuilles
///
/// Index:
/// - idx_accounts_name : Recherche rapide par nom de compte
@TableIndex(name: 'idx_accounts_name', columns: {#name})
class Accounts extends Table {
  /// Identifiant unique (UUID v4)
  TextColumn get id => text()();

  /// Nom du compte (ex: "Compte Courant BNP", "Livret A")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Type de compte (checking, savings, cash)
  IntColumn get type => integer().map(const AccountTypeConverter())();

  /// Solde initial du compte
  RealColumn get balance => real().withDefault(const Constant(0))();

  /// Code devise ISO 4217 (EUR, USD, etc.)
  TextColumn get currency => text().withLength(min: 3, max: 3)();

  /// Couleur du compte (valeur hexadécimale stockée en int)
  IntColumn get color => integer()();

  /// Dernière synchronisation avec le serveur (nullable si jamais synchronisé)
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
