import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/common_widgets/glass_card.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/account_type.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/screens/add_account_screen.dart';

/// Card affichant la liste des comptes avec leur solde.
class AccountListCard extends ConsumerWidget {
  const AccountListCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final accountsAsync = ref.watch(accountsStreamProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes comptes', style: AppTextStyles.h4(color: textColor)),
              accountsAsync.when(
                data: (accounts) => _buildAddButton(context, accounts, isDark),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Account list
          accountsAsync.when(
            data: (accounts) => _buildAccountList(
              context,
              accounts,
              textColor,
              subtitleColor,
              isDark,
            ),
            loading: () => _buildLoadingSkeleton(isDark),
            error: (_, __) => Text(
              'Erreur de chargement',
              style: AppTextStyles.bodySmall(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    List<Account> accounts,
    bool isDark,
  ) {
    // Vérifie si on peut encore créer un compte (checking ou savings manquant)
    final existingTypes = accounts.map((a) => a.type).toSet();
    final canAddChecking = !existingTypes.contains(AccountType.checking);
    final canAddSavings = !existingTypes.contains(AccountType.savings);

    if (!canAddChecking && !canAddSavings) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => AddAccountScreen.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Ajouter',
              style: AppTextStyles.caption(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList(
    BuildContext context,
    List<Account> accounts,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    if (accounts.isEmpty) {
      return _buildEmptyState(context, subtitleColor, isDark);
    }

    return Column(
      children: accounts.asMap().entries.map((entry) {
        final index = entry.key;
        final account = entry.value;
        final isLast = index == accounts.length - 1;

        return _AccountTile(
          account: account,
          textColor: textColor,
          subtitleColor: subtitleColor,
          isDark: isDark,
          showDivider: !isLast,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color subtitleColor,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => AddAccountScreen.show(context),
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun compte',
                style: AppTextStyles.labelMedium(color: subtitleColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Appuyez pour créer votre premier compte',
                style: AppTextStyles.caption(color: subtitleColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    final color = isDark
        ? AppColors.textPrimaryDark.withValues(alpha: 0.1)
        : AppColors.textPrimaryLight.withValues(alpha: 0.1);

    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({
    required this.account,
    required this.textColor,
    required this.subtitleColor,
    required this.isDark,
    required this.showDivider,
  });

  final Account account;
  final Color textColor;
  final Color subtitleColor;
  final bool isDark;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utilise le solde calculé (solde initial + transactions)
    final calculatedBalanceAsync = ref.watch(
      accountCalculatedBalanceStreamProvider(account.id),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(account.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getAccountTypeIcon(account.type),
                  size: 20,
                  color: Color(account.color),
                ),
              ),
              const SizedBox(width: 12),

              // Name and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: AppTextStyles.labelMedium(color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      getAccountTypeLabel(account.type),
                      style: AppTextStyles.caption(color: subtitleColor),
                    ),
                  ],
                ),
              ),

              // Balance (calculé avec les transactions)
              calculatedBalanceAsync.when(
                data: (balance) => Text(
                  CurrencyFormatter.format(balance),
                  style: AppTextStyles.labelLarge(color: textColor),
                ),
                loading: () => Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                error: (_, __) => Text(
                  '--,-- €',
                  style: AppTextStyles.labelLarge(color: textColor),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
      ],
    );
  }
}
