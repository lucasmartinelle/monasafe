import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';

class TransactionFormAccountDropdown extends ConsumerWidget {
  const TransactionFormAccountDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) return const SizedBox.shrink();

        final selectedAccount = accounts.firstWhere(
          (a) => a.id == state.selectedAccountId,
          orElse: () => accounts.first,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedAccount.id,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: AppTextStyles.labelMedium(color: textColor),
              dropdownColor: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              items: accounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Row(
                    children: [
                      Icon(
                        _getAccountIcon(account),
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(account.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(transactionFormNotifierProvider.notifier)
                      .setAccount(value);
                }
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  IconData _getAccountIcon(Account account) {
    return switch (account.type) {
      AccountType.checking => Icons.account_balance,
      AccountType.savings => Icons.savings,
      AccountType.cash => Icons.payments,
    };
  }
}
