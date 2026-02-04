import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';
import 'package:simpleflow/src/features/recurring/presentation/recurring_providers.dart';
import 'package:simpleflow/src/features/transactions/presentation/transaction_form_state.dart';

part 'transaction_form_provider.g.dart';

/// Unified notifier for transaction forms (add/edit).
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  TransactionFormState build() {
    final accounts = ref.watch(accountsStreamProvider).valueOrNull;
    final defaultAccountId =
        accounts?.isNotEmpty ?? false ? accounts!.first.id : null;

    return TransactionFormState(selectedAccountId: defaultAccountId);
  }

  /// Reset form to initial state (for adding new transaction)
  void reset() {
    final accounts = ref.read(accountsStreamProvider).valueOrNull;
    final defaultAccountId =
        accounts?.isNotEmpty ?? false ? accounts!.first.id : null;

    state = TransactionFormState(selectedAccountId: defaultAccountId);
  }

  /// Load an existing transaction for editing
  void loadTransaction(TransactionWithDetails transaction) {
    final isLinked = transaction.transaction.recurringId != null;
    state = TransactionFormState(
      transactionId: transaction.transaction.id,
      type: transaction.category.type,
      amountCents: (transaction.transaction.amount * 100).round(),
      categoryId: transaction.category.id,
      note: transaction.transaction.note ?? '',
      date: transaction.transaction.date,
      isRecurring: transaction.transaction.isRecurring,
      isLinkedToRecurrence: isLinked,
      selectedAccountId: transaction.account.id,
    );
  }

  // ============ Form field setters ============

  void setType(CategoryType type) {
    state = state.copyWith(type: type, clearCategoryId: true);
  }

  void setCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void setRecurring(bool isRecurring) {
    state = state.copyWith(isRecurring: isRecurring);
  }

  void setAccount(String accountId) {
    state = state.copyWith(selectedAccountId: accountId);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  // ============ Amount handling (cents mode) ============

  /// Append a digit to the amount.
  /// Each digit shifts existing value left and adds the new digit.
  /// e.g., 0 -> tap 1 -> 1 (0,01€) -> tap 5 -> 15 (0,15€)
  void appendDigit(String digit) {
    if (state.isBusy) return;
    if (digit == '.') return; // Ignore decimal point in cents mode

    final digitValue = int.tryParse(digit);
    if (digitValue == null) return;

    final newAmount = state.amountCents * 10 + digitValue;
    if (newAmount > 2147483647) return; // Prevent overflow

    state = state.copyWith(amountCents: newAmount);
  }

  /// Delete the last digit (divide by 10).
  void deleteDigit() {
    if (state.isBusy) return;
    state = state.copyWith(amountCents: state.amountCents ~/ 10);
  }

  void clearAmount() {
    state = state.copyWith(amountCents: 0);
  }

  // ============ Suggestions ============

  /// Apply a suggestion: set category, amount, and note from a previous transaction.
  void applySuggestion(TransactionWithDetails suggestion) {
    state = state.copyWith(
      categoryId: suggestion.category.id,
      amountCents: (suggestion.transaction.amount * 100).round(),
      note: suggestion.transaction.note ?? '',
    );
  }

  // ============ Actions ============

  /// Create a new transaction
  /// Si isRecurring est true, cree une RecurringTransaction + premiere occurrence
  Future<bool> create() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Veuillez remplir tous les champs requis');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      if (state.isRecurring) {
        // Creer une transaction recurrente
        return await _createRecurring();
      } else {
        // Creer une transaction normale
        return await _createTransaction();
      }
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Cree une transaction normale
  Future<bool> _createTransaction() async {
    final repository = ref.read(transactionRepositoryProvider);
    final result = await repository.createTransaction(
      accountId: state.selectedAccountId!,
      categoryId: state.categoryId!,
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
        _triggerRefresh();
        return true;
      },
    );
  }

  /// Cree une RecurringTransaction + premiere occurrence
  Future<bool> _createRecurring() async {
    final recurringService = ref.read(recurringTransactionServiceProvider);
    final generatorService = ref.read(recurrenceGeneratorServiceProvider);

    // 1. Creer la recurrence
    final recurring = await recurringService.create(
      accountId: state.selectedAccountId!,
      categoryId: state.categoryId!,
      amount: state.amount,
      note: state.note.isEmpty ? null : state.note,
      startDate: state.effectiveDate,
    );

    // 2. Generer la premiere occurrence
    await generatorService.generateFirstOccurrence(recurring);

    state = state.copyWith(isSubmitting: false);
    _triggerRefresh();
    _refreshRecurringProviders();
    return true;
  }

  /// Rafraîchit les providers de récurrence
  void _refreshRecurringProviders() {
    ref.invalidate(recurringWithDetailsProvider);
    ref.invalidate(activeRecurringWithDetailsProvider);
    ref.invalidate(activeRecurringCountProvider);
  }

  /// Update an existing transaction
  Future<bool> update() async {
    if (!state.isValid || state.transactionId == null) {
      state = state.copyWith(error: 'Veuillez remplir tous les champs requis');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repository = ref.read(transactionRepositoryProvider);
      final result = await repository.updateTransaction(
        id: state.transactionId!,
        accountId: state.selectedAccountId,
        categoryId: state.categoryId,
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
          _triggerRefresh();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Delete the transaction
  Future<bool> delete() async {
    if (state.transactionId == null) {
      state = state.copyWith(error: 'Transaction non trouvée');
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    try {
      final repository = ref.read(transactionRepositoryProvider);
      final result = await repository.deleteTransaction(state.transactionId!);

      return result.fold(
        (error) {
          state = state.copyWith(isDeleting: false, error: error.message);
          return false;
        },
        (_) {
          state = state.copyWith(isDeleting: false);
          _triggerRefresh();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Déclenche le rafraîchissement de tous les providers liés aux transactions
  void _triggerRefresh() {
    ref.read(transactionsRefreshTriggerProvider.notifier).refresh();
  }

  /// Re-emit: create a new transaction with the current form data
  Future<bool> reEmit() async {
    // Same as create but can be called in edit mode
    return create();
  }
}

/// Provider for note suggestions based on search query and transaction type.
@riverpod
Future<List<TransactionWithDetails>> noteSuggestions(
  Ref ref,
  String query,
  CategoryType type,
) async {
  final repository = ref.watch(transactionRepositoryProvider);

  if (query.isEmpty) {
    final result = await repository.getRecentDistinctNotesByType(type, limit: 5);
    return result.fold(
      (error) => [],
      (transactions) => transactions,
    );
  }

  final result = await repository.searchByNoteAndType(query, type);
  return result.fold(
    (error) => [],
    (transactions) => transactions,
  );
}
