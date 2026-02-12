import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/stats/presentation/budget_form_state.dart';
import 'package:monasafe/src/features/stats/presentation/stats_providers.dart';
import 'package:monasafe/src/features/stats/presentation/stats_state.dart';

part 'budget_form_provider.g.dart';

/// Provider pour gérer le formulaire de modification/suppression de budget.
@riverpod
class BudgetFormNotifier extends _$BudgetFormNotifier {
  @override
  BudgetFormState? build() => null;

  /// Charge les données depuis un BudgetProgress existant.
  void loadFromBudgetProgress(BudgetProgress progress) {
    state = BudgetFormState(
      budgetId: progress.budgetId,
      categoryId: progress.category.id,
      category: progress.category,
      amountCents: (progress.monthlyBudgetLimit * 100).round(),
      currentSpending: progress.currentSpending,
    );
  }

  /// Ajoute un chiffre au montant.
  void appendDigit(String digit) {
    if (state == null) return;
    // Limite à 999999,99 (8 chiffres)
    if (state!.amountCents.toString().length >= 8) return;

    state = state!.copyWith(
      amountCents: state!.amountCents * 10 + int.parse(digit),
    );
  }

  /// Supprime le dernier chiffre.
  void deleteDigit() {
    if (state == null) return;
    state = state!.copyWith(
      amountCents: state!.amountCents ~/ 10,
    );
  }

  /// Réinitialise le montant à zéro.
  void clearAmount() {
    if (state == null) return;
    state = state!.copyWith(amountCents: 0);
  }

  /// Met à jour le budget.
  Future<bool> update() async {
    if (state == null || !state!.isValid) return false;

    state = state!.copyWith(isLoading: true);

    try {
      final budgetService = ref.read(budgetServiceProvider);

      await budgetService.upsertBudget(
        categoryId: state!.categoryId,
        budgetLimit: state!.budgetLimit,
      );

      // Rafraîchir la liste des budgets
      ref.invalidate(budgetProgressStreamProvider);
      ref.invalidate(budgetProgressListProvider);

      return true;
    } catch (e) {
      state = state!.copyWith(isLoading: false);
      return false;
    }
  }

  /// Supprime le budget.
  Future<bool> delete() async {
    if (state == null) return false;

    state = state!.copyWith(isDeleting: true);

    try {
      final budgetService = ref.read(budgetServiceProvider);

      await budgetService.deleteBudget(state!.budgetId);

      // Rafraîchir la liste des budgets
      ref.invalidate(budgetProgressStreamProvider);
      ref.invalidate(budgetProgressListProvider);

      return true;
    } catch (e) {
      state = state!.copyWith(isDeleting: false);
      return false;
    }
  }
}
