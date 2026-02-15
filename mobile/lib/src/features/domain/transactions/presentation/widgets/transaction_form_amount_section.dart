import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/numeric_keypad.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';

class TransactionFormAmountSection extends ConsumerWidget {
  const TransactionFormAmountSection({
    required this.showKeypad,
    required this.onTap,
    required this.isDark,
    super.key,
  });

  final bool showKeypad;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    final color = state.type == CategoryType.expense
        ? AppColors.error
        : AppColors.success;

    final prefix = state.type == CategoryType.expense ? '-' : '+';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: showKeypad
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: showKeypad
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          children: [
            Text(
              state.type == CategoryType.expense ? 'Dépense' : 'Revenu',
              style: AppTextStyles.labelMedium(color: color),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(prefix, style: AppTextStyles.h1(color: color)),
                Text(state.displayAmount, style: AppTextStyles.h1(color: color)),
                const SizedBox(width: 8),
                Text(
                  '€',
                  style: AppTextStyles.h2(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              showKeypad ? 'Tapez pour fermer' : 'Tapez pour modifier',
              style: AppTextStyles.caption(
                color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionFormNumericKeypad extends ConsumerWidget {
  const TransactionFormNumericKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFormNotifierProvider.notifier);

    return NumericKeypad(
      onDigit: notifier.appendDigit,
      onDelete: notifier.deleteDigit,
      onClear: notifier.clearAmount,
    );
  }
}
