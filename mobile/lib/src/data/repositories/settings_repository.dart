import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/services/services.dart';

/// Repository pour la gestion des paramètres utilisateur
class SettingsRepository {
  SettingsRepository(this._settingsService);

  final SettingsService _settingsService;

  // ==================== ONBOARDING ====================

  /// Vérifie si l'onboarding a été complété
  Future<bool> isOnboardingCompleted() {
    return _settingsService.getBool(SettingsKeys.onboardingCompleted);
  }

  /// Stream de l'état de l'onboarding
  Stream<bool> watchOnboardingCompleted() {
    return _settingsService.watchBool(SettingsKeys.onboardingCompleted);
  }

  /// Marque l'onboarding comme complété
  Future<void> setOnboardingCompleted() {
    return _settingsService.setBool(SettingsKeys.onboardingCompleted, value: true);
  }

  // ==================== DEVISE ====================

  /// Récupère la devise de l'utilisateur
  Future<String> getCurrency() async {
    final value = await _settingsService.getValue(SettingsKeys.currency);
    return value ?? 'EUR';
  }

  /// Stream de la devise
  Stream<String> watchCurrency() {
    return _settingsService
        .watchValue(SettingsKeys.currency)
        .map((v) => v ?? 'EUR');
  }

  /// Définit la devise de l'utilisateur
  Future<void> setCurrency(String currency) {
    return _settingsService.setValue(SettingsKeys.currency, currency);
  }

  // ==================== MODE ANONYME ====================

  /// Vérifie si l'utilisateur est en mode anonyme (local only)
  Future<bool> isAnonymous() {
    return _settingsService.getBool(SettingsKeys.isAnonymous, defaultValue: true);
  }

  /// Stream du mode anonyme
  Stream<bool> watchIsAnonymous() {
    return _settingsService.watchBool(SettingsKeys.isAnonymous, defaultValue: true);
  }

  /// Définit le mode anonyme
  Future<void> setIsAnonymous({required bool value}) {
    return _settingsService.setBool(SettingsKeys.isAnonymous, value: value);
  }

  // ==================== COMPTE PRINCIPAL ====================

  /// Récupère l'ID du compte principal
  Future<String?> getPrimaryAccountId() {
    return _settingsService.getValue(SettingsKeys.primaryAccountId);
  }

  /// Stream de l'ID du compte principal
  Stream<String?> watchPrimaryAccountId() {
    return _settingsService.watchValue(SettingsKeys.primaryAccountId);
  }

  /// Définit l'ID du compte principal
  Future<void> setPrimaryAccountId(String accountId) {
    return _settingsService.setValue(SettingsKeys.primaryAccountId, accountId);
  }

  // ==================== UTILS ====================

  /// Réinitialise tous les paramètres (pour debug)
  Future<void> resetAll() async {
    await _settingsService.deleteValue(SettingsKeys.onboardingCompleted);
    await _settingsService.deleteValue(SettingsKeys.currency);
    await _settingsService.deleteValue(SettingsKeys.isAnonymous);
    await _settingsService.deleteValue(SettingsKeys.primaryAccountId);
  }
}
