import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/selectable_option_container.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';

/// Segmented control for selecting transaction type (Expense/Income).
class TransactionTypeTabs extends ConsumerWidget {
  const TransactionTypeTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.surfaceDark
        : AppColors.backgroundLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableTab(
              label: 'Dépense',
              icon: Icons.arrow_upward,
              isSelected: state.type == CategoryType.expense,
              selectedColor: AppColors.error,
              onTap: () {
                ref
                    .read(transactionFormNotifierProvider.notifier)
                    .setType(CategoryType.expense);
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SelectableTab(
              label: 'Revenu',
              icon: Icons.arrow_downward,
              isSelected: state.type == CategoryType.income,
              selectedColor: AppColors.success,
              onTap: () {
                ref
                    .read(transactionFormNotifierProvider.notifier)
                    .setType(CategoryType.income);
              },
            ),
          ),
        ],
      ),
    );
  }
}
