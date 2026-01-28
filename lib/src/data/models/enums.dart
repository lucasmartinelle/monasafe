/// Types de comptes disponibles
enum AccountType {
  checking, // Compte courant
  savings, // Compte épargne
  cash; // Espèces

  /// Convertit depuis la valeur Supabase (string)
  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AccountType.checking,
    );
  }
}

/// Types de catégories (revenus ou dépenses)
enum CategoryType {
  income,
  expense;

  /// Convertit depuis la valeur Supabase (string)
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoryType.expense,
    );
  }
}

/// Statut de synchronisation avec le serveur distant
enum SyncStatus {
  pending, // En attente de synchronisation
  synced; // Synchronisé avec le serveur

  /// Convertit depuis la valeur Supabase (string)
  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncStatus.synced,
    );
  }
}
