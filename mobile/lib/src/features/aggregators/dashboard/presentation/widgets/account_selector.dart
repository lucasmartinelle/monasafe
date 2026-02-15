import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/aggregators/dashboard/presentation/dashboard_providers.dart';

/// Horizontal scrollable account selector chips.
class AccountSelector extends ConsumerWidget {
  const AccountSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsStreamProvider);
    final selectedAccountId = ref.watch(selectedAccountIdProvider);

    return accounts.when(
      data: (accountList) {
        if (accountList.isEmpty) {
          return const SizedBox.shrink();
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _AccountChip(
                label: 'Tous',
                icon: Icons.account_balance_wallet,
                isSelected: selectedAccountId == null,
                onTap: () {
                  ref.read(selectedAccountIdProvider.notifier).select(null);
                },
              ),
              const SizedBox(width: 8),
              ...accountList.map((account) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AccountChipWithBalance(
                    account: account,
                    icon: _getIconForType(account.type),
                    isSelected: selectedAccountId == account.id,
                    onTap: () {
                      ref
                          .read(selectedAccountIdProvider.notifier)
                          .select(account.id);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  IconData _getIconForType(AccountType type) {
    return switch (type) {
      AccountType.checking => Icons.account_balance,
      AccountType.savings => Icons.savings,
      AccountType.cash => Icons.payments,
    };
  }
}

/// Widget qui affiche un compte avec son solde calculé (réactif)
class _AccountChipWithBalance extends ConsumerWidget {
  const _AccountChipWithBalance({
    required this.account,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final Account account;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(
      accountCalculatedBalanceStreamProvider(account.id),
    );

    return _AccountChip(
      label: account.name,
      subtitle: balanceAsync.when(
        data: CurrencyFormatter.format,
        loading: () => CurrencyFormatter.format(account.balance),
        error: (_, __) => CurrencyFormatter.format(account.balance),
      ),
      icon: icon,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.label,
    required this.icon, required this.isSelected, required this.onTap, this.subtitle,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? AppColors.primary
        : isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight;

    final textColor = isSelected
        ? Colors.white
        : isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;

    final subtitleColor = isSelected
        ? Colors.white.withValues(alpha: 0.8)
        : isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;

    final iconColor = isSelected
        ? Colors.white
        : AppColors.primary;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall(color: textColor),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption(color: subtitleColor),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
