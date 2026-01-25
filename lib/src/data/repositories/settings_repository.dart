import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/local/tables/user_settings_table.dart';

/// Repository pour la gestion des paramètres utilisateur
class SettingsRepository {

  SettingsRepository(this._db);
  final AppDatabase _db;

  // ==================== ONBOARDING ====================

  /// Vérifie si l'onboarding a été complété
  Future<bool> isOnboardingCompleted() {
    return _db.userSettingsDao.getBool(SettingsKeys.onboardingCompleted);
  }

  /// Stream de l'état de l'onboarding
  Stream<bool> watchOnboardingCompleted() {
    return _db.userSettingsDao.watchBool(SettingsKeys.onboardingCompleted);
  }

  /// Marque l'onboarding comme complété
  Future<void> setOnboardingCompleted() {
    return _db.userSettingsDao.setBool(SettingsKeys.onboardingCompleted, true);
  }

  // ==================== DEVISE ====================

  /// Récupère la devise de l'utilisateur
  Future<String> getCurrency() async {
    final value = await _db.userSettingsDao.getValue(SettingsKeys.currency);
    return value ?? 'EUR';
  }

  /// Stream de la devise
  Stream<String> watchCurrency() {
    return _db.userSettingsDao
        .watchValue(SettingsKeys.currency)
        .map((v) => v ?? 'EUR');
  }

  /// Définit la devise de l'utilisateur
  Future<void> setCurrency(String currency) {
    return _db.userSettingsDao.setValue(SettingsKeys.currency, currency);
  }

  // ==================== MODE ANONYME ====================

  /// Vérifie si l'utilisateur est en mode anonyme (local only)
  Future<bool> isAnonymous() {
    return _db.userSettingsDao.getBool(SettingsKeys.isAnonymous, defaultValue: true);
  }

  /// Stream du mode anonyme
  Stream<bool> watchIsAnonymous() {
    return _db.userSettingsDao.watchBool(SettingsKeys.isAnonymous, defaultValue: true);
  }

  /// Définit le mode anonyme
  Future<void> setIsAnonymous(bool value) {
    return _db.userSettingsDao.setBool(SettingsKeys.isAnonymous, value);
  }

  // ==================== COMPTE PRINCIPAL ====================

  /// Récupère l'ID du compte principal
  Future<String?> getPrimaryAccountId() {
    return _db.userSettingsDao.getValue(SettingsKeys.primaryAccountId);
  }

  /// Stream de l'ID du compte principal
  Stream<String?> watchPrimaryAccountId() {
    return _db.userSettingsDao.watchValue(SettingsKeys.primaryAccountId);
  }

  /// Définit l'ID du compte principal
  Future<void> setPrimaryAccountId(String accountId) {
    return _db.userSettingsDao.setValue(SettingsKeys.primaryAccountId, accountId);
  }

  // ==================== UTILS ====================

  /// Réinitialise tous les paramètres (pour debug)
  Future<void> resetAll() async {
    await _db.userSettingsDao.deleteValue(SettingsKeys.onboardingCompleted);
    await _db.userSettingsDao.deleteValue(SettingsKeys.currency);
    await _db.userSettingsDao.deleteValue(SettingsKeys.isAnonymous);
    await _db.userSettingsDao.deleteValue(SettingsKeys.primaryAccountId);
  }
}
