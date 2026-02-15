import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form.dart';

/// Modal bottom sheet for adding a new transaction.
class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  /// Shows the add transaction modal.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TransactionForm(
      title: 'Nouvelle transaction',
      primaryButtonLabel: 'Confirmer la transaction',
      onPrimaryAction: () =>
          ref.read(transactionFormNotifierProvider.notifier).create(),
      onInit: () => ref.read(transactionFormNotifierProvider.notifier).initializeIfNeeded(),
    );
  }
}
