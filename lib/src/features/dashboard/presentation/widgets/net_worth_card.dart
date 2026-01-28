import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          const SizedBox(height: 16),
          accounts.when(
            data: (accountList) => _buildAccountBadges(context, accountList),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
      balancesByType[account.type] = (balancesByType[account.type] ?? 0) + account.balance;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: balancesByType.entries.map((entry) {
        return _AccountTypeBadge(
          type: entry.key,
          balance: entry.value,
        );
      }).toList(),
    );
  }
}

class _AccountTypeBadge extends StatelessWidget {
  const _AccountTypeBadge({
    required this.type,
    required this.balance,
  });

  final AccountType type;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.primary.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.1);
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '${_getLabel()} ${CurrencyFormatter.format(balance)}',
            style: AppTextStyles.caption(color: textColor),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    return switch (type) {
      AccountType.checking => Icons.account_balance,
      AccountType.savings => Icons.savings,
      AccountType.cash => Icons.payments,
    };
  }

  String _getLabel() {
    return switch (type) {
      AccountType.checking => 'Courant',
      AccountType.savings => 'Épargne',
      AccountType.cash => 'Espèces',
    };
  }
}
