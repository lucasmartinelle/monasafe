import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/transactions/presentation/transaction_form_provider.dart';
import 'package:monasafe/src/features/transactions/presentation/widgets/transaction_form.dart';

/// Result of the edit transaction screen
enum EditTransactionResult {
  updated,
  deleted,
  reEmitted,
}

/// Modal bottom sheet for editing an existing transaction.
class EditTransactionScreen extends ConsumerWidget {
  const EditTransactionScreen({
    required this.transaction,
    super.key,
  });

  final TransactionWithDetails transaction;

  /// Shows the edit transaction modal.
  static Future<EditTransactionResult?> show(
    BuildContext context,
    TransactionWithDetails transaction,
  ) {
    return showModalBottomSheet<EditTransactionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTransactionScreen(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TransactionForm(
      title: 'Sauvegarder les modifications',
      primaryButtonLabel: 'Sauvegarder',
      onPrimaryAction: () async {
        final success =
            await ref.read(transactionFormNotifierProvider.notifier).update();
        if (success && context.mounted) {
          // Override the default pop behavior to return the correct result
          Navigator.of(context).pop(EditTransactionResult.updated);
        }
        return false; // Don't let TransactionForm handle the pop
      },
      onInit: () => ref
          .read(transactionFormNotifierProvider.notifier)
          .loadTransaction(transaction),
      secondaryActions: [
        TransactionFormAction(
          label: 'Supprimer',
          icon: Icons.delete_outline,
          isDestructive: true,
          showLoading: true,
          onPressed: () => _handleDelete(context, ref),
        ),
        TransactionFormAction(
          label: 'Ré-émettre',
          icon: Icons.replay,
          color: AppColors.success,
          onPressed: () => _handleReEmit(context, ref),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (!confirmed) return;

    final success =
        await ref.read(transactionFormNotifierProvider.notifier).delete();

    if (success && context.mounted) {
      Navigator.of(context).pop(EditTransactionResult.deleted);
    }
  }

  Future<void> _handleReEmit(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(transactionFormNotifierProvider.notifier).reEmit();

    if (success && context.mounted) {
      Navigator.of(context).pop(EditTransactionResult.reEmitted);
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la transaction'),
        content: const Text(
          'Voulez-vous vraiment supprimer cette transaction ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
