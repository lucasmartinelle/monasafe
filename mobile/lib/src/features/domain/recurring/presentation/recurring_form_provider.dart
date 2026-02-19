import 'package:flutter/foundation.dart' hide Category;
import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/core/utils/constants.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/recurring_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_form_provider.g.dart';

/// Provider pour gerer le formulaire de modification d'une transaction recurrente.
@riverpod
class RecurringFormNotifier extends _$RecurringFormNotifier {
  @override
  RecurringFormState? build() => null;

  /// Charge les donnees depuis une RecurringTransactionWithDetails existante.
  void loadFromRecurring(RecurringTransactionWithDetails recurring) {
    state = RecurringFormState(
      recurringId: recurring.recurring.id,
      categoryId: recurring.recurring.categoryId ?? '',
      category: recurring.category,
      account: recurring.account,
      amountCents: (recurring.recurring.amount * 100).round(),
      note: recurring.recurring.note ?? '',
      endDate: recurring.recurring.endDate,
      isActive: recurring.recurring.isActive,
    );
  }

  /// Ajoute un chiffre au montant.
  void appendDigit(String digit) {
    if (state == null || state!.isBusy) return;
    final newAmount = state!.amountCents * 10 + int.parse(digit);
    if (newAmount > kMaxAmountCents) return;
    state = state!.copyWith(amountCents: newAmount);
  }

  /// Supprime le dernier chiffre.
  void deleteDigit() {
    if (state == null || state!.isBusy) return;
    state = state!.copyWith(
      amountCents: state!.amountCents ~/ 10,
    );
  }

  /// Reinitialise le montant a zero.
  void clearAmount() {
    if (state == null || state!.isBusy) return;
    state = state!.copyWith(amountCents: 0);
  }

  /// Modifie la note.
  void setNote(String note) {
    if (state == null || state!.isBusy) return;
    state = state!.copyWith(note: note);
  }

  /// Modifie la date de fin.
  void setEndDate(DateTime? date) {
    if (state == null || state!.isBusy) return;
    if (date == null) {
      state = state!.copyWith(clearEndDate: true);
    } else {
      state = state!.copyWith(endDate: date);
    }
  }

  /// Met a jour la recurrence.
  Future<bool> update() async {
    if (state == null || !state!.isValid) return false;

    state = state!.copyWith(isLoading: true, clearError: true);

    try {
      final recurringService = ref.read(recurringTransactionServiceProvider);

      await recurringService.update(
        id: state!.recurringId,
        amount: state!.budgetLimit,
        note: state!.note.isEmpty ? null : state!.note,
        endDate: state!.endDate,
      );

      // Rafraichir les listes
      _invalidateAllProviders();

      return true;
    } catch (e) {
      state = state!.copyWith(isLoading: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Active ou desactive la recurrence.
  Future<bool> toggleActive() async {
    if (state == null) return false;

    state = state!.copyWith(isToggling: true, clearError: true);

    try {
      final recurringService = ref.read(recurringTransactionServiceProvider);

      if (state!.isActive) {
        await recurringService.deactivate(state!.recurringId);
      } else {
        await recurringService.reactivate(state!.recurringId);
      }

      state = state!.copyWith(
        isToggling: false,
        isActive: !state!.isActive,
      );

      // Rafraichir les listes
      _invalidateAllProviders();

      return true;
    } catch (e) {
      state = state!.copyWith(isToggling: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Supprime la recurrence.
  Future<bool> delete() async {
    if (state == null) {
      debugPrint('[RecurringForm] delete: state is null');
      return false;
    }

    debugPrint('[RecurringForm] delete: starting for ${state!.recurringId}');
    state = state!.copyWith(isDeleting: true, clearError: true);

    try {
      final recurringService = ref.read(recurringTransactionServiceProvider);

      await recurringService.delete(state!.recurringId);
      debugPrint('[RecurringForm] delete: service call completed');

      // Rafraichir les listes
      _invalidateAllProviders();
      debugPrint('[RecurringForm] delete: providers invalidated');

      return true;
    } catch (e, stack) {
      debugPrint('[RecurringForm] delete error: $e');
      debugPrint('[RecurringForm] stack: $stack');
      state = state!.copyWith(isDeleting: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Invalide tous les providers lies aux recurrences.
  void _invalidateAllProviders() {
    InvalidationService.onRecurringChanged(ref);
  }
}
