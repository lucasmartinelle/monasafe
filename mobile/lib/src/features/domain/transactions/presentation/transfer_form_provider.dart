import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/core/utils/constants.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transfer_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transfer_form_provider.g.dart';

/// Notifier pour le formulaire de virement entre comptes.
@Riverpod(keepAlive: true)
class TransferFormNotifier extends _$TransferFormNotifier {
  @override
  TransferFormState build() => const TransferFormState();

  /// Réinitialise le formulaire avec les deux premiers comptes disponibles.
  void reset() {
    final accounts = ref.read(accountsStreamProvider).valueOrNull;
    state = TransferFormState(
      fromAccountId: accounts?.isNotEmpty ?? false ? accounts!.first.id : null,
      toAccountId: (accounts?.length ?? 0) > 1 ? accounts![1].id : null,
    );
  }

  // ============ Setters ============

  void setFromAccount(String id) {
    state = state.copyWith(fromAccountId: id, clearError: true);
  }

  void setToAccount(String id) {
    state = state.copyWith(toAccountId: id, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  // ============ Saisie du montant (mode centimes) ============

  void appendDigit(String digit) {
    if (state.isSubmitting) return;
    if (digit == '.') return;

    final digitValue = int.tryParse(digit);
    if (digitValue == null) return;

    final newAmount = state.amountCents * 10 + digitValue;
    if (newAmount > kMaxAmountCents) return;

    state = state.copyWith(amountCents: newAmount);
  }

  void deleteDigit() {
    if (state.isSubmitting) return;
    state = state.copyWith(amountCents: state.amountCents ~/ 10);
  }

  void clearAmount() {
    state = state.copyWith(amountCents: 0);
  }

  // ============ Action ============

  /// Crée le virement entre les deux comptes sélectionnés.
  Future<bool> createTransfer() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Veuillez remplir tous les champs requis');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repository = ref.read(transactionRepositoryProvider);
      final result = await repository.createTransfer(
        fromAccountId: state.fromAccountId!,
        toAccountId: state.toAccountId!,
        amount: state.amount,
        date: state.effectiveDate,
        note: state.note.isEmpty ? null : state.note,
      );

      return result.fold(
        (error) {
          state = state.copyWith(isSubmitting: false, error: error.message);
          return false;
        },
        (_) {
          state = state.copyWith(isSubmitting: false);
          InvalidationService.onTransactionChanged(ref);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Erreur: $e');
      return false;
    }
  }
}
