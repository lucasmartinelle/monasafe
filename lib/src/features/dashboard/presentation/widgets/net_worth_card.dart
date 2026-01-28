import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/account_type_badge.dart';
import 'package:simpleflow/src/common_widgets/glass_card.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/utils/currency_formatter.dart';
import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';

/// Card displaying the total net worth with account type badges.
class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final financialSummary = ref.watch(financialSummaryStreamProvider);
    final accounts = ref.watch(accountsStreamProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Patrimoine net',
            style: AppTextStyles.labelMedium(color: subtitleColor),
          ),
          const SizedBox(height: 8),
          financialSummary.when(
            data: (summary) => Text(
              CurrencyFormatter.format(summary.totalBalance),
              style: AppTextStyles.h1(color: textColor),
            ),
            loading: () => _buildBalanceSkeleton(textColor),
            error: (_, __) => Text(
              '--,-- €',
              style: AppTextStyles.h1(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSkeleton(Color textColor) {
    return Container(
      height: 38,
      width: 180,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildAccountBadges(BuildContext context, List<Account> accounts) {
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group accounts by type and sum balances
    final balancesByType = <AccountType, double>{};
    for (final account in accounts) {
      balancesByType[account.type] =
          (balancesByType[account.type] ?? 0) + account.balance;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: balancesByType.entries.map((entry) {
        return AccountTypeBadge(
          type: entry.key,
          balance: entry.value,
        );
      }).toList(),
    );
  }
}
