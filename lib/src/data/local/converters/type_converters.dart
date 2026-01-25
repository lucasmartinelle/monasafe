import 'package:drift/drift.dart';

/// Types de comptes disponibles
enum AccountType {
  checking, // Compte courant
  savings, // Compte épargne
  cash, // Espèces
}

/// Types de catégories (revenus ou dépenses)
enum CategoryType {
  income,
  expense,
}

/// Statut de synchronisation avec le serveur distant
enum SyncStatus {
  pending, // En attente de synchronisation
  synced, // Synchronisé avec le serveur
}

/// Convertisseur Drift pour AccountType
class AccountTypeConverter extends TypeConverter<AccountType, int> {
  const AccountTypeConverter();

  @override
  AccountType fromSql(int fromDb) {
    return AccountType.values[fromDb];
  }

  @override
  int toSql(AccountType value) {
    return value.index;
  }
}

/// Convertisseur Drift pour CategoryType
class CategoryTypeConverter extends TypeConverter<CategoryType, int> {
  const CategoryTypeConverter();

  @override
  CategoryType fromSql(int fromDb) {
    return CategoryType.values[fromDb];
  }

  @override
  int toSql(CategoryType value) {
    return value.index;
  }
}

/// Convertisseur Drift pour SyncStatus
class SyncStatusConverter extends TypeConverter<SyncStatus, int> {
  const SyncStatusConverter();

  @override
  SyncStatus fromSql(int fromDb) {
    return SyncStatus.values[fromDb];
  }

  @override
  int toSql(SyncStatus value) {
    return value.index;
  }
}
