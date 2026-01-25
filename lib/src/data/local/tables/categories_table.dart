import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';

/// Table des catégories de transactions
///
/// Index:
/// - idx_categories_type : Filtrage rapide par type (income/expense)
@TableIndex(name: 'idx_categories_type', columns: {#type})
class Categories extends Table {
  /// Identifiant unique (UUID v4)
  TextColumn get id => text()();

  /// Nom de la catégorie (ex: "Alimentation", "Salaire")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Clé de l'icône (référence vers assets/icons/)
  TextColumn get iconKey => text()();

  /// Couleur de la catégorie (valeur hexadécimale stockée en int)
  IntColumn get color => integer()();

  /// Type de catégorie (income ou expense)
  IntColumn get type => integer().map(const CategoryTypeConverter())();

  /// Limite de budget mensuel (nullable, fonctionnalité Premium)
  RealColumn get budgetLimit => real().nullable()();

  /// Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
