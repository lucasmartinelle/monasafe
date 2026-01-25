import 'package:drift/drift.dart';

/// Table pour stocker les paramètres utilisateur (clé-valeur)
///
/// Utilisée pour :
/// - Préférences de l'onboarding (devise, mode anonyme)
/// - Paramètres de l'application
/// - Flags divers
class UserSettings extends Table {
  /// Clé unique du paramètre
  TextColumn get key => text()();

  /// Valeur du paramètre (stockée en JSON string)
  TextColumn get value => text()();

  /// Date de dernière modification
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

/// Clés prédéfinies pour les paramètres utilisateur
abstract final class SettingsKeys {
  /// Onboarding complété (bool)
  static const String onboardingCompleted = 'onboarding_completed';

  /// Devise de l'utilisateur (String: EUR, USD, GBP)
  static const String currency = 'currency';

  /// Mode anonyme / local only (bool)
  static const String isAnonymous = 'is_anonymous';

  /// ID du compte principal (String)
  static const String primaryAccountId = 'primary_account_id';
}
