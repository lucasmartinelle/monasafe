import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/category_grid.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/recurrence_toggle.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/smart_note_field.dart';

/// Connecte le CategoryGrid au provider du formulaire.
class TransactionFormCategoryGrid extends ConsumerWidget {
  const TransactionFormCategoryGrid({this.onInteraction, super.key});

  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final categoriesAsync = state.type == CategoryType.expense
        ? ref.watch(expenseCategoriesStreamProvider)
        : ref.watch(incomeCategoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) {
        return CategoryGrid(
          categories: categories,
          selectedCategoryId: state.categoryId,
          onCategorySelected: (categoryId) {
            onInteraction?.call();
            FocusScope.of(context).unfocus();
            ref
                .read(transactionFormNotifierProvider.notifier)
                .setCategory(categoryId);
          },
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Connecte le SmartNoteField au provider du formulaire.
class TransactionFormSmartNoteField extends ConsumerWidget {
  const TransactionFormSmartNoteField({required this.onFocusChanged, super.key});

  final ValueChanged<bool> onFocusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    return SmartNoteField(
      initialValue: state.note,
      transactionType: state.type,
      onChanged: (note) {
        ref.read(transactionFormNotifierProvider.notifier).setNote(note);
      },
      onFocusChanged: onFocusChanged,
    );
  }
}

/// Connecte le RecurrenceToggle au provider du formulaire.
class TransactionFormRecurrenceToggle extends ConsumerWidget {
  const TransactionFormRecurrenceToggle({this.onInteraction, super.key});

  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    return RecurrenceToggle(
      isRecurring: state.isRecurring,
      onChanged: (value) {
        onInteraction?.call();
        FocusScope.of(context).unfocus();
        ref.read(transactionFormNotifierProvider.notifier).setRecurring(isRecurring: value);
      },
    );
  }
}
