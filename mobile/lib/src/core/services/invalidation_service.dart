import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/data/providers/database_providers.dart';

/// Service centralisé pour coordonner le rafraîchissement des données
/// après un événement métier.
///
/// Élimine le couplage direct entre features en utilisant des triggers
/// définis dans la couche data. Chaque feature watch son propre trigger.
///
/// Les méthodes acceptent [Ref] (depuis un provider/notifier) ou
/// [WidgetRef] (depuis un widget) selon le contexte d'appel.
class InvalidationService {
  const InvalidationService._();

  // ==================== Depuis un provider/notifier (Ref) ====================

  /// Données de transactions modifiées (création/modification/suppression).
  /// Rafraîchit : dashboard, stats, comptes.
  static void onTransactionChanged(Ref ref) {
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  /// Données de récurrences modifiées (création/modification/suppression/toggle).
  /// Rafraîchit : liste récurrences, compteur, + transactions.
  static void onRecurringChanged(Ref ref) {
    ref.read(recurringRefreshTriggerProvider.notifier).refresh();
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  /// Récurrence créée depuis le formulaire de transaction.
  /// Rafraîchit : récurrences uniquement (les transactions sont déjà rafraîchies
  /// par le formulaire lui-même via onTransactionChanged).
  static void onRecurringCreatedFromTransaction(Ref ref) {
    ref.read(recurringRefreshTriggerProvider.notifier).refresh();
  }

  /// Budget modifié (création/modification/suppression).
  /// Rafraîchit : liste budgets, progress stream.
  static void onBudgetChanged(Ref ref) {
    ref.read(budgetRefreshTriggerProvider.notifier).refresh();
  }

  /// Catégorie modifiée (création/modification).
  /// Rafraîchit : listes de catégories.
  static void onCategoryChanged(Ref ref) {
    ref.invalidate(categoriesStreamProvider);
    ref.invalidate(expenseCategoriesStreamProvider);
    ref.invalidate(incomeCategoriesStreamProvider);
  }

  /// Compte créé.
  /// Rafraîchit : transactions (pour mettre à jour les listes de comptes).
  static void onAccountCreated(Ref ref) {
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  /// Coffre-fort activé/désactivé (chiffrement/déchiffrement des transactions).
  /// Rafraîchit : transactions.
  static void onVaultToggled(Ref ref) {
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  // ==================== Depuis un widget (WidgetRef) ====================

  /// Budget modifié (depuis un widget).
  /// Rafraîchit : liste budgets, progress stream.
  static void onBudgetChangedFromWidget(WidgetRef ref) {
    ref.read(budgetRefreshTriggerProvider.notifier).refresh();
  }

  /// Catégorie supprimée (depuis un widget).
  /// Rafraîchit : listes de catégories + budgets.
  static void onCategoryDeletedFromWidget(WidgetRef ref) {
    ref
      ..invalidate(categoriesStreamProvider)
      ..invalidate(expenseCategoriesStreamProvider)
      ..invalidate(incomeCategoriesStreamProvider);
    ref.read(budgetRefreshTriggerProvider.notifier).refresh();
  }

  /// Compte mis à jour (solde initial modifié, depuis un widget).
  /// Rafraîchit : comptes, soldes calculés, soldes réels, résumé financier.
  static void onAccountUpdatedFromWidget(WidgetRef ref) {
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  /// Toutes les données supprimées (depuis un widget).
  /// Rafraîchit : tout.
  static void onAllDataDeletedFromWidget(WidgetRef ref) {
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
    ref.read(recurringRefreshTriggerProvider.notifier).refresh();
    ref.read(budgetRefreshTriggerProvider.notifier).refresh();
  }
}
