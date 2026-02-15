import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/stats/presentation/stats_providers.dart';

/// Liste des transactions pour la categorie du budget.
class BudgetDetailTransactionsList extends ConsumerWidget {
  const BudgetDetailTransactionsList({
    required this.categoryId,
    required this.categoryColor,
    super.key,
  });

  final String categoryId;
  final Color categoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final period = ref.watch(selectedPeriodProvider);
    final (startDate, endDate) = period.dateRange;

    final transactionsAsync = ref.watch(
      transactionsByCategoryProvider(categoryId, startDate, endDate),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(color: secondaryColor.withValues(alpha: 0.2)),
        const SizedBox(height: 12),

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions ${period.label.toLowerCase()}',
              style: AppTextStyles.labelMedium(color: textColor),
            ),
            if (transactionsAsync.hasValue)
              Text(
                '${transactionsAsync.value!.length}',
                style: AppTextStyles.caption(color: secondaryColor),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Liste des transactions
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: secondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune transaction',
                        style: AppTextStyles.bodySmall(color: secondaryColor),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Limiter a 10 transactions max
            final displayedTransactions = transactions.take(10).toList();
            final hasMore = transactions.length > 10;

            return Column(
              children: [
                ...displayedTransactions.map(
                  (tx) => TransactionTile(transaction: tx),
                ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${transactions.length - 10} autres transactions',
                      style: AppTextStyles.caption(color: secondaryColor),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingStateWidget(
              message: 'Chargement...',
              padding: EdgeInsets.zero,
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ErrorStateWidget(
              message: 'Erreur: $error',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
